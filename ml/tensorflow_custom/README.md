##### # This example uses Tensorflow and Jupyter
###### # this image requires the rhel7-custom image to be available 
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
oc new-app https://github.com/nnachefski/ocpstuff.git --context-dir=ml/tensorflow_custom --name=tensorflow-custom-gpu -e NVIDIA_VISIBLE_DEVICES=all -e NVIDIA_DRIVER_CAPABILITIES="compute,utility" -e NVIDIA_REQUIRE_CUDA="cuda>=9.0"
```
##### # expose the jupyter UI port
```
oc expose svc jupyter --port 8888
```