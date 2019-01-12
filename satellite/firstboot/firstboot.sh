export ANSIBLE_HOST_KEY_CHECKING=False
echo "starting OCP install" && sleep 60
sed -i 's/#log_path/log_path/' /etc/ansible/ansible.cfg
#git clone https://github.com/openshift/openshift-ansible.git --branch release-3.11
#ansible-playbook openshift-ansible/playbooks/prerequisites.yml || exit 1
#ansible-playbook openshift-ansible/playbooks/deploy_cluster.yml || exit 1
ansible-playbook /usr/share/ansible/openshift-ansible/playbooks/prerequisites.yml  || exit 1
ansible-playbook /usr/share/ansible/openshift-ansible/playbooks/deploy_cluster.yml || exit 1
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

curl https://raw.githubusercontent.com/nnachefski/ocpstuff/master/satellite/firstboot/post-install.sh > post-install.sh && chmod +x post-install.sh
ansible "*" -m script -a "post.sh"

