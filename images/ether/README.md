### # This image is for building and deploying CUDA/GPU-enabled Ethereum miners on Openshift.
# # This is the old way.  Dont build ethminer this way if using 3.10+
###### # this image requires the rhel7-cuda image to be available
##### # create the project
```
oc new-project ether
```
##### # build/deploy ethminer
```
oc new-app https://github.com/nnachefski/ocpstuff.git --context-dir=images/ether --name=ethminer
```
##### # then patch the dc to set resource limits and nodeaffinity
```
oc patch dc ethminer -p '{"spec":{"template":{"spec":{"affinity":{"nodeAffinity":{"requiredDuringSchedulingIgnoredDuringExecution":{"nodeSelectorTerms":[{"matchExpressions":[{"key":"alpha.kubernetes.io/nvidia-gpu-name","operator":"In","values":["GTX"]}]}]}}},"containers":[{"name":"ethminer","resources":{"limits":{"alpha.kubernetes.io/nvidia-gpu":"1"}}}]}}}}'
```
###### # change GTX to match node label for your NVIDIA box   
###### # change 'ethminer' to match above --name (in both dc and container name)
