export ANSIBLE_HOST_KEY_CHECKING=False
cd /root
echo "starting OCP install" && sleep 60
git clone https://github.com/openshift/openshift-ansible.git --branch release-3.11
sed -i 's/#log_path/log_path/' /etc/ansible/ansible.cfg
ansible-playbook openshift-ansible/playbooks/prerequisites.yml || exit 1
ansible-playbook openshift-ansible/playbooks/deploy_cluster.yml || exit 1
#ansible-playbook /usr/share/ansible/openshift-ansible/playbooks/prerequisites.yml 
#ansible-playbook /usr/share/ansible/openshift-ansible/playbooks/deploy_cluster.yml 
wget https://raw.githubusercontent.com/nnachefski/ocpstuff/master/rbac/ocp_group_sync.conf -O /etc/origin/master/ocp_group_sync.conf
wget https://raw.githubusercontent.com/nnachefski/ocpstuff/master/rbac/ocp_group_sync-whitelist.conf -O /etc/origin/master/ocp_group_sync-whitelist.conf 
oc adm groups sync --sync-config=/etc/origin/master/ocp_group_sync.conf --confirm --whitelist=/etc/origin/master/ocp_group_sync-whitelist.conf
oc adm policy add-cluster-role-to-group cluster-admin admins
oc adm policy add-role-to-group basic-user authenticated
oc adm policy add-cluster-role-to-user cluster-reader readonly
oc patch dc docker-registry -p '{"spec":{"template":{"spec":{"containers":[{"name":"registry","volumeMounts":[{"mountPath":"/etc/pki","name":"certs"}]}],"volumes":[{"hostPath":{"path":"/etc/pki","type":"Directory"},"name":"certs"}]}}}}' -n default
oc adm policy add-scc-to-user hostaccess -z registry -n default
oc get cm node-config-all-in-one -n openshift-node -o yaml |sed '/RotateKubeletClientCertificate/ s/$/,DevicePlugins=true/' > node-config.patch
oc replace cm node-config-all-in-one -f node-config.patch -n openshift-node

cat <<EOF > post.sh
cp /etc/origin/node/pods/apiserver.yaml apiserver.yaml.prepatch
oc ex config patch apiserver.yaml.prepatch -p '{"spec":{"containers":[{"name":"api","volumeMounts":[{"mountPath":"/etc/pki","name":"certs"}]}],"volumes":[{"hostPath":{"path":"/etc/pki","type":"Directory"},"name":"certs"}]}}' > /etc/origin/node/pods/apiserver.yaml 
wget https://raw.githubusercontent.com/Maistra/openshift-ansible/maistra-0.6/istio/master-config.patch
cp -p /etc/origin/master/master-config.yaml master-config.yaml.prepatch
oc ex config patch master-config.yaml.prepatch -p "$(cat master-config.patch)" > /etc/origin/master/master-config.yaml
/usr/local/bin/master-restart api && /usr/local/bin/master-restart controllers
echo 'vm.max_map_count = 262144' > /etc/sysctl.d/99-elasticsearch.conf
chcon -R -t container_file_t  /dev/nvidia*
restorecon -R /dev/nvidia*
setenforce 0 && sed -i 's/=enforcing/=permissive/' /etc/selinux/config
EOF

chmod +x post.sh
ansible "*" -m script -a "post.sh"

