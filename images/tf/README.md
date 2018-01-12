#### # This repo's content is for building and deploying CUDA/GPU-enabled ML images on Openshift.
##### # This example uses Tensorflow and Jupyter

##### # You must first build the base image (which adds the cuda layer)
```
oc new-build https://github.com/nnachefski/ocpstuff.git --context-dir=images/rhel7-cuda --strategy=docker --name=rhel7-cuda -i rhel7-custom -n openshift
```
##### # join a bare-metal node (w/ an NVIDIA GPU) to your 3.6+ cluster and label that node appropriately:
```
oc label node bc1.home.nicknach.net alpha.kubernetes.io/nvidia-gpu-name='GTX' --overwrite
```
###### # dont forget to enable the Features Gate for Accelerators in the node-config.yml for this node  
###### # change GTX to whatever you want
##### # create the project
```
oc new-project ml-on-ocp
```
##### # set anyuid for the default serviceaccount
```
oc adm policy add-scc-to-user anyuid -z default
```
##### # now build/deploy the ML framework
```
oc new-app https://github.com/nnachefski/ocpstuff.git --context-dir=images/tf --name=jupyter
```
##### # expose the jupyter UI port
```
oc expose svc jupyter --port 8888
```
##### # then patch the dc to set resource limits and nodeaffinity
```
oc patch dc jupyter -p '{"spec":{"template":{"spec":{"affinity":{"nodeAffinity":{"requiredDuringSchedulingIgnoredDuringExecution":{"nodeSelectorTerms":[{"matchExpressions":[{"key":"alpha.kubernetes.io/nvidia-gpu-name","operator":"In","values":["GTX"]}]}]}}},"containers":[{"name":"jupyter","resources":{"limits":{"alpha.kubernetes.io/nvidia-gpu":"1"}}}]}}}}'
```
###### # change GTX to match above
###### # change 'jupyter' to match above --name (in both dc and container names)

##### # now run the mnist notebook and see that it scheduled on the GPU 
###### # use nvidia-smi on the bare-metal node
