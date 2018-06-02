####  # this howto is tensorflow/jupyter running in an openshift container
###### # follow these instructions to enable your node for GPU containers
##### #  
##### # now import the base tensorflow image
```
oc import-image repo.home.nicknach.net/tensorflow/tensorflow:latest-gpu -n openshift --insecure --confirm
```
##### # give the default ServiceAcount 'anyuid' SCC
```
oc adm policy add-scc-to-user anyuid -z default
```
##### # now use new-app to launch the image
```
oc new-app -n nvidia -i tensorflow:latest-gpu -e NVIDIA_VISIBLE_DEVICES=all -e NVIDIA_DRIVER_CAPABILITIES="compute,utility" -e NVIDIA_REQUIRE_CUDA="cuda>=9.0"
```

