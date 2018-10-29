### # deploying CUDA/GPU-enabled Ethereum miners on Openshift.
##### # switch nvidia project (with device plugin DS deployed)
```
oc new-project crypto
```
##### # give the default ServiceAccount 'anyuid' SCC
```
oc adm policy add-scc-to-user anyuid -z default
```
##### # build/deploy ethminer
```
oc new-app https://github.com/nnachefski/ocpstuff.git --context-dir=crypto/ethminer --name=ethminer -e NVIDIA_VISIBLE_DEVICES=all -e NVIDIA_DRIVER_CAPABILITIES="compute,utility" -e NVIDIA_REQUIRE_CUDA="cuda>=9.1" -e APP_VER="0.14.0"
```

###### # you can control which NVIDIA devices to use for mining by setting 'NVIDIA_VISIBLE_DEVICES'.  
###### # Ex: NVIDIA_VISIBLE_DEVICES=0 (will mine on the first device)
###### # you can also switch the verison of ethminer that you want to run by setting 'APP_VER' env var.
