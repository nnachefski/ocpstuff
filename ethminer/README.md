### # This image is for building and deploying CUDA/GPU-enabled Ethereum miners on Openshift.
##### # create the project
```
oc new-project ether
```
##### # give the default ServiceAccount 'anyuid' SCC
```
oc adm policy add-scc-to-user anyuid -z default
```
##### # build/deploy ethminer
```
oc new-app https://github.com/nnachefski/ocpstuff.git --context-dir=images/ether --name=ethminer -e NVIDIA_VISIBLE_DEVICES=all -e NVIDIA_DRIVER_CAPABILITIES="compute,utility" -e NVIDIA_REQUIRE_CUDA="cuda>=9.0" -e APP_VER="0.14.0"
```

##### # then patch the DeploymentConfig
```
oc patch dc ethminer -p '{"spec":{"template":{"spec":{"containers":[{"name":"ethminer","resources":{"limits":{"nvidia.com/gpu":1}}}]}}}}'
``` 
