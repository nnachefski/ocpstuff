### # build a cuda-enabled rhel7 image based on your customized rhel7-custom image
###### # this image adds the nvidia cuda libs to rhel7-custom
##### # set the project and build the image
```
export PROJECT=openshift
oc new-build https://github.com/nnachefski/ocpstuff.git --context-dir=images/rhel7-cuda --name=rhel7-cuda -i rhel7-custom --strategy=docker -n $PROJECT
```
##### # add it to the builder catalog
```
oc patch is s2i-custom-python35 -p '{"spec":{"tags":[{"annotations":{"tags":"builder,python"},"name":"latest"}]}}' -n $PROJECT
```
#### # now get started with some tensorflow+jupyter demos or ether mining containers

https://github.com/nnachefski/ocpstuff/tree/master/images/tensorflow

https://github.com/nnachefski/ocpstuff/tree/master/images/ether
