#### # this is for building jboss-base on top of rhel7-custom

##### # start the jboss base build
```
oc new-build https://github.com/nnachefski/ocpstuff.git --context-dir=jboss-images/base --strategy=docker --name=jboss-base
```

##### # now build the openjdk on top of the jboss base
```
oc new-build https://github.com/jboss-dockerfiles/base-jdk.git -i jboss-base --strategy=docker --name=base-jdk8
```

