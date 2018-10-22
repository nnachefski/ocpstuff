####  # how to deploy ai-duet NN demo app
##### # create the project
```
oc new-project cool
```
##### # give the default sa 'anyuid' scc on this project
```
#oc adm policy add-scc-to-user anyuid -z default
```
##### # deploy ai-duet app
```
oc new-app --docker-image=docker.io/marcelmaatkamp/aiexperiments-ai-duet:latest --name ai-duet
```
