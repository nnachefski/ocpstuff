### # How to generate an s2i image chain from a customized RHEL7 base image using native buildconfigs and imagestreams in Openshift
###### # note that because we are linking images streams, any subsequent modifications to the rhel7-custom image will send imagechange triggers to the entire s2i chain.

### # Note
#### # You can either run through these steps one-at-a-time, or take the easy way and import the template below.

```
oc import-image satellite.home.nicknach.net:8888/rhel7.6 --confirm -n openshift
oc create -f https://raw.githubusercontent.com/nnachefski/ocpstuff/master/rhel7-custom/custom-images-template.yml -n openshift
```
###### # The command used to generate this template is: 
###### # oc export bc,is rhel7-custom s2i-custom-core s2i-custom-base s2i-custom-python36 s2i-custom-nodejs8 -n openshift > custom-images-template.yml
#### # Begin
###### # the idea is to clone and then customize the rhel7-custom folder/image.  Insert your org's certs, gpgkeys, repo files, etc...  Then, you can build (and provide) customized runtime images to your developers and operations teams.

##### # set the project to build these image in.  Using the 'openshift' project will allow others to use these images by default
```
export PROJECT=openshift
```
###### # make sure you have rhel-7-server-rhscl-rpms and rhel-7-server-optional-rpms repos enabled on all openshift build/app nodes

##### # build the base rhel7 images from a git repo (clone mine or use it directly to get started)
```
oc new-build https://github.com/nnachefski/ocpstuff.git --context-dir=rhel7-custom --name=rhel7-custom --strategy=docker -n $PROJECT -e SKIP_REPOS_ENABLE=false -e SKIP_REPOS_DISABLE=true
```
##### # now build the 'core' s2i image.  this build will initially fail because there is no way to pass dockerfilePath on new-build
###### # see next step for work-around
```
oc new-build https://github.com/sclorg/s2i-base-container.git -i rhel7-custom --context-dir=core --name=s2i-custom-core -n $PROJECT --strategy=docker -e SKIP_REPOS_ENABLE=false -e SKIP_REPOS_DISABLE=true
```
###### # a feature is needed to allow a new-build to pass a "Dockerfile" to build (within the context-dir). 
##### # work-around by patching the bc after you create it, https://bugzilla.redhat.com/show_bug.cgi?id=1382938 
```
oc patch bc s2i-custom-core -p '{"spec":{"strategy":{"dockerStrategy":{"dockerfilePath": "Dockerfile.rhel7"}}}}' -n $PROJECT
oc start-build s2i-custom-core -n $PROJECT
```
##### # now build the 'base' s2i image
```
oc new-build https://github.com/sclorg/s2i-base-container.git -i s2i-custom-core --context-dir=base --name=s2i-custom-base --strategy=docker -n $PROJECT -e SKIP_REPOS_ENABLE=false -e SKIP_REPOS_DISABLE=true
```
##### # work-around, see above
```
oc patch bc s2i-custom-base -p '{"spec":{"strategy":{"dockerStrategy":{"dockerfilePath": "Dockerfile.rhel7"}}}}' -n $PROJECT
oc start-build s2i-custom-base -n $PROJECT
```
##### # now lets build our 'builder' images for each runtime

#### # python 3.6
```
oc new-build https://github.com/sclorg/s2i-python-container.git -i s2i-custom-base --context-dir=3.6 --name=s2i-custom-python36 --strategy=docker -n $PROJECT -e SKIP_REPOS_ENABLE=false -e SKIP_REPOS_DISABLE=true
```
##### # work-around, again
```
oc patch bc s2i-custom-python36 -p '{"spec":{"strategy":{"dockerStrategy":{"dockerfilePath": "Dockerfile.rhel7"}}}}' -n $PROJECT
oc start-build s2i-custom-python36 -n $PROJECT
```
##### # now build nodejs 10 custom image
```
oc new-build https://github.com/sclorg/s2i-nodejs-container.git -i s2i-custom-base --context-dir=10 --name=s2i-custom-nodejs10 --strategy=docker -n $PROJECT -e SKIP_REPOS_ENABLE=false -e SKIP_REPOS_DISABLE=true
```
##### # work-around, again
```
oc patch bc s2i-custom-nodejs10 -p '{"spec":{"strategy":{"dockerStrategy":{"dockerfilePath": "Dockerfile.rhel7"}}}}' -n $PROJECT
oc start-build s2i-custom-nodejs10 -n $PROJECT
```
#### # build whatever else runtimes you need
#### # https://github.com/sclorg

###### # now lets test with a small python/django app
##### # create a test project
```
oc new-project custom-s2i-test
```
##### # allow pull from $PROJECT to ‘custom-s2i-test’ 
###### # this is not required if you built your base images in the 'openshift' project
``` 
oc policy add-role-to-group system:image-puller system:serviceaccounts:custom-s2i-test -n $PROJECT
```
##### # add your custom image to the service catalog as a 'builder' image
```
oc patch is s2i-custom-python36 -p '{"spec":{"tags":[{"annotations":{"tags":"builder,python"},"name":"latest"}]}}' -n $PROJECT
oc patch is s2i-custom-nodejs10 -p '{"spec":{"tags":[{"annotations":{"tags":"builder,nodejs"},"name":"latest"}]}}' -n $PROJECT
```
##### # and finally, create the app
```
oc new-app https://github.com/nnachefski/pydemo.git -i s2i-custom-python36 --name=pydemo
```
###### # click to the terminal tab and look for the files that you added to the rhel7-custom base image
##### # now make a change to your rhel7-custom base image and watch all the dependent apps/images get rebuilt auto-magically (via ImageChange triggers)

