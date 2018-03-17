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
htpasswd -b /etc/origin/master/htpasswd ocpadmin welcome1
oc adm policy add-cluster-role-to-user cluster-admin ocpadmin
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
##### # make the  storageClass the default
```
oc patch storageclass fs-storage -p '{"metadata": {"annotations": {"storageclass.kubernetes.io/is-default-class": "true"}}}'
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
```
oc volume dc docker-registry  --add --overwrite -t persistentVolumeClaim  --claim-name=registry-volume-claim --name=registry-storage
```
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
##### # disable logging
```
ansible-playbook /usr/share/ansible/openshift-ansible/playbooks/byo/openshift-cluster/openshift-logging.yml -e openshift_logging_install_logging=false
```

## do this to get a complete list of missing images/tags in your ISs
for i in `oc get is -n openshift |awk '{print $1}'`; do oc get is $i -n openshift -o json; done |grep 'not found' |awk '{print $3}' |awk -F \/ '{print $2,$3}' | awk -F \: '{print $1}'
