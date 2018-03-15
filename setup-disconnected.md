## This doc describes how setup content mirrors for disconnected installs

###### # make sure you have ample space available on your local repo box (called repo.home.nicknach.net in my lab).  
###### # Recommended 100GB storage for this repo server.

##### # set your repo host var
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
mkdir /var/www/html/repo
```
##### # start the reposync
```
cd ~ && wget https://raw.githubusercontent.com/nnachefski/ocpstuff/master/scripts/sync_repos.sh && chmod +x sync_repos.sh
./sync_repos.sh
```
##### # fix selinux
``` 
restorecon -R /var/www/html/repo
```
##### # open the firewall up
##### # you can get more strict with this if you want
```
firewall-cmd --set-default-zone trusted
```
#### # now lets create the docker image mirror on our repo server
##### # install/enable/start docker-distribution on the repo box
```
yum -y install docker-distribution.x86_64 && systemctl enable docker-distribution --now
```
##### # now run the import-image.py script
```
cd ~ && wget https://raw.githubusercontent.com/nnachefski/ocpstuff/master/scripts/import-images.py && wget https://raw.githubusercontent.com/nnachefski/ocpstuff/master/images/core_images.txt
chmod +x import-images.py
./import-images.py docker $SRC_REPO $MY_REPO -d
```
##### # manually get the etcd and rhel7 images
```
skopeo --insecure-policy copy --src-tls-verify=false --dest-tls-verify=false docker://$SRC_REPO/rhel7/etcd docker://$MY_REPO/rhel7/etcd
skopeo --insecure-policy copy --src-tls-verify=false --dest-tls-verify=false docker://$SRC_REPO/rhel7.4 docker://$MY_REPO/rhel7.4
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
wget https://$MY_REPO/repo/$MY_REPO.crt && restorecon /var/www/html/repo/$MY_REPO.crt && update-ca-trust
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
#yum-config-manager --add-repo http://$REPO/repo/rh-gluster-3-for-rhel-7-server-rpms
```
##### # add your docker registry
```
sed -i '16,/registries =/s/\[\]/\[\"repo.home.nicknach.net\"\]/' /etc/containers/registries.conf
systemctl restart docker
```
##### # during the install, do these commands in other terminals
```
watch -n2 oc adm manage-node --selector= --list-pods -owide
journalctl -xlf
```
###### # look for errors about images not found