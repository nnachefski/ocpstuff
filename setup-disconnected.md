## This doc describes how setup content mirrors for disconnected installs

###### # make sure you have ample space available on your local repo box (called repo.home.nicknach.net in my lab).  
###### # Recommended 100GB storage for this repo server.

##### # set your repo host vars
```
export MY_REPO=repo.home.nicknach.net
export SRC_REPO=registry.access.redhat.com
```
##### # subscribe your repo box to the proper channels for OCP
```
subscription-manager register --username=nnachefs@redhat.com --password <REDACTED> --force
subscription-manager attach --pool=8a85f98260c27fc50160c323263339ff
subscription-manager repos --disable="*"
subscription-manager repos \
   --enable=rhel-7-server-rpms \
   --enable=rhel-7-server-extras-rpms \
   --enable=rhel-7-server-ose-3.7-rpms \
   --enable=rhel-7-fast-datapath-rpms \
   --enable=rhel-7-server-rhscl-rpms \
   --enable=rhel-7-server-optional-rpms 
   --enable=rh-gluster-3-for-rhel-7-server-rpms \ 
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
mv repo /var/www/html && restorecon -R /var/www/html/repo
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
##### # create certs for this registry (so you can enable https)
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
##### # get the import-image.py script and image lists
```
cd ~ && wget https://raw.githubusercontent.com/nnachefski/ocpstuff/master/scripts/import-images.py && chmod +x import-images.py
wget https://raw.githubusercontent.com/nnachefski/ocpstuff/master/images/core_images.txt
wget https://raw.githubusercontent.com/nnachefski/ocpstuff/master/images/app_images.txt 
```
##### # now get the core images
``` 
./import-images.py docker $SRC_REPO $MY_REPO -d -t v3.7
```
##### # now get the other app images
```
./import-images.py docker $SRC_REPO $MY_REPO -d -l app_images.txt
```
##### # manually get the etcd and rhel7 images
```
skopeo --insecure-policy copy --src-tls-verify=false --dest-tls-verify=false docker://$SRC_REPO/rhel7/etcd docker://$MY_REPO/rhel7/etcd
skopeo --insecure-policy copy --src-tls-verify=false --dest-tls-verify=false docker://$SRC_REPO/rhel7.4 docker://$MY_REPO/rhel7.4
```
###### # sometimes you have to normalize the tags on your images (like with beta/puddle builds)
```
TAG=v3.9.9 REPO=repo.home.nicknach.net; for i in `cat core_images.txt`; do docker pull $REPO/$i:v3.9; docker tag $REPO/$i:v3.9 $REPO/$i:$TAG; docker push $REPO/$i:$TAG; done
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
wget http://$MY_REPO/repo/$MY_REPO.crt && mv -f $MY_REPO.crt /etc/pki/ca-trust/source/anchors && restorecon -R /etc/pki/ca-trust/source/anchors/$MY_REPO.crt && update-ca-trust
```
##### # add your rpm repos
```
yum-config-manager --disable \* && rm -rf /etc/yum.repos.d/*.repo && yum clean all
yum-config-manager --add-repo http://$REPO/repo/rhel-7-server-rpms
yum-config-manager --add-repo http://$REPO/repo/rhel-7-fast-datapath-rpms
yum-config-manager --add-repo http://$REPO/repo/rhel-7-server-extras-rpms
yum-config-manager --add-repo http://$REPO/repo/rhel-7-server-ose-3.7-rpms
yum-config-manager --add-repo http://$REPO/repo/rhel-server-rhscl-7-rpms
yum-config-manager --add-repo http://$REPO/repo/rhel-7-server-optional-rpms 
yum-config-manager --add-repo http://$REPO/repo/rh-gluster-3-for-rhel-7-server-rpms
```
##### # add your docker registry
```
sed -i '16,/registries =/s/\[\]/\[\"repo.home.nicknach.net\"\]/' /etc/containers/registries.conf
systemctl restart docker
```
##### # during the install, do these commands in other terminals to trouble shoot any missing images
```
watch -n2 oc adm manage-node --selector= --list-pods -owide
journalctl -xlf
```
###### # look for errors about images not found

#### Now run through the install howto
###### # https://github.com/nnachefski/ocpstuff/blob/master/install-37.md
