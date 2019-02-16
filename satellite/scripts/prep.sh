export ANSIBLE_HOST_KEY_CHECKING=False
curl http://satellite.home.nicknach.net/pub/hosts_libvirt > hosts
curl http://satellite.home.nicknach.net/pub/prep.sh > prep.sh && chmod +x prep.sh
./prep.sh
mv hosts /etc/ansible -f
ansible "*" -m script -a "./prep.sh"
curl https://raw.githubusercontent.com/openshift/openshift-ansible/master/roles/openshift_storage_glusterfs/files/glusterfs-template.yml > /usr/share/ansible/openshift-ansible/roles/openshift_storage_glusterfs/files/glusterfs-template.yml
ansible-playbook /usr/share/ansible/openshift-ansible/playbooks/prerequisites.yml
[root@satellite pub]# cat prep.sh 
export ANSIBLE_HOST_KEY_CHECKING=False && echo ANSIBLE_HOST_KEY_CHECKING=False >> /etc/environment
curl http://satellite.home.nicknach.net/pub/bootstrap.py > bootstrap.py && chmod +x bootstrap.py && ./bootstrap.py -l admin -o nicknach -a ocp-node -s satellite.home.nicknach.net -L home -g ocp-nodes -p welcome1 --skip-puppet --force
yum clean all
## install sub manager
yum install -d1 -y -q subscription-manager yum-utils wget
curl http://satellite.home.nicknach.net/pub/satellite.home.nicknach.net.crt > satellite.home.nicknach.net.crt && mv -f satellite.home.nicknach.net.crt /etc/pki/ca-trust/source/anchors && restorecon /etc/pki/ca-trust/source/anchors/satellite.home.nicknach.net.crt && update-ca-trust
subscription-manager repos --disable nicknach_nvidia_cuda
subscription-manager repos --disable nicknach_epel_epel
## grab your LDAP server's cert
#curl http://satellite.home.nicknach.net/pub/my-ldap-ca-bundle.crt > ~/my-ldap-ca-bundle.crt
## install some general pre-req packages
yum install -d1 -y yum-utils wget git net-tools bind-utils iptables-services bridge-utils bash-completion nfs-utils dstat mlocate screen
## install openshift client package (oc)
yum install -d1 -y atomic-openshift-clients
yum install -d1 -y openshift-ansible-playbooks
#sed -i 's/#log_path/log_path/' /etc/ansible/ansible.cfg
## install container runtime
yum install -d1 -y docker
#yum install -d1 -y crio cri-tools podman skopeo
## set the repo in runtime config (disconnected only)
sed -i "s/registry.access.redhat.com'/registry.access.redhat.com\', \'satellite.home.nicknach.net:8888\'/" /etc/containers/registries.conf
## enable container runtime
systemctl enable docker --now
#systemctl enable crio --now
## wipe the gluster disk
#wipefs --all /dev/sdb -f
## install gluster packages
yum install -d1 -y cns-deploy heketi-client
## make sure your nodes are up-to-date
yum -d1 -y update
mkdir -p /etc/origin/master
curl http://satellite.home.nicknach.net/pub/my-ldap-ca-bundle.crt > /etc/origin/master/my-ldap-ca-bundle.crt
sed -i 's/#log_path/log_path/' /etc/ansible/ansible.cfg

