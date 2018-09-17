#### # on the master
##### # grab the files
```
wget https://raw.githubusercontent.com/openshift-istio/openshift-ansible/istio-3.10-1.0.0-snapshot.2/istio/istio_installer_template.yaml
wget https://raw.githubusercontent.com/openshift-istio/openshift-ansible/istio-3.10-1.0.0-snapshot.2/istio/master-config.patch
wget https://raw.githubusercontent.com/openshift-istio/openshift-ansible/istio-3.10-1.0.0-snapshot.2/istio/istio_removal_template.yaml
```
##### # patch the master-config
```
cp -p /etc/origin/master/master-config.yaml /etc/origin/master/master-config.yaml.prepatch
oc ex config patch /etc/origin/master/master-config.yaml.prepatch -p "$(cat /etc/origin/master/master-config.patch)" > /etc/origin/master/master-config.yaml
```
##### # restart the master services
```
systemctl restart atomic-openshift-master*
```
#### # use ansible to set elasticsearch vars on all nodes
```
ansible --private-key=.ssh/nicknach-ca.pem "*" -m shell -a "echo 'vm.max_map_count = 262144' > /etc/sysctl.d/99-elasticsearch.conf"
ansible --private-key=.ssh/nicknach-ca.pem "*" -m shell -a "sysctl vm.max_map_count=262144"
```
##### # create a project
```
oc new-project testing
```
##### # add priv SCC (temp)
```
oc adm policy add-scc-to-user anyuid -z default
oc adm policy add-scc-to-user privileged -z default
```
##### # label the openshift namespace 
```
oc label namespace -n testing istio-injection=enabled
oc get namespace -L istio-injection
```
##### # create the sample app
```
oc create -f https://raw.githubusercontent.com/istio/istio/master/samples/bookinfo/platform/kube/bookinfo.yaml
```
