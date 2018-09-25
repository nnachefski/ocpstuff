#### # on the master
##### # grab the files
```
cd ~
wget https://raw.githubusercontent.com/openshift-istio/openshift-ansible/istio-3.10-1.0.0-snapshot.2/istio/istio_installer_template.yaml
wget https://raw.githubusercontent.com/openshift-istio/openshift-ansible/istio-3.10-1.0.0-snapshot.2/istio/master-config.patch
wget https://raw.githubusercontent.com/openshift-istio/openshift-ansible/istio-3.10-1.0.0-snapshot.2/istio/istio_removal_template.yaml
```
##### # patch the master-config
```
cp -p /etc/origin/master/master-config.yaml /etc/origin/master/master-config.yaml.prepatch
oc ex config patch /etc/origin/master/master-config.yaml.prepatch -p "$(cat ~/master-config.patch)" > /etc/origin/master/master-config.yaml
```
##### # restart the master services
```
systemctl restart atomic-openshift-master*
```
#### # use ansible to set elasticsearch vars on all nodes
```
ansible "*" -m shell -a "echo 'vm.max_map_count = 262144' > /etc/sysctl.d/99-elasticsearch.conf"
ansible "*" -m shell -a "sysctl vm.max_map_count=262144"
```
###### # use --private-key= if you are on AWS
##### # deploy the istio
```
oc new-project istio-system
oc create sa openshift-ansible
oc adm policy add-scc-to-user privileged -z openshift-ansible
oc adm policy add-cluster-role-to-user cluster-admin -z openshift-ansible
oc new-app istio_installer_template.yaml --param=OPENSHIFT_ISTIO_MASTER_PUBLIC_URL=console.openshiftdemo.com --param=OPENSHIFT_ISTIO_KIALI_USERNAME=ocpadmin --param=OPENSHIFT_ISTIO_KIALI_PASSWORD=welcome1
```
##### # create a project
```
cd ~
oc new-project testing
```
##### # add priv SCC (temp)
```
oc adm policy add-scc-to-user anyuid -z default
oc adm policy add-scc-to-user privileged -z default
```
##### # label the openshift namespace 
```
oc label namespace testing istio-injection=enabled
oc get namespace -L istio-injection
```
##### # create the sample app
```
wget https://raw.githubusercontent.com/istio/istio/master/samples/bookinfo/platform/kube/bookinfo.yaml
oc create -f bookinfo.yaml
oc expose svc productpage
```
##### # or, if you need to manually inject the sidecar, do this
```
oc apply -f <(istioctl kube-inject -f ~/bookinfo.yaml)
```
