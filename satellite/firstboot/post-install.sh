cd /root
cp /etc/origin/node/pods/apiserver.yaml apiserver.yaml.prepatch
oc ex config patch apiserver.yaml.prepatch -p '{"spec":{"containers":[{"name":"api","volumeMounts":[{"mountPath":"/etc/pki","name":"certs"}]}],"volumes":[{"hostPath":{"path":"/etc/pki","type":"Directory"},"name":"certs"}]}}' > /etc/origin/node/pods/apiserver.yaml      
curl https://raw.githubusercontent.com/Maistra/openshift-ansible/maistra-0.7/istio/master-config.patch > master-config.patch
cp -f /etc/origin/master/master-config.yaml master-config.yaml.prepatch
oc ex config patch master-config.yaml.prepatch -p "$(cat master-config.patch)" > /etc/origin/master/master-config.yaml
/usr/local/bin/master-restart api && /usr/local/bin/master-restart controllers
echo 'vm.max_map_count = 262144' > /etc/sysctl.d/99-elasticsearch.conf
dkms autoinstall
chcon -R -t container_file_t  /dev/nvidia*
restorecon -R /dev/nvidia*
setenforce 0 && sed -i 's/=enforcing/=permissive/' /etc/selinux/config
