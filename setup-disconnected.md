## This doc describes how setup content mirrors for disconnected installs

###### # make sure you have ample space available on your local repo box (called repo.home.nicknach.net in my lab).  
###### # Recommended 100GB storage for this repo server.

##### # set your repo host vars
```
export MY_REPO=repo.home.nicknach.net
export SRC_REPO=registry.access.redhat.com
export OCP_VER=v3.9.14
```
##### # subscribe your repo box to the proper channels for OCP
```
subscription-manager register --username=nnachefs@redhat.com --password <REDACTED> --force
subscription-manager attach --pool=8a85f98260c27fc50160c323263339ff
subscription-manager repos --disable="*"
subscription-manager repos \
   --enable=rhel-7-server-rpms \
   --enable=rhel-7-server-extras-rpms \
   --enable=rhel-7-server-ose-3.9-rpms \
   --enable=rhel-7-fast-datapath-rpms \
   --enable=rhel-7-server-rhscl-rpms \
   --enable=rhel-7-server-ansible-2.4-rpms \
   --enable=rh-gluster-3-client-for-rhel-7-server-rpms \
   --enable=rhel-7-server-optional-rpms 
```
##### # install/enable/start httpd
```
yum -y install httpd && systemctl enable httpd --now
```
##### # start the reposync
```
cd ~ && mkdir repo && wget https://raw.githubusercontent.com/nnachefski/ocpstuff/master/scripts/sync_repos.sh && chmod +x sync_repos.sh
./sync_repos.sh
```
##### # move and fix repo dir selinux
```
mv repo /var/www/html && restorecon -R /var/www/html
```
##### # open the firewall up
###### # you can get more strict with this if you want
```
firewall-cmd --set-default-zone trusted
```
### # now lets create the docker image mirror on our repo server
##### # install/enable/start docker-distribution on the repo box
```
yum -y install docker-distribution.x86_64 && systemctl enable docker-distribution --now
```
##### # create certs for this registry (so you can enable https, required for v2 images)
```
mkdir -p /etc/docker/certs.d/$MY_REPO
openssl req  -newkey rsa:4096 -nodes -sha256 -keyout /etc/docker/certs.d/$MY_REPO/$MY_REPO.key -x509 -days 365 -out /etc/docker/certs.d/$MY_REPO/$MY_REPO.crt
```
##### # add this to the http section in /etc/docker-distribution/registry/config.yml
```
    headers:
        X-Content-Type-Options: [nosniff]
    tls:
        certificate: /etc/docker/certs.d/$MY_REPO/$MY_REPO.crt
        key: /etc/docker/certs.d/$MY_REPO/$MY_REPO.key
```
##### # restart registry for SSL changes
```
systemctl restart docker-distribution
```
##### # copy the cert to the webroot for your clients to pull from
```
cp -f /etc/docker/certs.d/$MY_REPO/$MY_REPO.crt /var/www/html/repo && restorecon /var/www/html/repo/$MY_REPO.crt
```
##### # get the import-image.py script and image lists
```
cd ~ && wget https://raw.githubusercontent.com/nnachefski/ocpstuff/master/scripts/import-images.py && chmod +x import-images.py
wget https://raw.githubusercontent.com/nnachefski/ocpstuff/master/images/core_images.txt
wget https://raw.githubusercontent.com/nnachefski/ocpstuff/master/images/app_images.txt 
```
##### # now get the core images, setting debug mode and a specific version (this will default to core_images.txt list)
``` 
./import-images.py docker $SRC_REPO $MY_REPO -d -t $OCP_VER
```
##### # now get the other app images, specifying the app_images.txt list (this will default to 'latest' tag)
```
./import-images.py docker $SRC_REPO $MY_REPO -d -l app_images.txt
```
#### # done with repo box

### # now on your client boxes
##### # set your docker repo host var
```
export REPO=repo.home.nicknach.net
```
##### # import keys from repo
```
rpm --import http://$REPO/7fa2af80.pub
rpm --import http://$REPO/RPM-GPG-KEY-EPEL-7
rpm --import http://$REPO/RPM-GPG-KEY-redhat-release
```
##### # add the docker repo cert to the pki store
```
wget http://$REPO/repo/$REPO.crt && mv -f $REPO.crt /etc/pki/ca-trust/source/anchors && restorecon /etc/pki/ca-trust/source/anchors/$REPO.crt && update-ca-trust
```
##### # add your rpm repos
```
yum-config-manager --disable \* && rm -rf /etc/yum.repos.d/*.repo && yum clean all
yum-config-manager --add-repo http://$REPO/repo/rhel-7-server-rpms
yum-config-manager --add-repo http://$REPO/repo/rhel-7-fast-datapath-rpms
yum-config-manager --add-repo http://$REPO/repo/rhel-7-server-extras-rpms
yum-config-manager --add-repo http://$REPO/repo/rhel-7-server-ose-3.9-rpms
yum-config-manager --add-repo http://$REPO/repo/rhel-server-rhscl-7-rpms
yum-config-manager --add-repo http://$REPO/repo/rhel-7-server-optional-rpms 
yum-config-manager --add-repo http://$REPO/repo/rh-gluster-3-client-for-rhel-7-server-rpms
yum-config-manager --add-repo http://$REPO/repo/rhel-7-server-ansible-2.4-rpms
```
##### # add your docker registry
```
sed -i "16,/registries =/s/\[\]/\[\'$REPO\'\]/" /etc/containers/registries.conf
systemctl restart docker
```
#### # Troubleshooting disconnected installs
##### # during the install, do these commands in separate terminals to trouble shoot any missing images
```
watch -n2 oc adm manage-node --selector= --list-pods -owide

and

watch -n2 oc get pv

and

journalctl -xlf
```
###### # look for errors about images not found
##### # after install, you may find that you didnt copy EVERY single non-core image.  If that is the case, *some* imageStreams may reference non-existing (older) images.  If you want a list of missing (defunct) images, then do this
```
for i in `oc get is -n openshift |grep -v NAME |awk '{print $1}'`; do oc get is $i -n openshift -o json; done |grep 'not found' |awk '{print $3}' |awk -F \/ '{print $2,$3}' | awk -F \: '{print $1}' |sed 's/ /\//g' |sort -u
```
###### # this will yield a list of missing images that you can import using the import-images.py script
###### # redirect the output to a file (> missing.txt) and then re-run the import-images.py script with '-l missing.txt'
###### # (be prepared to pay a storage cost for all those old images)
