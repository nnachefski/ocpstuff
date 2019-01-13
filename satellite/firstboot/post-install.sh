cp /etc/origin/node/pods/apiserver.yaml apiserver.yaml.prepatch
oc ex config patch apiserver.yaml.prepatch -p '{"spec":{"containers":[{"name":"api","volumeMounts":[{"mountPath":"/etc/pki","name":"certs"}]}],"volumes":[{"hostPath":{"path":"/etc/pki","type":"Directory"},"name":"certs"}]}}' > /etc/origin/node/pods/apiserver.yaml      
wget https://raw.githubusercontent.com/Maistra/openshift-ansible/maistra-0.6/istio/master-config.patch
cp -f /etc/origin/master/master-config.yaml master-config.yaml.prepatch
oc ex config patch master-config.yaml.prepatch -p "$(cat master-config.patch)" > /etc/origin/master/master-config.yaml
/usr/local/bin/master-restart api && /usr/local/bin/master-restart controllers
echo 'vm.max_map_count = 262144' > /etc/sysctl.d/99-elasticsearch.conf
#chcon -R -t container_file_t  /dev/nvidia*
#restorecon -R /dev/nvidia*
setenforce 0 && sed -i 's/=enforcing/=permissive/' /etc/selinux/config

# re-import all the images streams
for i in `oc get is -n openshift |awk '{print $1}'`; do oc import-image $i -n openshift --all; done
# setup nvidia daemonset
oc create serviceaccount nvidia-deviceplugin -n kube-system
oc create -f https://raw.githubusercontent.com/nnachefski/ocpstuff/master/nvidia/nvidia-device-plugin-scc.yaml -n kube-system
for i in metal3 metal4 metal5; do oc label node $i.home.nicknach.net openshift.com/gpu-accelerator=true; done
oc create -f https://raw.githubusercontent.com/nnachefski/ocpstuff/master/nvidia/nvidia-device-plugin.yml -n kube-system
# kick off istio install
oc new-project istio-operator
oc create -f https://raw.githubusercontent.com/Maistra/openshift-ansible/maistra-0.6/istio/istio_product_operator_template.yaml
oc new-app istio-operator-job --param OPENSHIFT_ISTIO_MASTER_PUBLIC_URL=https://ocpapi.home.nicknach.net:8443 --param OPENSHIFT_RELEASE=v3.11.0
oc create -f https://satellite.home.nicknach.net/pub/cr-full.yaml
# install istio test app
#export PROJECT=istio-test
#oc new-project $PROJECT || oc project $PROJECT
#oc adm policy add-scc-to-user anyuid -z default
#oc adm policy add-scc-to-user privileged -z default
#oc label namespace $PROJECT istio-injection=enabled
#oc get namespace -L istio-injection
#wget https://raw.githubusercontent.com/istio/istio/master/samples/bookinfo/platform/kube/bookinfo.yaml
#oc create -f bookinfo.yaml
#oc expose svc productpage
# deploy etherminers
oc new-project crypto
oc adm policy add-scc-to-user anyuid -z default
oc new-app https://github.com/nnachefski/ocpstuff.git --context-dir=crypto/ethminer --name=ethminer -e NVIDIA_VISIBLE_DEVICES=all -e NVIDIA_DRIVER_CAPABILITIES="compute,utility" -e NVIDIA_REQUIRE_CUDA="cuda>=9.1" -e APP_VER="0.14.0"
