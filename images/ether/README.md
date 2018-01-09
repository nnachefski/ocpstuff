## This repo's content is for building and deploying CUDA/GPU-enabled Ethereum components on Openshift.
### You must first build the base image (which adds the cuda layer)

0.  make sure to build the rhel7-cuda base image first
    > oc new-build https://github.com/nnachefski/rhel7-cuda.git --name=rhel7-cuda -n openshift

1.  create the project:
	> oc new-project ether-on-ocp

2.  set anyuid for the default serviceaccount:
	> oc adm policy add-scc-to-user anyuid -z default

4.  now build/deploy ethminer
	> oc new-app https://github.com/nnachefski/ether-on-ocp.git --name=ethminer
	
5.  expose the service
	> oc expose svc ether --port 1234

6.  then patch the dc to set resource limits and nodeaffinity 
	> oc patch dc ethminer -p '{"spec":{"template":{"spec":{"affinity":{"nodeAffinity":{"requiredDuringSchedulingIgnoredDuringExecution":{"nodeSelectorTerms":[{"matchExpressions":[{"key":"alpha.kubernetes.io/nvidia-gpu-name","operator":"In","values":["GTX"]}]}]}}},"containers":[{"name":"ethminer","resources":{"limits":{"alpha.kubernetes.io/nvidia-gpu":"1"}}}]}}}}'
	- change GTX to match node label for your NVIDIA box   
	- change 'ethminer' to match above --name (in both dc and container names)
