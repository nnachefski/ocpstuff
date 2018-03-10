## This doc describes how to perform an RPM-based installation of OCP 3.7
#### # BEGIN
##### # do this on ALL hosts (master/infra/nodes)
##### # SET THESE VARIABLES ###
```
export ROOT_DOMAIN=ocp.nicknach.net
export APPS_DOMAIN=apps.$ROOT_DOMAIN 
export DOCKER_DEV=/dev/vdb
export OCP_NFS_MOUNT=/home/data/openshift
export OCP_NFS_SERVER=storage.home.nicknach.net
export LDAP_SERVER=gw.home.nicknach.net
export RHSM_ID=your@rhn.com
export RHSM_PW=yourpassword
export POOLID=8a85f98260c27fc50160c323263339ff
export ANSIBLE_HOST_KEY_CHECKING=False
export MY_REPO=repo.home.nicknach.net
```
##### # make them persistent 
```
cat <<EOF >> ~/.bashrc
export ROOT_DOMAIN=$ROOT_DOMAIN
export APPS_DOMAIN=$APPS_DOMAIN
export DOCKER_DEV=$DOCKER_DEV
export OCP_NFS_MOUNT=$OCP_NFS_MOUNT
export OCP_NFS_SERVER=$OCP_NFS_SERVER
export LDAP_SERVER=$LDAP_SERVER
export POOLID=$POOLID
export ANSIBLE_HOST_KEY_CHECKING=False
export MY_REPO=$MY_REPO
EOF
```
##### # subscribe to RHSM
```
#yum install subscription-manager yum-utils -y
#subscription-manager register --username=$RHSM_ID --password $RHSM_PW --force
#subscription-manager attach --pool=$POOLID
#subscription-manager repos --disable="*"
#subscription-manager repos \
#   --enable=rhel-7-server-rpms \
#   --enable=rhel-7-server-extras-rpms \
#   --enable=rhel-7-server-ose-3.7-rpms \
#   --enable=rhel-7-fast-datapath-rpms \
#   --enable=rhel-7-server-rhscl-rpms \
#   --enable=rhel-7-server-optional-rpms 
##   --enable=rh-gluster-3-for-rhel-7-server-rpms \ 
##   --enable=rhel-7-server-3scale-amp-2.0-rpms
```
##### # OR, add your internal repos
```
##yum-config-manager --disable \* && rm -rf /etc/yum.repos.d/*.repo && yum clean all
##yum-config-manager --add-repo http://$MY_REPO/rhel-7-server-rpms
##yum-config-manager --add-repo http://$MY_REPO/rhel-7-server-extras-rpms
yum-config-manager --add-repo http://$MY_REPO/rhel-7-fast-datapath-rpms
yum-config-manager --add-repo http://$MY_REPO/rhel-7-server-ose-3.7-rpms
yum-config-manager --add-repo http://$MY_REPO/rhel-server-rhscl-7-rpms
yum-config-manager --add-repo http://$MY_REPO/rhel-7-server-optional-rpms 
##yum-config-manager --add-repo http://$MY_REPO/rh-gluster-3-for-rhel-7-server-rpms
```
##### # install some general pre-req packages
``` 
yum install -y yum-utils wget git net-tools bind-utils iptables-services bridge-utils bash-completion nfs-utils dstat mlocate
```
##### # install ocp specific pre-reqs
```
yum install -y atomic atomic-openshift-utils openshift-ansible atomic-openshift-clients
```
##### # install docker
```
yum install -y docker docker-logrotate
```
##### # install gluster packages
```
#yum -y install cns-deploy heketi-client
```
##### # configure the docker pool device
```
cat <<EOF > /etc/sysconfig/docker-storage-setup
DEVS=$DOCKER_DEV
VG=docker-vg
WIPE_SIGNATURES=true
EOF
```
##### # and setup the storage
```
docker-storage-setup
```
##### # enable and start docker
```
systemctl enable docker --now
```
##### # add an internal docker registry (if any)
```
#sed -i '16,/registries =/s/\[\]/\[\"repo.home.nicknach.net:5000\"\]/' /etc/containers/registries.conf && systemctl restart docker
```
##### # make sure your nodes are up to date
```
yum -y update
```
###### # reboot if necessary 
## #  On first master only now (or bastion host)
##### #  make password-less key for openshift-ansible usage
```
ssh-keygen
```
##### # copy keys to all hosts(masters/infras/nodes).  make a list.txt of IPs and then do...
```
for i in `cat list.txt`; do ssh-copy-id root@$i; done
```
##### # create your ansible hosts (inventory) file 
###### # (see below link for creating this file)
https://raw.githubusercontent.com/nnachefski/ocpstuff/master/generate-ansible-inventory.txt
##### # now run the ansible playbook to install
```
ansible-playbook /usr/share/ansible/openshift-ansible/playbooks/byo/config.yml
```
###### #  if you to need explicitly provide a private keyfile (like with AWS)
--private-key ~/.ssh/nick-west2.pem

##### # use these commands in other terminal windows to keep an eye on the deployment (and look for potential problems)
```
watch -n2 oc adm manage-node --selector= --list-pods -owide
watch -n2 oc get pv
journalctl -xlf
```
###### # verify the install was successful
###### 'oc get nodes'

### # Now run through the post-deployment steps
#### # https://github.com/nnachefski/ocpstuff/blob/master/install-post-deployment.md

### # Now run through the rhel7-custom image build guide
#### # https://github.com/nnachefski/ocpstuff/tree/master/images

