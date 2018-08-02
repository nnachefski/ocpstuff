# # This way is old way.  Use the new devices plugin for nvidia 
### # This repo's content is for building and deploying CUDA/GPU-enabled ML images on Openshift.
##### # This example uses Tensorflow and Jupyter
###### # this image requires the rhel7-cuda image to be available 
##### # join a bare-metal node (w/ an NVIDIA GPU) to your 3.6+ cluster and label that node appropriately:
```
oc label node desktop.home.nicknach.net alpha.kubernetes.io/nvidia-gpu-name='GTX' --overwrite
```
###### # dont forget to enable the Features Gate for Accelerators in the node-config.yml on this node  
###### # change 'desktop.home.nicknach.net' to your node name
###### # change 'GTX' to whatever you want (this is a node label)
##### # create the project
```
oc new-project tensorflow
```
##### # set anyuid for the default serviceaccount
```
oc adm policy add-scc-to-user anyuid -z default
```
##### # now build/deploy the ML framework
```
oc new-app https://github.com/nnachefski/ocpstuff.git --context-dir=ml/tensorflow_custom --name=jupyter
```
##### # expose the jupyter UI port
```
oc expose svc jupyter --port 8888
```
##### # then patch the dc to set resource limits and nodeaffinity
```
#oc patch dc jupyter -p '{"spec":{"template":{"spec":{"affinity":{"nodeAffinity":{"requiredDuringSchedulingIgnoredDuringExecution":{"nodeSelectorTerms":[{"matchExpressions":[{"key":"alpha.kubernetes.io/nvidia-gpu-name","operator":"In","values":["GTX"]}]}]}}},"containers":[{"name":"jupyter","resources":{"limits":{"alpha.kubernetes.io/nvidia-gpu":"1"}}}]}}}}'
```
###### # change 'GTX' to match above node label
###### # change 'jupyter' to match above --name (in both dc and container name)

##### # now run the mnist notebook and see that it scheduled on the GPU 
###### # use nvidia-smi on the bare-metal node
