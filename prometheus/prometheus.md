##### # playing with prometheus and grafana
```
oc new-project grafana
oc adm policy add-role-to-user view -z grafana -n openshift-metrics
oc adm policy add-cluster-role-to-user cluster-reader gfadmin
oc process -f https://raw.githubusercontent.com/openshift/origin/master/examples/grafana/grafana.yaml |oc create -f -
```
