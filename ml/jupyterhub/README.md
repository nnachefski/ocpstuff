####  # this howto use the jupyterhub s2i
###### # from: https://github.com/jupyter-on-openshift/jupyterhub-quickstart
##### # create the project
```
oc new-project data-sci
```
##### # create a minimal Jupyter notebook image
```
oc create -f https://raw.githubusercontent.com/jupyter-on-openshift/jupyter-notebooks/master/images.json
```
##### # build the JupyterHub image
```
oc create -f https://raw.githubusercontent.com/jupyter-on-openshift/jupyterhub-quickstart/master/images.json
```
##### # load the template
```
oc create -f https://raw.githubusercontent.com/jupyter-on-openshift/jupyterhub-quickstart/master/templates.json
```
##### # now deploy and use the PythonDataScienceHandbook repo for the notebook source
```
oc new-app --template jupyterhub-quickstart \
  --param APPLICATION_NAME=demo \
  --param GIT_REPOSITORY_URL=https://github.com/jakevdp/PythonDataScienceHandbook
```


##### # deploy jupyterhub w/ keycloak
```
oc new-app https://raw.githubusercontent.com/jupyter-on-openshift/poc-hub-tensorflow-gpu/master/templates/jupyterhub.json -e NVIDIA_VISIBLE_DEVICES=0 -e NVIDIA_DRIVER_CAPABILITIES="compute,utility" -e NVIDIA_REQUIRE_CUDA="cuda>=9.0"
```
##### # clone the test repo
```
git clone http://gitlab-cicd.apps.ocp.nicknach.net/root/poc-hub-tensorflow-gpu.git
```
##### # get the cudnn package
```
wget http://developer.download.nvidia.com/compute/redist/cudnn/v7.1.4/cudnn-9.0-linux-x64-v7.1.tgz
```
##### # cp the tgz into 'notebook' dir
```
mv cudnn-9.0-linux-x64-v7.1.tgz poc-hub-tensorflow-gpu/notebook
```
###### # wait for the images to build
##### # now build tensorflow image
```
cd poc-hub-tensorflow-gpu/notebook
oc start-build jupyterhub-nb-tfg --from-dir=.
```
