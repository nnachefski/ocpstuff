#### # Begin post-deployment steps
##### # aliases for ops
```
echo alias allpods=\'watch -n2 oc get pods -owide --all-namespaces\' > /etc/profile.d/ocp.sh
echo alias allpodsp=\'watch -n1 oc adm manage-node --selector="region=primary" --list-pods\' >> /etc/profile.d/ocp.sh
chmod +x /etc/profile.d/ocp.sh
```
##### # setup group sync and run it once
```
wget https://raw.githubusercontent.com/nnachefski/ocpstuff/master/ocp_group_sync.conf -O /etc/origin/master/ocp_group_sync.conf
wget https://raw.githubusercontent.com/nnachefski/ocpstuff/master/ocp_group_sync-whitelist.conf -O /etc/origin/master/ocp_group_sync-whitelist.conf 
oc adm groups sync --sync-config=/etc/origin/master/ocp_group_sync.conf --confirm --whitelist=/etc/origin/master/ocp_group_sync-whitelist.conf
```
##### # set policies (perms) on your sync’ed groups
```
oc adm policy add-cluster-role-to-group cluster-admin admins
oc adm policy add-role-to-group basic-user authenticated
oc adm policy add-cluster-role-to-user cluster-reader readonly
```
##### # set your infra/masters regions to unschedulable
```
oc adm manage-node --selector=region=masters --schedulable=false
oc adm manage-node --selector=region=infra --schedulable=false
```
##### # pin your metrics and asb projects to infra nodes (if using HA mode)
```
oc patch ns openshift-infra -p '{"metadata": {"annotations": {"openshift.io/node-selector": "region=infra"}}}'
oc patch ns openshift-ansible-service-broker -p '{"metadata": {"annotations": {"openshift.io/node-selector": "region=infra"}}}'
```
##### # make CNS the default SC (optional)
```
oc patch storageclass glusterfs-storage -p '{"metadata": {"annotations": {"storageclass.kubernetes.io/is-default-class": "true"}}}'
```
##### # add infra role for infra nodes (work-around)
```
oc label node --selector=region=infra node-role.kubernetes.io/infra=true
```
## # Done!

### # Now run through the rhel7-custom image build guide
#### # https://github.com/nnachefski/ocpstuff/tree/master/images
