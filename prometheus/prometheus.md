##### # playing with prometheus and grafana
```
oc new-project grafana
oc adm policy add-role-to-user view -z grafana -n openshift-metrics
oc adm policy add-cluster-role-to-user cluster-reader gfadmin
oc process -f https://raw.githubusercontent.com/openshift/origin/master/examples/grafana/grafana.yaml |oc create -f -
```
###### # hit grafana dashboard (via the route) and login as 'gfadmin'
##### # now configure the prometheus datasource
###### # use the params
```
Name: prom
URL: http://prometheus-node-exporter.openshift-metrics.svc:9100
Access: Proxy
Type: Prometheus
Token: <GET THE VALUE FROM THIS COMMAND> `oc sa get-token management-admin -n management-infra`
Skip TLS Verification (Insecure) = true
```
##### # now click on the 'dashboards' tab and you should see "Prometheus Stats" listed
##### # click on the 'import' button on the right
