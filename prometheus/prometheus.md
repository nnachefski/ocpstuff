##### # playing with prometheus and grafana
```
oc new-project grafana
oc adm policy add-role-to-user view -z gfadmin -n openshift-metrics
oc process -f https://raw.githubusercontent.com/openshift/origin/master/examples/grafana/grafana.yaml |oc create -f -
```
