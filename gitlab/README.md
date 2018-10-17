####  # gitlab-ce on openshift
##### # set the wildcar variable
```
export WILDCARD=apps.ocp.nicknach.net
```
##### # create the project
```
oc new-project cicd || oc project cicd
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
oc new-app --template gitlab-ce -p APPLICATION_HOSTNAME=gitlab-cicd.$WILDCARD
```
