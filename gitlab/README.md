####  # gitlab-ce on openshift
##### # create the project
```
oc new-project cicd
```
##### # get the template
```
wget https://gitlab.com/gitlab-org/omnibus-gitlab/raw/master/docker/openshift-template.json
```
##### # now create the template
```
oc create -f openshift-template.json
```
##### # give the default sa 'anyuid' scc on this project
```
oc adm policy add-scc-to-user anyuid -z gitlab-ce-user
```
##### # now deploy gitlab
```
oc new-app --template gitlab-ce -p APPLICATION_HOSTNAME=gitlab-cicd.apps.ocp.nicknach.net
```
