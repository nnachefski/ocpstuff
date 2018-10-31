### # misc stuff

#### # work-around for x509 error on private registry.  
##### # add this to master-config.yaml on all masters
```
cp /etc/pki/ca-trust/source/anchors/satellite.home.nicknach.net.crt /etc/origin/master

imagePolicyConfig:
  internalRegistryHostname: satellite.home.nicknach.net:8888
    AdditionalTrustedCA=/etc/origin/master/satellite.home.nicknach.net.crt
```
##### # then do this on a master (to patch the registry config)
```
oc patch dc docker-registry -p '{"spec":{"template":{"spec":{"containers":[{"name":"registry","volumeMounts":[{"mountPath":"/etc/pki","name":"certs"}]}],"volumes":[{"hostPath":{"path":"/etc/pki","type":"Directory"},"name":"certs"}]}}}}' -n default

oc adm policy add-scc-to-user hostaccess -z registry -n default
```
##### # now do this on each infra node to fix SELinux
```
chcon -R -t container_file_t  /etc/pki
```

##### # attach(patch) a hostMount to a DC
```
oc patch dc pydemo -p '{"spec":{"template":{"spec":{"containers":[{"name":"pydemo","volumeMounts":[{"mountPath":"/mnt/test","name":"data"}]}],"volumes":[{"hostPath":{"path":"/mnt/test","type":"Directory"},"name":"data"}]}}}}'

oc adm policy add-scc-to-user hostaccess -z default

ansible "node0*" -m shell -a "chcon -R unconfined_u:object_r:svirt_sandbox_file_t:s0 /mnt/test"
```
##### # wipe CNS/OCS
```
rm -fr /var/lib/heketi /etc/glusterfs /var/lib/glusterd; wipefs --all /dev/vdb -f
```
##### # pin project pods to a specific nodeselector
```
oc patch ns glusterfs -p '{"metadata": {"annotations": {"openshift.io/node-selector": "node-role.kubernetes.io/infra=true"}}}'
```
##### # start a build from a local dir
```
oc start-build jupyterhub-nb-tfg --from-dir .
```
##### # add post hook 
```
oc set deployment-hook dc/tensorflow --post -- /bin/sh -c 'curl http://repo.home.nicknach.net/repo/foo.ipynb -o /notebooks/foo.ipynb'
```
##### # re-import all ISs from cli
```
for i in `oc get is -n openshift |awk '{print $1}'`; do oc import-image $i -n openshift --all; done
```
##### # add system and repo certs to docker-registry pod
```
oc create configmap mycert --from-file=repo.cert=/etc/pki/ca-trust/source/anchors/repo.home.nicknach.net.cert -n default

oc create configmap systemcert --from-file=cert.pem=/etc/pki/tls/cert.pem -n default

oc patch dc docker-registry -p '{"spec":{"template":{"spec":{"containers":[{"name":"registry","volumeMounts":[{"mountPath":"/etc/pki/tls","name":"certs"},{"mountPath":"/etc/pki/ca-trust/source/anchors","name":"repocert"}]}],"volumes":[{"configMap":{"defaultMode":420,"name":"systemcert"},"name":"certs"},{"configMap":{"defaultMode":420,"name":"mycert"},"name":"repocert"}]}}}}' -n default
```
##### # add just /etc/pki to docker-registry
```
oc create configmap systemcert --from-file=cert.pem=/etc/pki/tls/cert.pem -n default

oc patch dc docker-registry -p ''
```
##### # work-around host mount the entire /etc/pki dir
```
oc patch dc docker-registry -p '{"spec":{"template":{"spec":{"containers":[{"name":"registry","volumeMounts":[{"mountPath":"/etc/pki","name":"certs"}]}],"volumes":[{"hostPath":{"path":"/etc/pki","type":"Directory"},"name":"certs"}]}}}}' -n default

oc adm policy add-scc-to-user hostaccess -z registry -n default

ansible "infra*" -a "sed -i 's/=enforcing/=permissive/' /etc/sysconfig/selinux"

ansible "infra*" -a "setenforce 0" 

```
##### # change node role
```
oc label node --selector=region=infra node-role.kubernetes.io/infra=true
```
##### # login to master box (if you somehow lose your .kube folder)
```
export KUBECONFIG=/etc/origin/master/admin.kubeconfig
oc login -u system:admin
```
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

##### # do this to get a complete list of missing images/tags in your ISs
```
for i in `oc get is -n openshift |awk '{print $1}'`; do oc get is $i -n openshift -o json; done |grep 'not found' |awk '{print $3}' |awk -F \/ '{print $2,$3}' | awk -F \: '{print $1}' |sed 's/ /\//g' |sort -u
```

##### # nasty docker-registry DC patch
```
oc patch dc docker-registry -p '{"spec":{"template":{"spec":{"containers":[{"name":"registry","volumeMounts":[{"mountPath":"/etc/pki","name":"certs"}]}],"volumes":[{"hostPath":{"path":"/etc/pki","type":"Directory"},"name":"certs"}]}}}}'
```

##### # allow hostmounts
```
oc adm policy add-scc-to-user hostaccess -z registry
``` 

To un-install logging, do this:
ansible-playbook /usr/share/ansible/openshift-ansible/playbooks/byo/openshift-cluster/openshift-logging.yml -e openshift_logging_install_logging=False

Then to re-install, do this:
ansible-playbook /usr/share/ansible/openshift-ansible/playbooks/byo/openshift-cluster/openshift-logging.yml -e openshift_logging_install_logging=True -e openshift_logging_es_pvc_storage_class_name=glusterfs-storage-block -e openshift_logging_es_pvc_dynamic=true openshift_logging_es_memory_limit=4G -e openshift_logging_es_pvc_size=10Gi

To un-install metrics, do this:
ansible-playbook /usr/share/ansible/openshift-ansible/playbooks/byo/openshift-cluster/openshift-metrics.yml -e openshift_metrics_install_metrics=False

To re-deploy metrics, do this:
ansible-playbook /usr/share/ansible/openshift-ansible/playbooks/byo/openshift-cluster/openshift-metrics.yml -e openshift_metrics_install_metrics=True -e openshift_metrics_cassandra_pvc_storage_class_name=glusterfs-storage-block -e openshift_metrics_cassandra_storage_type=dynamic -e openshift_metrics_cassandra_pvc_size=10Gi 
