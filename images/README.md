## How to generate an s2i image chain from a customized RHEL7 base image
#### note that this method also generates imagestream objects.  Any subsequent modifications to the base image will send imagechange triggers to the entire s2i chain

### build the base image
oc new-build https://github.com/nnachefski/ocpstuff.git --context-dir=/images/rhel7-custom --name=rhel7-custom

### now build the 'core' s2i image
oc new-build https://github.com/sclorg/s2i-base-container.git --context-dir=core -i rhel7-custom --name=s2i-custom-core --strategy=docker

### build the 'base' s2i image
oc start-build s2i-custom-core --from-file=Dockerfile.rhel7


