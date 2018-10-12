#### # on the master

##### # patch the master-config (do this on all masters)
```
cd ~
wget https://raw.githubusercontent.com/openshift-istio/openshift-ansible/istio-3.10-1.0.0-snapshot.2/istio/master-config.patch
cp -p /etc/origin/master/master-config.yaml /etc/origin/master/master-config.yaml.prepatch
oc ex config patch /etc/origin/master/master-config.yaml.prepatch -p "$(cat ~/master-config.patch)" > /etc/origin/master/master-config.yaml
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
wget 
oc new-project istio-operator
wget https://raw.githubusercontent.com/Maistra/openshift-ansible/maistra-0.1.0-ocp-3.1.0-istio-1.0.0/istio/istio_product_operator_template.yaml
oc new-app -f istio_product_operator_template.yaml --param OPENSHIFT_ISTIO_MASTER_PUBLIC_URL=api.ocp.nicknach.net --param OPENSHIFT_RELEASE=v3.11.0
oc create -f https://raw.githubusercontent.com/nnachefski/ocpstuff/master/istio/istio-crd.yaml
```
##### # to uninstall
```
oc delete -n istio-operator installation istio-installation
oc process -n istio-operator -f istio_product_operator_template.yaml | oc delete -f -
oc delete project istio-operator
oc delete project istio-system 
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
