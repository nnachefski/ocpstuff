### # This image is for building and deploying CUDA/GPU-enabled Ethereum miners on Openshift.
##### # create the project
```
oc new-project ether
```
##### # build/deploy ethminer
```
oc new-app https://github.com/nnachefski/ocpstuff.git --context-dir=images/ether --name=ethminer
```
##### # then patch the dc to set resource limits and nodeaffinity (deprecated)
```
oc patch dc ethminer -p '{"spec":{"template":{"spec":{"affinity":{"nodeAffinity":{"requiredDuringSchedulingIgnoredDuringExecution":{"nodeSelectorTerms":[{"matchExpressions":[{"key":"alpha.kubernetes.io/nvidia-gpu-name","operator":"In","values":["GTX"]}]}]}}},"containers":[{"name":"ethminer","resources":{"limits":{"alpha.kubernetes.io/nvidia-gpu":"1"}}}]}}}}'
```
##### # new way (nvidia device plugin, OCP 3.9+)
```
oc patch dc ethminer -p '{"spec":{"template":{"spec":{"containers":[{"name":"ethminer","resources":{"limits":{"nvidia.com/gpu":1}}}]}}}}'
``` 
