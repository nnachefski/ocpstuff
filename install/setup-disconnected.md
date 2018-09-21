## This doc describes how setup content mirrors for disconnected installs

###### # make sure you have ample space available on your local repo box (called repo.home.nicknach.net in my lab).  
###### # Recommended 100GB storage for this repo server.

##### # set your repo host vars
```
export MY_REPO=repo.home.nicknach.net
export SRC_REPO=registry.access.redhat.com
export OCP_VER=v3.10
export POOLID=8a85f98260c27fc50160c323263339ff
export RHN_ID=nnachefs@redhat.com
export RHN_PWD=
```
##### # or, if doing an internal puddle build
```
#export SRC_REPO=brew-pulp-docker01.web.prod.ext.phx2.redhat.com:8888
```
##### # subscribe your repo box to the proper channels for OCP
```
subscription-manager register --username=$RHN_ID --password $RHN_PWD --force
subscription-manager attach --pool=$POOLID
subscription-manager repos --disable="*"
subscription-manager repos \
   --enable=rhel-7-server-rpms \
   --enable=rhel-7-server-extras-rpms \
   --enable=rhel-7-server-ose-3.10-rpms \
   --enable=rhel-7-fast-datapath-rpms \
   --enable=rhel-7-server-ansible-2.5-rpms \
   --enable=rh-gluster-3-client-for-rhel-7-server-rpms
   
#   --enable=rhel-server-rhscl-7-rpms \
#   --enable=rhel-7-server-optional-rpms 
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
openssl req  -newkey rsa:4096 -nodes -sha256 -keyout /etc/docker/certs.d/$MY_REPO/$MY_REPO.key -x509 -days 365 -out /etc/docker/certs.d/$MY_REPO/$MY_REPO.cert
```
##### # add this to the http section in /etc/docker-distribution/registry/config.yml
```
cat <<EOF >> /etc/docker-distribution/registry/config.yml
    headers:
        X-Content-Type-Options: [nosniff]
    tls:
        certificate: /etc/docker/certs.d/$MY_REPO/$MY_REPO.cert
        key: /etc/docker/certs.d/$MY_REPO/$MY_REPO.key
EOF
```
##### # change the port from 5000 to 443
```
sed -i 's/\:5000/\:443/' /etc/docker-distribution/registry/config.yml
```
##### # restart registry
```
systemctl restart docker-distribution
```
##### # copy the cert to the webroot for your clients to pull from
```
cp -f /etc/docker/certs.d/$MY_REPO/$MY_REPO.cert /var/www/html/repo && restorecon /var/www/html/repo/$MY_REPO.cert
```
##### # copy cert to local pki store and update
```
cp -f /etc/docker/certs.d/$MY_REPO/$MY_REPO.cert /etc/pki/ca-trust/source/anchors/$MY_REPO.cert && restorecon /etc/pki/ca-trust/source/anchors/$MY_REPO.cert && update-ca-trust
```
##### # setup the epel repo so we can get python34 package, then disable it
```
rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum install -y python34 python34-pip
yum-config-manager --disable epel
```
##### # make sure skopeo is installed
```
yum install -y skopeo
```
##### # get the import-images.py script and image lists (this script is a python3 wrapper for skopeo)
```
cd ~ && wget https://raw.githubusercontent.com/nnachefski/ocpstuff/master/scripts/import-images.py && chmod +x import-images.py
wget https://raw.githubusercontent.com/nnachefski/ocpstuff/master/images/core_images.txt
wget https://raw.githubusercontent.com/nnachefski/ocpstuff/master/images/app_images.txt
wget https://raw.githubusercontent.com/nnachefski/ocpstuff/master/images/mw_images.txt  
```
##### # now get the core images, setting debug mode and a specific version (this will default to core_images.txt list)
``` 
./import-images.py docker $SRC_REPO $MY_REPO -d
```
##### # now get the other app images, specifying the app_images.txt list
```
./import-images.py docker $SRC_REPO $MY_REPO -d -l app_images.txt
```
##### # now get the other app images, specifying the app_images.txt list
```
./import-images.py docker $SRC_REPO $MY_REPO -d -l mw_images.txt
```
##### # if using internal puddle build, then you'll have to re-tag the images (add an alias).
###### # for some reason, the installer will try to pull a tag that looks like this 'v3.11.0-0.9.0'
```
TAG=v3.11.0-0.10.0 REPO=$MY_REPO; for i in `cat core_images.txt`; do docker pull $REPO/$i; docker tag $REPO/$i $REPO/`echo $i |awk -F: '{print $1}'`:$TAG; docker push $REPO/`echo $i |awk -F: '{print $1}'`:$TAG; done
```
#### # Troubleshooting disconnected installs
##### # during the install, do these commands in separate terminals to trouble shoot any missing images
```
watch oc get pods -owide --all-namespaces

# and

watch oc get pv

# and

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
