cd /root
export ANSIBLE_HOST_KEY_CHECKING=False
echo "starting OCP install" && sleep 60
sed -i 's/#log_path/log_path/' /etc/ansible/ansible.cfg
#git clone https://github.com/openshift/openshift-ansible.git --branch release-3.11
curl https://raw.githubusercontent.com/openshift/openshift-ansible/master/roles/openshift_storage_glusterfs/files/glusterfs-template.yml > /usr/share/ansible/openshift-ansible/roles/openshift_storage_glusterfs/files/glusterfs-template.yml
ansible-playbook openshift-ansible/playbooks/prerequisites.yml || exit 1
ansible-playbook openshift-ansible/playbooks/deploy_cluster.yml || exit 1
#ansible-playbook /usr/share/ansible/openshift-ansible/playbooks/prerequisites.yml  || exit 1
#ansible-playbook /usr/share/ansible/openshift-ansible/playbooks/deploy_cluster.yml || exit 1
curl https://raw.githubusercontent.com/nnachefski/ocpstuff/master/rbac/ocp_group_sync.conf > /etc/origin/master/ocp_group_sync.conf
curl https://raw.githubusercontent.com/nnachefski/ocpstuff/master/rbac/ocp_group_sync-whitelist.conf > /etc/origin/master/ocp_group_sync-whitelist.conf 
oc adm groups sync --sync-config=/etc/origin/master/ocp_group_sync.conf --confirm --whitelist=/etc/origin/master/ocp_group_sync-whitelist.conf
oc adm policy add-cluster-role-to-group cluster-admin admins
oc adm policy add-role-to-group basic-user authenticated
oc adm policy add-cluster-role-to-user cluster-reader readonly
oc patch dc docker-registry -p '{"spec":{"template":{"spec":{"containers":[{"name":"registry","volumeMounts":[{"mountPath":"/etc/pki","name":"certs"}]}],"volumes":[{"hostPath":{"path":"/etc/pki","type":"Directory"},"name":"certs"}]}}}}' -n default
sleep 60
oc adm policy add-scc-to-user hostaccess -z registry -n default
oc get cm node-config-all-in-one -n openshift-node -o yaml |sed '/RotateKubeletClientCertificate/ s/$/,DevicePlugins=true/' > node-config.patch
oc replace cm node-config-all-in-one -f node-config.patch -n openshift-node 
sleep 60

curl https://raw.githubusercontent.com/nnachefski/ocpstuff/master/satellite/firstboot/post-install.sh > post-install.sh && chmod +x post-install.sh
ansible "*" -m script -a "post-install.sh"
echo "############ RETURN '$?'"
sleep 60

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
oc new-project istio-test
oc adm policy add-scc-to-user anyuid -z default
oc adm policy add-scc-to-user privileged -z default
oc label namespace istio-system istio-injection=enabled
oc label namespace istio-test istio-injection=enabled
#oc get namespace -L istio-injection
curl https://raw.githubusercontent.com/istio/istio/master/samples/bookinfo/platform/kube/bookinfo.yaml > bookinfo.yaml
oc create -f bookinfo.yaml
oc expose svc productpage
# deploy etherminers
oc new-project crypto
oc adm policy add-scc-to-user anyuid -z default
oc new-app https://github.com/nnachefski/ocpstuff.git --context-dir=crypto/ethminer --name=ethminer -e NVIDIA_VISIBLE_DEVICES=all -e NVIDIA_DRIVER_CAPABILITIES="compute,utility" -e NVIDIA_REQUIRE_CUDA="cuda>=9.1" -e APP_VER="0.14.0"
oc new-project foo
oc new-app https://raw.githubusercontent.com/nnachefski/pydemo/master/openshift/templates/pydemo-postgresql.yaml --name=pydemo

echo `date` > /root/finished.txt
