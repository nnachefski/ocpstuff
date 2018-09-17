#### # on the master(s)
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
#### # now on the control/bastion host
```
ansible --private-key=.ssh/nicknach-ca.pem "*" -m shell -a "echo 'vm.max_map_count = 262144' > /etc/sysctl.d/99-elasticsearch.conf"
ansible --private-key=.ssh/nicknach-ca.pem "*" -m shell -a "sysctl vm.max_map_count=262144"
```
##### # label the openshift namespace 
```
oc label namespace openshift istio-injection=enabled
```
##### # create the sample app
```
oc create -f https://raw.githubusercontent.com/istio/istio/master/samples/bookinfo/platform/kube/bookinfo.yaml
```
