#### # Begin post-deployment steps
##### # aliases for ops
```
echo alias allpods=\'watch -n1 oc adm manage-node --selector="" --list-pods\' > /etc/profile.d/ocp.sh
echo alias allpodsp=\'watch -n1 oc adm manage-node --selector="region=primary" --list-pods\' >> /etc/profile.d/ocp.sh
chmod +x /etc/profile.d/ocp.sh
```
##### # pin all the metrics pods to the infra nodes
```
oc patch ns openshift-infra -p '{"metadata": {"annotations": {"openshift.io/node-selector": "region=infra"}}}'
```
##### # set gluster to be the default storageclass
```
oc annotate storageclass glusterfs-storage storageclass.beta.kubernetes.io/is-default-class="true"
```
##### # setup group sync and run it once
```
wget https://raw.githubusercontent.com/nnachefski/ocpstuff/master/ocp_group_sync.conf -O /etc/origin/master/ocp_group_sync.conf
wget https://raw.githubusercontent.com/nnachefski/ocpstuff/master/ocp_group_sync-whitelist.conf -O /etc/origin/master/ocp_group_sync-whitelist.conf 
oc adm groups sync --sync-config=/etc/origin/master/ocp_group_sync.conf --confirm --whitelist=/etc/origin/master/ocp_group_sync-whitelist.conf
```
##### # setup a cronjob on ansible host to sync groups nightly
```
#echo 'oc adm groups sync --sync-config=/etc/origin/master/ocp_group_sync.conf --confirm --whitelist=/etc/origin/master/ocp_group_sync-whitelist.conf' > /etc/cron.daily/ocp-group-sync.sh && chmod +x /etc/cron.daily/ocp-group-sync.sh 
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