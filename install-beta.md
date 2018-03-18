## This doc describes how to perform a disconnected installation of puddle builds (internal RH release candidates)

#### # You must first sync the development rpm repos from the internal build servers
###### # make sure you have ample space available on your local repo box (called repo.home.nicknach.net in my lab).  
###### # You need at least 30GB total.  (~10GB  for rpms and ~20GB for images)

##### # set your repo host var
```
export MY_REPO=repo.home.nicknach.net
export SRC_REPO=download-node-02.eng.bos.redhat.com
```
##### # start by connecting your repo box to the RH VPN.  You can setup a command line VPN client by installing these rpms
```
redhat-internal-cert-install-0.1-7.el7.csb.noarch.rpm
redhat-internal-NetworkManager-openvpn-profiles-non-gnome-0.1-30.el7.csb.noarch.rpm
redhat-internal-openvpn-profiles-0.1-30.el7.csb.noarch.rpm
```
##### # then run
``` 
openvpn --config /etc/openvpn/ovpn-phx2-udp.conf
```
###### # your repo box is now connected to the RH vpn
##### # now run this command to import the puddle repo
```
yum-config-manager --add-repo http://$SRC_REPO/brewroot/repos/rhaos-3.9-rhel-7-build/latest/x86_64/
```
##### # change the name to something more simple (rhaos-3.9)
```
sed -i 's/\[.*\]/\[rhaos-3.9\]/' /etc/yum.repos.d/download-node-02.eng.bos.redhat.com_brewroot_repos_rhaos-3.9-rhel-7-build_latest_x86_64_.repo
mv /etc/yum.repos.d/download-node-02.eng.bos.redhat.com_brewroot_repos_rhaos-3.9-rhel-7-build_latest_x86_64_.repo /etc/yum.repos.d/rhaos-3.9.repo
```
##### # disable gpg checking (for beta/puddle builds only)
```
echo gpgcheck=0 >> /etc/yum.repos.d/rhaos-3.9.repo
```
##### # start the reposync
```
cd ~ && reposync -lm --repoid=rhaos-3.9
```
##### # create the repodata xml
```
createrepo rhaos-3.9
```

##### # run the import-image.py script
```
cd ~ && wget https://raw.githubusercontent.com/nnachefski/ocpstuff/master/scripts/import-images.py && chmod +x import-images.py
wget https://raw.githubusercontent.com/nnachefski/ocpstuff/master/images/core_images.txt
wget https://raw.githubusercontent.com/nnachefski/ocpstuff/master/images/app_images.txt
./import-images.py docker $SRC_REPO:8888 $MY_REPO -d -t 3.9
```
##### # manually get the etcd and rhel7 images
```
skopeo --insecure-policy copy --src-tls-verify=false --dest-tls-verify=false docker://registry.access.redhat.com/rhel7/etcd docker://$MY_REPO/rhel7/etcd
skopeo --insecure-policy copy --src-tls-verify=false --dest-tls-verify=false docker://registry.access.redhat.com/rhel7.4 docker://$MY_REPO/rhel7.4
```
### # BEGIN
##### # do this on ALL hosts (master/infra/nodes)
##### # SET THESE VARIABLES ###
```
export ROOT_DOMAIN=ocp.nicknach.net
export APPS_DOMAIN=apps.$ROOT_DOMAIN 
export DOCKER_DEV=/dev/vdb
export OCP_NFS_MOUNT=/data/openshift/enterprise
export OCP_NFS_SERVER=storage.home.nicknach.net
export LDAP_SERVER=gw.home.nicknach.net
export ANSIBLE_HOST_KEY_CHECKING=False
export MY_REPO=repo.home.nicknach.net
export OCP_VER=v3.9.11
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
export ANSIBLE_HOST_KEY_CHECKING=False
export MY_REPO=$MY_REPO
export OCP_VER=$OCP_VER
EOF
```
##### # add your internal repos
```
rm -rf /etc/yum.repos.d/* && yum clean all
yum-config-manager --add-repo http://$MY_REPO/repo/rhaos-3.9
yum-config-manager --add-repo http://$MY_REPO/repo/rhel-7-fast-datapath-rpms
yum-config-manager --add-repo http://$MY_REPO/repo/rhel-7-server-extras-rpms
yum-config-manager --add-repo http://$MY_REPO/repo/rhel-server-rhscl-7-rpms
yum-config-manager --add-repo http://$MY_REPO/repo/rhel-7-server-optional-rpms 
yum-config-manager --add-repo http://$MY_REPO/repo/rh-gluster-3-for-rhel-7-server-rpms
```
##### # disable gpg checks (because these are beta bits)
```
echo gpgcheck=0 >> /etc/yum.repos.d/repo.home.nicknach.net_repo_rhaos-3.9.repo
```
##### # install some general pre-req packages
``` 
yum install -y yum-utils wget git net-tools bind-utils iptables-services bridge-utils bash-completion nfs-utils dstat mlocate
```
##### # install openshift specific pre-reqs
```
yum install -y atomic atomic-openshift-clients
```
##### # install docker (non-Atomic installs)
```
yum install -y docker docker-logrotate
```
##### # install gluster packages 
```
yum -y install cns-deploy heketi-client
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
##### # add the internal docker registry
```
sed -i "16,/registries =/s/\[\]/\[\'$MY_REPO\'\]/" /etc/containers/registries.conf
systemctl restart docker
```
##### # enable and start docker
```
systemctl enable docker --now
```
##### # make sure your nodes are up to date
```
yum -y update --disablerepo=$MY_REPO_repo_rh-gluster-3-for-rhel-7-server-rpms
```
###### # reboot if necessary 
## #  On first master only now (or bastion host)
```
yum install -y atomic-openshift-utils
```
###### # this will install openshift-ansible as a dependency
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
ansible-playbook /usr/share/ansible/openshift-ansible/playbooks/deploy_cluster.yml
```
###### #  if you to need explicitly provide a private keyfile (like with AWS)
--private-key ~/.ssh/nick-west2.pem

###### # verify the install was successful
###### 'oc get nodes'
### # Now run through the post-deployment steps
#### # https://github.com/nnachefski/ocpstuff/blob/master/install-post-deployment.txt

### # Then run through the rhel7-custom image build guide
#### # https://github.com/nnachefski/ocpstuff/tree/master/images
