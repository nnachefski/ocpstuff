####  # artifactory on openshift
##### # create the project
```
oc new-project cicd
```
##### # get the template
```
wget https://raw.githubusercontent.com/jfrog/artifactory-docker-examples/master/kubernetes/artifactory.yml
```
##### # now create the template
```
oc create -f artifactory.yml
```
##### # give the default sa 'anyuid' scc on this project
```
oc adm policy add-scc-to-user anyuid -z gitlab-ce-user
```
##### # now deploy gitlab
```
oc new-app --template gitlab-ce 
```
