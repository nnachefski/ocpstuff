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
##### # add a link to your repo dir in the web root
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
EOF
```
##### # add your internal repos
```
yum-config-manager --disable \* && rm -rf /etc/yum.repos.d/*.repo && yum clean all
yum-config-manager --add-repo http://repo.home.nicknach.net/repo/rhaos-3.9
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
##### # add the internal repo
```
sed -i '16,/registries =/s/\[\]/\[\"repo.home.nicknach.net:5000\"\]/' /etc/containers/registries.conf
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

## # Begin post-deployment steps
##### # aliases for ops
```
echo alias allpods=\'watch -n1 oc adm manage-node --selector="" --list-pods -owide\' > /etc/profile.d/ocp.sh
echo alias allpodsp=\'watch -n1 oc adm manage-node --selector="region=primary" --list-pods -owide\' >> /etc/profile.d/ocp.sh
chmod +x /etc/profile.d/ocp.sh
```
##### # pin all the metrics pods to the infra nodes
```
oc patch ns openshift-infra -p '{"metadata": {"annotations": {"openshift.io/node-selector": "region=infra"}}}'
```
##### # set gluster to be the default storageclass
```
#oc annotate storageclass glusterfs-storage storageclass.beta.kubernetes.io/is-default-class="true"
```
##### # setup group sync and run it once
```
wget https://raw.githubusercontent.com/nnachefski/ocpstuff/master/ocp_group_sync.conf -O /etc/origin/master/ocp_group_sync.conf
wget https://raw.githubusercontent.com/nnachefski/ocpstuff/master/ocp_group_sync-whitelist.conf -O /etc/origin/master/ocp_group_sync-whitelist.conf 
oc adm groups sync --sync-config=/etc/origin/master/ocp_group_sync.conf --confirm --whitelist=/etc/origin/master/ocp_group_sync-whitelist.conf
```
##### # setup a cronjob on ansible host to sync groups nightly
```
echo 'oc adm groups sync --sync-config=/etc/origin/master/ocp_group_sync.conf --confirm --whitelist=/etc/origin/master/ocp_group_sync-whitelist.conf' > /etc/cron.daily/ocp-group-sync.sh && chmod +x /etc/cron.daily/ocp-group-sync.sh 
```
##### # set policies (perms) on your sync’ed groups
```
oc adm policy add-cluster-role-to-group cluster-admin admins
oc adm policy add-role-to-group basic-user authenticated
```
##### # set your infra region to unschedulable
```
oc adm manage-node --selector=region=masters --schedulable=false
oc adm manage-node --selector=region=infra --schedulable=false
```

## # Done!
### # Now run through the rhel7-custom image build guide
#### # https://github.com/nnachefski/ocpstuff/tree/master/images

### # misc stuff
##### #  entitle admins group to run pods as root
```
oc adm policy add-scc-to-group anyuid system:admins
```
##### # entitle the current project’s default svc account to run as anyuid
```
oc adm policy add-scc-to-user anyuid -z default
```
##### # setup a cronjob on ansible host to prune images
```
echo 'ansible all -m shell -a "docker rm \$(docker ps -q -f status=exited); docker volume rm \$(docker volume ls -qf dangling=true); docker rmi \$(docker images --filter "dangling=true" -q --no-trunc)"' >> /etc/cron.daily/ocp-image-clean.sh && chmod +x /etc/cron.daily/ocp-image-clean.sh
```
##### # setup a local htpasswd user if not using LDAP or SSO
```
htpasswd -b /etc/origin/master/htpasswd $OCP_USER $OCP_PASSWD
oc adm policy add-cluster-role-to-user cluster-admin $OCP_USER
```
##### # create the registry manually
##### # oc adm registry --create --credentials=/etc/origin/master/openshift-registry.kubeconfig --selector region=infra
```
#oc adm router --service-account=router --selector region=infra
#oc adm policy add-scc-to-user privileged -z router
#oc adm policy add-scc-to-user hostnetwork -z router
#oc adm policy add-cluster-role-to-user system:router system:serviceaccount:default:router
```
##### # set infra zone to not be schedulable for apps
```
oc adm manage-node --selector="region=infra" --schedulable=false
```
##### # deploying 3scale
```
#yum install -y 3scale-amp-template
#oc new-project 3scaleamp
#oc new-app --file /opt/amp/templates/amp.yml --param #WILDCARD_DOMAIN=apps.ocp.nicknach.net --param ADMIN_PASSWORD=welcome1
```
##### # add a storage class if using dynamic provisioning
##### # for AWS
```
oc create -f - <<EOF
apiVersion: v1
kind: StorageClass
apiVersion: storage.k8s.io/v1beta1
metadata:
  name: aws-ebs-default
  annotations:
    storageclass.beta.kubernetes.io/is-default-class: "true"
provisioner: kubernetes.io/aws-ebs
parameters:
  type: gp2
  zone: us-west-2b
  iopsPerGB: "1000" 
  encrypted: "false"
EOF
```
##### # for GCE
```
oc create -f - <<EOF
apiVersion: v1
kind: StorageClass
apiVersion: storage.k8s.io/v1beta1
metadata:
 name: gce-default
provisioner: kubernetes.io/gce-pd 
parameters:
 type: pd-standard 
 zone: us-west2-b
EOF
```
##### # manually create PV for registry (NFS)
```
oc create -f - <<EOF
apiVersion: v1
kind: PersistentVolume
metadata:
  name: registry-volume
spec:
  capacity:
    storage: 40Gi
  accessModes:
  - ReadWriteMany
  nfs:
    path: "$OCP_NFS_MOUNT/enterprise/docker-registry"
    server: "$OCP_NFS_SERVER"
  persistentVolumeReclaimPolicy: Retain
EOF
```
##### # manually create PV for etcd (NFS)
```
oc create -f - <<EOF
apiVersion: v1
kind: PersistentVolume
metadata:
  name: etcd-volume
spec:
  capacity:
    storage: 1Gi
  accessModes:
  - ReadWriteOnce
  nfs:
    path: "$OCP_NFS_MOUNT/enterprise/etcd"
    server: "$OCP_NFS_SERVER"
  persistentVolumeReclaimPolicy: Retain
EOF
```
##### # OR
##### # manually create PV for registry (AWS)
```
oc create -f - <<EOF
apiVersion: v1
kind: PersistentVolume
metadata:
  name: registry-volume
spec:
  capacity:
    storage: 50Gi
  accessModes:
  - ReadWriteOnce
  awsElasticBlockStore:
    fsType: ext4
    volumeID: "vol-013223dd81d5b2cfa"
  persistentVolumeReclaimPolicy: Retain
EOF
```
##### # OR
##### # manually create PV for registry (GCE)
```
oc create -f - <<EOF
apiVersion: v1
kind: PersistentVolume
metadata:
  name: registry-volume
#    failure-domain.beta.kubernetes.io/region: "us-west1" 
#    failure-domain.beta.kubernetes.io/zone: "us-west1-b"
spec:
  capacity:
    storage: 70Gi
  accessModes:
  - ReadWriteOnce
  gcePersistentDisk:
    fsType: ext4
    pdName: "docker-registry"
  persistentVolumeReclaimPolicy: Delete
EOF
```
##### # manually create the PVC
```
oc create -f - <<EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: registry-volume-claim
  labels:
    deploymentconfig: docker-registry
spec:
  accessModes:
  - ReadWriteMany
  resources:
    requests:
      storage: 40Gi
EOF
```
##### # manually switch the registry’s storage to our NFS-backed PV we just created
oc volume dc docker-registry  --add --overwrite -t persistentVolumeClaim  --claim-name=registry-volume-claim --name=registry-storage

#### # manually Deploy metrics
##### # switch to metrics project
```
oc project openshift-infra
```
##### # manually create PV for metrics (NFS)
```
oc create -f - <<EOF
apiVersion: v1
kind: PersistentVolume
metadata:
  name: metrics-volume
spec:
  capacity:
    storage: 30Gi
  accessModes:
  - ReadWriteOnce
  nfs:
    path: "$OCP_NFS_MOUNT/enterprise/metrics"
    server: "$OCP_NFS_SERVER"
  persistentVolumeReclaimPolicy: Retain
EOF
```
##### # now run the playbook
```
ansible-playbook /usr/share/ansible/openshift-ansible/playbooks/byo/openshift-cluster/openshift-metrics.yml -e openshift_metrics_install_metrics=true -e openshift_metrics_cassandra_storage_type=pv -e openshift_metrics_cassandra_pvc_size=30Gi

-e openshift_metrics_cassandra_storage_type=dynamic 
```
##### # now once the deployer is finished and you see your pods as “Running” (watch -n1 ‘oc get pods’ also, ‘oc get events’)
#### # Setup aggregated logging
```
oc project logging
```
##### # manually create PV for logging (NFS)
```
oc create -f - <<EOF
apiVersion: v1
kind: PersistentVolume
metadata:
  name: logging-volume
spec:
  capacity:
    storage: 20Gi
  accessModes:
  - ReadWriteOnce
  nfs:
    path: "$OCP_NFS_MOUNT/enterprise/logging"
    server: "$OCP_NFS_SERVER"
  persistentVolumeReclaimPolicy: Retain
EOF
```
##### # now run the playbook
```
ansible-playbook /usr/share/ansible/openshift-ansible/playbooks/byo/openshift-cluster/openshift-logging.yml -e openshift_logging_install_logging=true -e openshift_logging_es_pvc_size=20Gi
```
