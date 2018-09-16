wget https://raw.githubusercontent.com/openshift-istio/openshift-ansible/istio-3.10-1.0.0-snapshot.2/istio/istio_installer_template.yaml
wget https://raw.githubusercontent.com/openshift-istio/openshift-ansible/istio-3.10-1.0.0-snapshot.2/istio/master-config.patch
wget https://raw.githubusercontent.com/openshift-istio/openshift-ansible/istio-3.10-1.0.0-snapshot.2/istio/istio_removal_template.yaml
cp -p /etc/origin/master/master-config.yaml /etc/origin/master/master-config.yaml.prepatch
oc ex config patch /etc/origin/master/master-config.yaml.prepatch -p "$(cat /etc/origin/master/master-config.patch)" > /etc/origin/master/master-config.yaml
systemctl restart atomic-openshift-master*
