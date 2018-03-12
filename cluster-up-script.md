#### # created and maintained by nick@redhat.com
###### # you can copy/paste this entire page (at once) into a centos7 terminal (virt or physical)
##### Goto the following link and get the link to the desired version of Openshift that yo wish to deploy
###### # https://github.com/openshift/origin/releases
##### # set the oc binary version corresponding to the version that you want to deploy.
```
PACKAGE_LINK=https://github.com/openshift/origin/releases/download/v3.9.0-alpha.3/openshift-origin-client-tools-v3.9.0-alpha.3-78ddc10-linux-64bit.tar.gz
```
##### # You need a wildcard (domain) for Openshift to manage.  If you have easy access to a DNS server (like IPA), then you can create one.  If not, and you can send recursive DNS lookups to the public internet, then you can use xip.io. 
##### # notice below how the console is with the app domain (wildcard).  
###### # setup this way, you just need a single wildcard DNS record pointing to this box and that’s it.
```
Ex:  *.origin.ocp.nicknach.net. → 192.168.2.69
or
Ex: WILDCARD=192.168.2.69.xip.io (xip will resolve this to 192.168.2.69 for you)
```
WILDCARD=origin.ocp.nicknach.net

##### # configure the docker pool device, example here is using a secondary raw disk (“Option A”)
###### # https://docs.openshift.com/container-platform/latest/install_config/install/prerequisites.html
```
DOCKER_DEV=/dev/vdb
```
##### # setup an admin user 
```
OCP_USER=ocpadmin
```
#### # Begin
###### # you need to subscribe this system to the centos7/rhel7 base channel as well as the extras channel
##### # temporarily open the firewall up
firewall-cmd --set-default-zone trusted
##### # setup docker storage and enable
```
sudo yum install docker -y && systemctl enable docker
sudo sed -i '/# INSECURE_REGISTRY/s/# INSECURE_REGISTRY/INSECURE_REGISTRY/' /etc/sysconfig/docker; 
sed -i "s/--selinux-enabled/--selinux-enabled --insecure-registry\ 172\.30\.0\.0\\/16/" /etc/sysconfig/docker
sudo cat <<EOF > /etc/sysconfig/docker-storage-setup
DEVS=$DOCKER_DEV
VG=docker-vg
WIPE_SIGNATURES=true
EOF
sudo docker-storage-setup
``` 
##### # download the oc client and install it in /usb/bin
```
rm -rf openshift-origin-client-tools*
yum install wget -y && cd ~ && wget $PACKAGE_LINK
mkdir octool && tar -xzvf openshift-origin-client-tools*.tar.gz -C octool
cp octool/openshift-origin-client-tools*/oc /usr/bin && rm -rf octool
```
##### # launch the cluster
oc cluster up --metrics=true --logging=true --public-hostname console.$WILDCARD --routing-suffix $WILDCARD --host-data-dir=ocpdata --host-config-dir=ocpconfig --use-existing-config
##### # login and validate deployment
```
oc login -u system:admin
oc create user $OCP_USER 
oc adm policy add-cluster-role-to-user cluster-admin $OCP_USER
echo alias allpods=\'watch -n1 oc adm manage-node --selector= --list-pods\' > /etc/profile.d/ocp.sh
echo alias allpodsp=\'watch -n1 oc adm manage-node --selector= --list-pods\' >> /etc/profile.d/ocp.sh
echo export WILDCARD=$WILDCARD >> /etc/profile.d/ocp.sh
chmod +x /etc/profile.d/ocp.sh && source /etc/profile.d/ocp.sh
```
#### # done
###### # type ‘allpods’ and watch the magic happen….
###### # access https://console.$WILDCARD:8443