##### # do this on ALL hosts (master/infra/nodes)
#### # BEGIN
##### # SET THESE VARIABLES ###
```
export ROOT_DOMAIN=ocp.nicknach.net
export APPS_DOMAIN=apps.$ROOT_DOMAIN 
export DOCKER_DEV=/dev/vdb
export LDAP_SERVER=gw.home.nicknach.net
export ANSIBLE_HOST_KEY_CHECKING=False
export MY_REPO=repo.home.nicknach.net
export OCP_VER=v3.11.0
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
EOF
```
##### # install sub manager
```
yum install -y subscription-manager yum-utils wget
```
##### # add your internal repos
```
rm -rf /etc/yum.repos.d/* && yum clean all
yum-config-manager --add-repo http://$MY_REPO/repo/rhaos-alpha
yum-config-manager --add-repo http://$MY_REPO/repo/rhel-7-fast-datapath-rpms
yum-config-manager --add-repo http://$MY_REPO/repo/rhel-7-server-extras-rpms
yum-config-manager --add-repo http://$MY_REPO/repo/rhel-server-rhscl-7-rpms
yum-config-manager --add-repo http://$MY_REPO/repo/rhel-7-server-optional-rpms 
yum-config-manager --add-repo http://$MY_REPO/repo/rh-gluster-3-client-for-rhel-7-server-rpms
yum-config-manager --add-repo http://$MY_REPO/repo/rhel-7-server-ansible-2.6-rpms
```
##### # disable gpg checks (because these are beta bits)
```
echo gpgcheck=0 >> /etc/yum.repos.d/$MY_REPO_repo_rhaos-alpha.repo
```
##### # install some general pre-req packages
``` 
yum install -y yum-utils wget git net-tools bind-utils iptables-services bridge-utils bash-completion nfs-utils dstat mlocate screen
```
##### # install openshift specific pre-reqs
```
yum install -y atomic atomic-openshift-clients
```
##### # install cri-o
```
yum install -y cri-o cri-tools podman runc && systemctl enable crio --now
```
##### # install docker
```
yum install -y docker && systemctl enable docker --now 
```
##### # install gluster packages 
```
yum -y install cns-deploy heketi-client
```
##### # add the registry mirror cert
```
wget http://$MY_REPO/repo/$MY_REPO.cert && mv -f $MY_REPO.cert /etc/pki/ca-trust/source/anchors && restorecon /etc/pki/ca-trust/source/anchors/$MY_REPO.cert && update-ca-trust
```
##### # add the internal docker registry
```
sed -i "s/registry.access.redhat.com/$MY_REPO/" /etc/containers/registries.conf && systemctl restart docker
```
##### # add the internal registry to crio.conf
```
sed -i "s/#registries = \[/registries = [ '$MY_REPO' ]/" /etc/crio/crio.conf && systemctl restart crio
```
##### # make sure your nodes are up to date
```
yum -y update
```
###### # reboot if necessary 
## #  On first master only now (or bastion host)
##### # install openshift-ansible and dependencies 
```
yum install -y openshift-ansible-playbooks && updatedb
```
##### # create your ansible hosts (inventory) file 
###### # (see below link for creating this file)
https://raw.githubusercontent.com/nnachefski/ocpstuff/master/generate-ansible-inventory.sh
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
watch oc get pods -owide --all-namespaces

and

watch oc get pv

and

journalctl -xlf
```
###### # verify the install was successful (oc get nodes)
### # Now run through the post-deployment steps
#### # https://github.com/nnachefski/ocpstuff/blob/master/install/install-post-deployment.md


