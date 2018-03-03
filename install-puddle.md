## This doc describes how to perform a disconnected installation of puddle builds (internal RH release candidates)

#### # You must first sync the development rpm repos from the internal build servers
###### # make sure you have ample space available on your local repo box (called repo.home.nicknach.net in my lab).  
###### # You need at least 30GB total.  (~10GB  for rpms and ~20GB for images)

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
yum-config-manager --add-repo http://download-node-02.eng.bos.redhat.com/brewroot/repos/rhaos-3.9-rhel-7-build/latest/x86_64/
```
##### # change the name to something more simple (rhaos-3.9)
```
sed -i 's/\[.*\]/\[rhaos-3.9\]/' /etc/yum.repos.d/download-node-02.eng.bos.redhat.com_brewroot_repos_rhaos-3.9-rhel-7-build_latest_x86_64_.repo
mv /etc/yum.repos.d/download-node-02.eng.bos.redhat.com_brewroot_repos_rhaos-3.9-rhel-7-build_latest_x86_64_.repo /etc/yum.repos.d/rhaos-3.9.repo
```
##### # disable gpg checking
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
##### # install/enable/start httpd
```
yum -y install httpd && systemctl enable httpd --now
```
##### # move your repo dir into the web root
```
mv ~/rhaos-3.9 /var/www/html 
```
##### # fix selinux
``` 
restorecon -R /var/www/html/rhaos-3.9
```
#### # now lets create the docker image mirror on our repo server
##### # install/enable/start docker-distribution on the repo box
```
yum -y install docker-distribution.x86_64 && systemctl enable docker-distribution --now
```
##### # open the firewall up
```
firewall-cmd --set-default-zone trusted
```
##### # now run the import-image.py script
```
cd ~ && wget https://raw.githubusercontent.com/nnachefski/ocpstuff/master/images/import-images.py && wget https://raw.githubusercontent.com/nnachefski/ocpstuff/master/images/images.txt
chmod +x import-images.py
./import-images.py docker brew-pulp-docker01.web.prod.ext.phx2.redhat.com:8888 repo.home.nicknach.net:5000 -t v3.9.0 -d
```
##### # manually get the etcd image
```
skopeo --insecure-policy copy --src-tls-verify=false --dest-tls-verify=false docker://brew-pulp-docker01.web.prod.ext.phx2.redhat.com:8888/rhel7/etcd:latest docker://repo.home.nicknach.net:5000/rhel7/etcd:latest
```
##### # in case you have to re-tag everything
export TAG=v3.9.0-0.36.0; for i in `cat images.txt`; do docker pull repo.home.nicknach.net:5000/$i:v3.9.0; docker tag repo.home.nicknach.net:5000/$i:v3.9.0 repo.home.nicknach.net:5000/$i:$TAG; docker push repo.home.nicknach.net:5000/$i:$TAG; done

### # BEGIN
##### # do this on ALL hosts (master/infra/nodes)
##### # SET THESE VARIABLES ###
```
export ROOT_DOMAIN=ocp.nicknach.net
export APPS_DOMAIN=apps.$ROOT_DOMAIN 
export DOCKER_DEV=/dev/vdb
export OCP_NFS_MOUNT=/home/data/openshift
export OCP_NFS_SERVER=storage.home.nicknach.net
export LDAP_SERVER=gw.home.nicknach.net
export ANSIBLE_HOST_KEY_CHECKING=False
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
EOF
```
##### # add your internal repos
```
yum-config-manager --disable \* && rm -rf /etc/yum.repos.d/*.repo && yum clean all
#yum-config-manager --add-repo http://repo.home.nicknach.net/repo/rhaos-3.9
yum-config-manager --add-repo http://repo.home.nicknach.net/repo/rhel-7-fast-datapath-rpms
yum-config-manager --add-repo http://repo.home.nicknach.net/repo/rhel-7-server-extras-rpms
yum-config-manager --add-repo http://repo.home.nicknach.net/repo/rhel-server-rhscl-7-rpms
yum-config-manager --add-repo http://repo.home.nicknach.net/repo/rhel-7-server-optional-rpms 
#yum-config-manager --add-repo http://repo.home.nicknach.net/repo/rh-gluster-3-for-rhel-7-server-rpms
```
##### # disable gpg checks
```
echo gpgcheck=0 >> /etc/yum.repos.d/repo.home.nicknach.net_repo_rhaos-3.9.repo
```
##### # install some general pre-req packages
``` 
yum install -y yum-utils wget git net-tools bind-utils iptables-services bridge-utils bash-completion nfs-utils dstat mlocate
```
##### # install openshift specific pre-reqs
```
yum install -y atomic atomic-openshift-utils openshift-ansible atomic-openshift-clients
```
##### # install docker (non-Atomic installs)
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
##### # add the internal docker registry
```
sed -i '16,/registries =/s/\[\]/\[\"repo.home.nicknach.net:5000\"\]/' /etc/containers/registries.conf
systemctl restart docker
```
##### # enable and start docker
```
systemctl enable docker --now
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
ansible-playbook /usr/share/ansible/openshift-ansible/playbooks/deploy_cluster.yml
```
###### #  if you to need explicitly provide a private keyfile (like with AWS)
--private-key ~/.ssh/nick-west2.pem
###### # verify the install was successful (oc get nodes)

### # Now run through the post-deployment steps
#### # https://github.com/nnachefski/ocpstuff/install-post-deployment.md

### # Now run through the rhel7-custom image build guide
#### # https://github.com/nnachefski/ocpstuff/tree/master/images
