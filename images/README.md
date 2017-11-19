## How to generate an s2i image chain from a customized RHEL7 base image using native buildconfigs and imagestreams
#### note that because we are linking images streams, any subsequent modifications to the rhel7-custom image will send imagechange triggers to the entire s2i chain
#### this functionality is higly desired by ops folks when maintaining custom images (and their derived s2i builders)

### using the 'openshift' project will allow others to use these images
export $PROJECT=openshift

### make sure you have rhscl and optional repos enabled on all openshift build/app nodes
subscription-manager repos --enable=rhel-7-server-rhscl-rpms --enable=rhel-7-server-optional-rpms

### build the rhel7 base image from a git repo (clone mine and use it to get started)
oc new-build https://github.com/nnachefski/ocpstuff.git --context-dir=/images/rhel7-custom --name=rhel7-custom -n $PROJECT

### now build the 'core' s2i image
oc new-build https://github.com/sclorg/s2i-base-container.git -i rhel7-custom --context-dir=core --name=s2i-custom-core --strategy=docker -n $PROJECT
### work-around until this feature gets enabled 
### https://bugzilla.redhat.com/show_bug.cgi?id=1382938 
oc patch bc s2i-custom-core -p '{"spec":{"strategy":{"dockerStrategy":{"dockerfilePath": "Dockerfile.rhel7"}}}}' -n $PROJECT
oc start-build s2i-custom-core -n openshift

### build the 'base' s2i image
oc new-build https://github.com/sclorg/s2i-base-container.git -i s2i-custom-core --context-dir=base --name=s2i-custom-base --strategy=docker -n $PROJECT
### work-around 
oc patch bc s2i-custom-base -p '{"spec":{"strategy":{"dockerStrategy":{"dockerfilePath": "Dockerfile.rhel7"}}}}' -n $PROJECT
oc start-build s2i-custom-base -n $PROJECT

