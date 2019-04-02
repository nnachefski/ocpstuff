#### # this is for building jboss-base on top of rhel7-custom

##### # start the base build
```
oc new-build https://github.com/nnachefski/ocpstuff.git --context-dir=jboss-images/base --strategy=docker --name=jboss-base
```