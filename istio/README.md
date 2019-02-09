#### # on the master
```
export MAISTRA_BASE=https://raw.githubusercontent.com/Maistra/openshift-ansible/maistra-0.7
```
##### # use ansible patch the master-config on all masters
```
cat <<EOF > istio.sh
cd ~
curl $MAISTRA_BASE/istio/master-config.patch > master-config.patch
cp -p /etc/origin/master/master-config.yaml master-config.yaml.prepatch
oc ex config patch master-config.yaml.prepatch -p "$(cat master-config.patch)" > /etc/origin/master/master-config.yaml
/usr/local/bin/master-restart api && /usr/local/bin/master-restart controllers
EOF
chmod +x istio.sh
ansible "master*" -m script -a "./istio.sh"
```
#### # use ansible to set elasticsearch vars on all nodes
```
ansible "*" -m shell -a "echo 'vm.max_map_count = 262144' > /etc/sysctl.d/99-elasticsearch.conf"
ansible "*" -m shell -a "sysctl vm.max_map_count=262144"
```
###### # use --private-key= if you are on AWS
##### # deploy istio
###### # if testing puddle/beta bits, use the internal engineering docker registry 'brew-pulp-docker01.web.prod.ext.phx2.redhat.com:8888'
###### # and grab the necessary images:  https://raw.githubusercontent.com/nnachefski/ocpstuff/master/images/istio_images.txt
```
oc new-project istio-operator
oc create -f $MAISTRA_BASE/istio/istio_product_operator_template.yaml
oc new-app istio-operator-job --param OPENSHIFT_ISTIO_MASTER_PUBLIC_URL=api.ocp.nicknach.net --param OPENSHIFT_RELEASE=v3.11.0
oc create -f $MAISTRA_BASE/istio/cr-full.yaml
```
##### # to uninstall
```
oc project istio-operator
oc delete -n istio-operator installation istio-installation
oc process -n istio-operator -f $MAISTRA_BASE/istio/istio_product_operator_template.yaml | oc delete -f -
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
##### # or, to manually add the injection annotation to a deploy config
```
oc patch deploy productpage-v1 -p '{"metadata": {"annotations": {"sidecar.istio.io/inject": "true"}}}'
```
##### # to install the latest istio client
```
curl -L https://git.io/getLatestIstio | sh -
```
