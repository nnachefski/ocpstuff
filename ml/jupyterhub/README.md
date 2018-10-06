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
### # Or, deploy jupyterhub w/ keycloak
##### # grant 'anyuid' to 'default' serviceaccount
```
oc adm policy add-scc-to-user anyuid -z default
```
##### # now deploy the stack
```
oc new-app https://raw.githubusercontent.com/jupyter-on-openshift/poc-hub-keycloak-auth/master/templates/jupyterhub.json -e NVIDIA_VISIBLE_DEVICES=1 -e NVIDIA_DRIVER_CAPABILITIES="compute,utility" -e NVIDIA_REQUIRE_CUDA="cuda>=9.0"
```

