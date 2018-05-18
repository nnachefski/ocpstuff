####  # this howto is tensorflow/jupyter running in an openshift container
###### # follow these instructions to enable your node for GPU containers
##### # https://blog.openshift.com/use-gpus-with-device-plugin-in-openshift-3-9/
##### # import the base tensorflow image
```
oc import-image repo.home.nicknach.net/tensorflow/tensorflow:latest-gpu -n openshift --confirm
```
##### # now run the template to create serviceaccount
```
oc create -f https://raw.githubusercontent.com/nnachefski/ocpstuff/master/ml/tensorflow.yml
```
##### # now use new-app to launch the image
```
oc new-app -i tensorflow:latest-gpu -e NVIDIA_VISIBLE_DEVICES=all -e NVIDIA_DRIVER_CAPABILITIES="compute,utility" -e NVIDIA_REQUIRE_CUDA="cuda>=8.0"
```
