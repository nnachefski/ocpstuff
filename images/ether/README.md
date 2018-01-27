### # This image is for building and deploying CUDA/GPU-enabled Ethereum miner on Openshift.
##### # build the rhel7-cuda base image first
```
oc new-build https://github.com/nnachefski/ocpstuff.git --context-dir=images/rhel7-cuda --name=rhel7-cuda -n openshift
```
##### # create the project
```
oc new-project ether-on-ocp
```
##### # set anyuid for the default serviceaccount
```
oc adm policy add-scc-to-user anyuid -z default
```
##### # now build/deploy ethminer
```
oc new-app https://github.com/nnachefski/ocpstuff.git --context-dir=images/ether --name=ethminer
```
##### # expose the service
```
oc expose svc ether --port 1234
```
##### # then patch the dc to set resource limits and nodeaffinity
```
oc patch dc ethminer -p '{"spec":{"template":{"spec":{"affinity":{"nodeAffinity":{"requiredDuringSchedulingIgnoredDuringExecution":{"nodeSelectorTerms":[{"matchExpressions":[{"key":"alpha.kubernetes.io/nvidia-gpu-name","operator":"In","values":["GTX"]}]}]}}},"containers":[{"name":"ethminer","resources":{"limits":{"alpha.kubernetes.io/nvidia-gpu":"1"}}}]}}}}'
```
###### # change GTX to match node label for your NVIDIA box   
###### # change 'ethminer' to match above --name (in both dc and container name)
