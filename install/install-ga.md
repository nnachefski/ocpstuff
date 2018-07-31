### # BEGIN
##### # do this on ALL hosts (master/infra/nodes)
##### # SET THESE VARIABLES ###
```
export ROOT_DOMAIN=ocp.nicknach.net
export APPS_DOMAIN=apps.$ROOT_DOMAIN 
export DOCKER_DEV=/dev/vdb
export LDAP_SERVER=gw.home.nicknach.net
export ANSIBLE_HOST_KEY_CHECKING=False
export MY_REPO=repo.home.nicknach.net
export OCP_VER=v3.10.21
```
##### # make them persistent 
```
cat <<EOF >> ~/.bashrc
export ROOT_DOMAIN=$ROOT_DOMAIN
export APPS_DOMAIN=$APPS_DOMAIN
export DOCKER_DEV=$DOCKER_DEV
export LDAP_SERVER=$LDAP_SERVER
export ANSIBLE_HOST_KEY_CHECKING=False
export MY_REPO=$MY_REPO
export OCP_VER=$OCP_VER
export RHN_ID=nnachefs@redhat.com
export RHN_PASSWD=
export RHN_POOL=8a85f98260c27fc50160c323263339ff
EOF
```
##### # install sub manager
```
yum install -y subscription-manager yum-utils wget
```
##### # subscribe to RHN
```
subscription-manager register --username=$RHN_ID --password $RHN_PASSWD --force
subscription-manager attach --pool=$RHN_POOL
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
##### # OR add your internal repos (for disconnected installs)
```
#rm -rf /etc/yum.repos.d/* && yum clean all
#yum-config-manager --add-repo http://$MY_REPO/repo/rhel-7-server-ose-3.10-rpms
#yum-config-manager --add-repo http://$MY_REPO/repo/rhel-7-fast-datapath-rpms
#yum-config-manager --add-repo http://$MY_REPO/repo/rhel-7-server-rpms
#yum-config-manager --add-repo http://$MY_REPO/repo/rhel-7-server-extras-rpms
#yum-config-manager --add-repo http://$MY_REPO/repo/rhel-server-rhscl-7-rpms
#yum-config-manager --add-repo http://$MY_REPO/repo/rhel-7-server-optional-rpms 
#yum-config-manager --add-repo http://$MY_REPO/repo/rh-gluster-3-client-for-rhel-7-server-rpms
#yum-config-manager --add-repo http://$MY_REPO/repo/rhel-7-server-ansible-2.5-rpms
```
##### # add the docker repo cert to the pki store (for disconnected installs)
```
#wget http://$MY_REPO/repo/$MY_REPO.crt && mv -f $MY_REPO.crt /etc/pki/ca-trust/source/anchors && restorecon /etc/pki/ca-trust/source/anchors/$MY_REPO.crt && update-ca-trust
```
##### # install some general pre-req packages
``` 
yum install -y yum-utils wget git net-tools bind-utils iptables-services bridge-utils bash-completion nfs-utils dstat mlocate screen
```
##### # install openshift client package (oc)
```
yum install -y atomic-openshift-clients
```
##### # install docker
```
yum install -y docker docker-logrotate
```
##### # install gluster packages 
```
yum install -y cns-deploy heketi-client
```
##### # configure the docker pool device
```
#cat <<EOF > /etc/sysconfig/docker-storage-setup
#DEVS=$DOCKER_DEV
#VG=docker-vg
#WIPE_SIGNATURES=true
#EOF
```
##### # and setup the storage
```
#container-storage-setup
```
##### # make sure your nodes are up-to-date
```
yum -y update
```
###### # reboot if necessary 
## #  On first master only now (or bastion host)
##### # install openshift-ansible and dependencies 
```
yum install -y openshift-ansible-playbooks && updatedb
```
##### #  make password-less key for ansible usage
```
ssh-keygen
```
##### # copy key to all hosts(masters/infras/nodes).  make a list.txt of hostnames/IPs and then do...
```
for i in `cat list.txt`; do ssh-copy-id root@$i; done
```
##### # create your ansible hosts (inventory) file 
###### # (see below link for creating this file)
https://raw.githubusercontent.com/nnachefski/ocpstuff/master/generate-ansible-inventory.sh
##### # run the pre-req check
```
ansible-playbook /usr/share/ansible/openshift-ansible/playbooks/prerequisites.yml
```
##### # now run the ansible playbook to deploy
```
ansible-playbook /usr/share/ansible/openshift-ansible/playbooks/deploy_cluster.yml
```
###### #  if you to need explicitly provide a private key file (like with AWS)
--private-key ~/.ssh/nick-west2.pem

##### # during the install, do these commands in separate terminals to trouble shoot any issues
```
watch oc get pods -owide --all-namespaces

and

watch oc get pv

and

journalctl -xlf
```
###### # verify the install was successful (oc get nodes)
### # Now run through the post-deployment steps
#### # https://github.com/nnachefski/ocpstuff/blob/master/install/install-post-deployment.md

