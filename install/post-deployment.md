#### # Begin post-deployment steps

##### # if not using LDAP, you'll need to add some htpasswd users (on all masters)
```
#htpasswd -b /etc/origin/master/htpasswd ocpadmin welcome1
#ansible "master*" -a "htpasswd -b /etc/origin/master/htpasswd ocpadmin welcome1"
#oc adm policy add-cluster-role-to-user cluster-admin ocpadmin
```
##### # setup group sync and run it once (LDAP only)
```
wget https://raw.githubusercontent.com/nnachefski/ocpstuff/master/rbac/ocp_group_sync.conf -O /etc/origin/master/ocp_group_sync.conf
wget https://raw.githubusercontent.com/nnachefski/ocpstuff/master/rbac/ocp_group_sync-whitelist.conf -O /etc/origin/master/ocp_group_sync-whitelist.conf 
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
#oc adm manage-node --selector=node-role.kubernetes.io/infra=true --schedulable=false
oc adm manage-node --selector=node-role.kubernetes.io/master=true --schedulable=false
```
## # Done!

### # Now run through the rhel7-custom image build guide
#### # https://github.com/nnachefski/ocpstuff/tree/master/rhel7-custom

##### # disconnected post-install items
```
ansible "*" -m copy -a "src=/etc/origin/master/ca.crt dest=/etc/pki/ca-trust/source/anchors/ca.crt"
ansible "*" -m shell -a "update-ca-trust"
ansible "*" -m shell -a "chcon -R -t container_file_t  /etc/pki"

oc patch dc docker-registry -p '{"spec":{"template":{"spec":{"containers":[{"name":"registry","volumeMounts":[{"mountPath":"/etc/pki","name":"certs"}]}],"volumes":[{"hostPath":{"path":"/etc/pki","type":"Directory"},"name":"certs"}]}}}}' -n default
oc adm policy add-scc-to-user hostaccess -z registry -n default
```