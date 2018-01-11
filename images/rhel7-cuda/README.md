#### # build a cuda-enabled rhel7 image based on your customized rhel7-custom image
###### # this image adds the nvidia cuda libs to rhel7-custom
```
oc new-build https://github.com/nnachefski/rhel7-cuda.git --name=rhel7-cuda -n openshift -i rhel7-custom --strategy=docker
```
#### # now get started with some tensorflow+jupyter demos or ether mining containers

https://github.com/nnachefski/ml-on-ocp

https://github.com/nnachefski/ether-on-ocp
