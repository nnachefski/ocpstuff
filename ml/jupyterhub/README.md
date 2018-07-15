####  # this howto use the jupyterhub s2i
###### # from: https://github.com/jupyter-on-openshift/jupyterhub-quickstart
##### # create the project
```
oc new-project jupyterhub-s2i
```
##### # give the default sa 'anyuid' scc on this project
```
#oc adm policy add-scc-to-user anyuid -z default
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
  --param APPLICATION_NAME=dsdemo \
  --param GIT_REPOSITORY_URL=https://github.com/jakevdp/PythonDataScienceHandbook
```
