## This doc describes how to perform a disconnected installation of puddle builds (internal RH release candidates)

#### # You must first sync the development rpm repos from the internal build servers
###### # make sure you have ample space available on your local repo box (called repo.home.nicknach.net in my lab).  
###### # You need at least 30GB total.  (~10GB  for rpms and ~20GB for images)

##### # set your repo host var
```
export MY_REPO=repo.home.nicknach.net
export SRC_REPO=download-node-02.eng.bos.redhat.com
export OCP_VER=3.10.1
```
##### # start by connecting your repo box to the RH VPN.  You can setup a command line VPN client by installing these rpms
```
redhat-internal-cert-install-0.1-7.el7.csb.noarch.rpm
redhat-internal-NetworkManager-openvpn-profiles-non-gnome-0.1-30.el7.csb.noarch.rpm
redhat-internal-openvpn-profiles-0.1-30.el7.csb.noarch.rpm
```
###### # if you are an employee, you know where to get these packages from
##### # then run
``` 
openvpn --config /etc/openvpn/ovpn-phx2-udp.conf
```
###### # your repo box is now connected to the RH vpn
##### # now run this command to import the puddle repo
```
yum-config-manager --add-repo http://$SRC_REPO/brewroot/repos/rhaos-$OCP_VER-rhel-7-build/latest/x86_64/
```
##### # change the name to something more simple (rhaos-beta)
```
sed -i "s/\[.*\]/\[rhaos-beta\]/" /etc/yum.repos.d/download-node-02.eng.bos.redhat.com_brewroot_repos_rhaos-$OCP_VER-rhel-7-build_latest_x86_64_.repo
mv /etc/yum.repos.d/download-node-02.eng.bos.redhat.com_brewroot_repos_rhaos-$OCP_VER-rhel-7-build_latest_x86_64_.repo /etc/yum.repos.d/rhaos-beta.repo
```
##### # disable gpg checking (for beta/puddle builds only)
```
echo gpgcheck=0 >> /etc/yum.repos.d/rhaos-beta.repo
```
##### # start the reposync
```
cd ~ && reposync -lm --repoid=rhaos-beta
```
##### # create the repodata xml
```
createrepo rhaos-beta
```

##### # run import-images.py (skopeo wrapper script written in python3)
###### # Sorry, Python3 is all i know now.... you can get it from epel 
```
cd ~ && wget https://raw.githubusercontent.com/nnachefski/ocpstuff/master/scripts/import-images.py && chmod +x import-images.py
wget https://raw.githubusercontent.com/nnachefski/ocpstuff/master/images/core_images.txt
wget https://raw.githubusercontent.com/nnachefski/ocpstuff/master/images/app_images.txt
./import-images.py docker $SRC_REPO:8888 $MY_REPO -d -t $OCP_VER
./import-images.py docker $SRC_REPO:8888 $MY_REPO -d -l app_images.txt
```
##### # openshift from the puddle servers will expect your images to be tagged like this 'ose-pod:v3.10.0-0.57.0'.  
###### # to mitigate, add a tag alias to the images you just imported.  Run this....
```
TAG=v3.10.0-0.57.0 REPO=repo.home.nicknach.net; for i in `cat core_images.txt`; do docker pull $REPO/$i:$OCP_VER; docker tag $REPO/$i:$OCP_VER $REPO/$i:$TAG; docker push $REPO/$i:$TAG; done
```
#### # Done with repo box

### ################### now on the client systems
##### # do this on ALL hosts (master/infra/nodes)
#### # BEGIN
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
export OCP_VER=v3.10.0
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
yum-config-manager --add-repo http://$MY_REPO/repo/rhaos-beta
yum-config-manager --add-repo http://$MY_REPO/repo/rhel-7-fast-datapath-rpms
yum-config-manager --add-repo http://$MY_REPO/repo/rhel-7-server-extras-rpms
yum-config-manager --add-repo http://$MY_REPO/repo/rhel-server-rhscl-7-rpms
yum-config-manager --add-repo http://$MY_REPO/repo/rhel-7-server-optional-rpms 
yum-config-manager --add-repo http://$MY_REPO/repo/rh-gluster-3-client-for-rhel-7-server-rpms
yum-config-manager --add-repo http://$MY_REPO/repo/rhel-7-server-ansible-2.4-rpms
```
##### # disable gpg checks (because these are beta bits)
```
echo gpgcheck=0 >> /etc/yum.repos.d/repo.home.nicknach.net_repo_rhaos-beta.repo
```
##### # install some general pre-req packages
``` 
yum install -y yum-utils wget git net-tools bind-utils iptables-services bridge-utils bash-completion nfs-utils dstat mlocate screen
```
##### # install openshift specific pre-reqs
```
yum install -y atomic atomic-openshift-clients
```
##### # install docker
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
container-storage-setup
```
##### # add the internal docker registry
```
sed -i 's/registry.access.redhat.com/repo.home.nicknach.net/' /etc/containers/registries.conf && systemctl restart docker
```
##### # add the registry mirror cert
```
wget http://$MY_REPO/repo/$MY_REPO.crt && mv -f $MY_REPO.crt /etc/pki/ca-trust/source/anchors && restorecon /etc/pki/ca-trust/source/anchors/$MY_REPO.crt && update-ca-trust
```
##### # test pulling a base ocp container
```
docker pull openshift3/ose-pod:$OCP_VER 
```
##### # make sure your nodes are up to date
```
yum -y update
```
###### # reboot if necessary 
## #  On first master only now (or bastion host)
```
yum install -y openshift-ansible-playbooks && updatedb
```
###### # this will install openshift-ansible and dependencies 
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
##### # run the pre-req check
```
ansible-playbook /usr/share/ansible/openshift-ansible/playbooks/prerequisites.yml
```
##### # now run the ansible playbook to install
```
ansible-playbook /usr/share/ansible/openshift-ansible/playbooks/deploy_cluster.yml
```
###### #  if you to need explicitly provide a private keyfile (like with AWS)
--private-key ~/.ssh/nick-west2.pem

##### # during the install, do these commands in separate terminals to trouble shoot any issues
```
watch -n2 oc get pods -owide --all-namespaces

and

watch -n2 oc get pv

and

journalctl -xlf
```
###### # verify the install was successful (oc get nodes)
### # Now run through the post-deployment steps
#### # https://github.com/nnachefski/ocpstuff/blob/master/install/install-post-deployment.md


