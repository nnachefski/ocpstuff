####  # NVIDIA GPU containers running on Openshift (OCP) 3.10
###### # from: https://blog.openshift.com/how-to-use-gpus-with-deviceplugin-in-openshift-3-10/ 
 
###### # RHEL 7.5
###### # run the following from your bare-metal GPU host
##### # start by installing the kernel-devel package for your running kernel
```
yum -y install kernel-devel-`uname -r`
```
##### # and enabling epel
```
rpm -ivh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
```
##### # setup the nvidia rhel repo 
```
rpm -ivh https://developer.download.nvidia.com/compute/cuda/repos/rhel7/x86_64/cuda-repo-rhel7-9.1.85-1.x86_64.rpm 
```
##### # install your nvidia drivers (this should blacklist nouveau)
```
yum -y install nvidia-driver
```
###### # reboot now
##### # after reboot, install cuda
```
yum -y install cuda-9-1
```
##### # after reboot, do this to ensure your nvidia drivers have bee properly installed
```
nvidia-smi --query-gpu=gpu_name --format=csv,noheader --id=0 | sed -e 's/ /-/g'
```
###### # you should see the model of your GPU as the output
##### # now add the nvidia-container-runtime-hook repo
```
curl -s -L https://nvidia.github.io/nvidia-container-runtime/centos7/x86_64/nvidia-container-runtime.repo | tee /etc/yum.repos.d/nvidia-container-runtime.repo
```
##### # now install the runtime hook package
```
yum -y install nvidia-container-runtime-hook
```
##### # add the hook to docker and make it exec
```
cat <<EOF > /usr/libexec/oci/hooks.d/oci-nvidia-hook
#!/bin/bash
/usr/bin/nvidia-container-runtime-hook \$@
EOF

chmod +x /usr/libexec/oci/hooks.d/oci-nvidia-hook
```
##### # add the SELinux context
```
chcon -t container_file_t  /dev/nvidia*
```
##### # run the vector-add GPU test in docker
```
docker run --privileged -it --rm docker.io/mirrorgooglecontainers/cuda-vector-add:v0.1
```
###### # you should see "Test PASSED"
##### # now change this node's bootstrap profile to one that we will create in the next phase
```
sed -i 's/BOOTSTRAP_CONFIG_NAME=node-config-compute/BOOTSTRAP_CONFIG_NAME=node-config-nvidia/' /etc/sysconfig/atomic-openshift-node
systemctl restart atomic-openshift-node
```
#### ################################### using 'oc' from the master now
##### # create a ServiceAccount
```
oc create serviceaccount nvidia-deviceplugin -n kube-system
```
##### # now add privledged nvidia scc (use file from this repo to avoid copy/paste formatting errors)
```
oc create -f https://raw.githubusercontent.com/nnachefski/ocpstuff/master/nvidia/nvidia-device-plugin-scc.yaml -n kube-system
```
##### # Now the fun part, getting feature-gates enable in OCP 3.10.
##### # Openshift 3.10 now bootstraps node configs from etcd.  This is done by storing node configs (grouped by 'roles') as ConfigMaps in the 'openshift-node' project.  Each node has a 'sync' pod running as a DaemonSet.  These sync pods keep your node config ConfigMaps pushed to the nodes.
###### # run from an 'oc' enabled (system:admin) shell (from the master).
##### # create a new node sync ConfigMap by using the file from this repo
```
oc create -f https://raw.githubusercontent.com/nnachefski/ocpstuff/master/nvidia/node-config-nvidia.yml -n openshift-node 
```
###### # this will create a new ConfigMap called 'node-config-nvidia'
###### # i created this new config map by cloning the standard 'compute' CM and changing a few things 
##### # label your GPU node
###### # swap out my node name for yours
```
oc label node metal.home.nicknach.net openshift.com/gpu-accelerator=true
```
##### # next, deploy the nvidia device plugin DaemonSet to the 'kube-system' project
```
oc create -f https://raw.githubusercontent.com/nnachefski/ocpstuff/master/nvidia/nvidia-device-plugin.yml -n kube-system
```
###### # for the upstream file, https://raw.githubusercontent.com/NVIDIA/k8s-device-plugin/v1.11/nvidia-device-plugin.yml
#### # now let's use that GPU-enabled container host.  Here are some more interesting workloads...
##### # Tensorflow
https://github.com/nnachefski/ocpstuff/tree/master/ml/tensorflow
##### # Ethminer
https://github.com/nnachefski/ocpstuff/tree/master/crypto/ethminer
 