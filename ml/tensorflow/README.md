####  # tensorflow/jupyter running in an openshift container
###### # follow these instructions to enable your nvidia node for GPU containers
##### #  https://github.com/nnachefski/ocpstuff/tree/master/nvidia
###### # nvidia daemonset pre-req required (see above link)
##### # import the base tensorflow image
```
oc import-image docker.io/tensorflow/tensorflow:latest-gpu -n openshift --confirm
```
##### # give the default ServiceAccount 'anyuid' SCC or, switch the DC to use the nvidia SA created in the previous howto
```
oc adm policy add-scc-to-user anyuid -z default
```
##### # now use new-app to launch the image
```
oc new-app -n nvidia -i tensorflow:latest-gpu -e NVIDIA_VISIBLE_DEVICES=1 -e NVIDIA_DRIVER_CAPABILITIES="compute,utility" -e NVIDIA_REQUIRE_CUDA="cuda>=9.0"
```
