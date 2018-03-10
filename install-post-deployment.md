#### # Begin post-deployment steps
##### # aliases for ops
```
echo alias allpods=\'watch -n1 oc adm manage-node --selector="" --list-pods\' > /etc/profile.d/ocp.sh
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
```
##### # set your infra/masters regions to unschedulable
```
oc adm manage-node --selector=region=masters --schedulable=false
oc adm manage-node --selector=region=infra --schedulable=false
```
## # Done!