oc new-project grafana
oc adm policy add-role-to-user view -z grafana -n openshift-metrics
oc process -f https://raw.githubusercontent.com/openshift/origin/master/examples/grafana/grafana.yaml |oc create -f -
oc process mysql-persistent -n openshift -p MYSQL_ROOT_PASSWORD=welcome1 -p MYSQL_PASSWORD=welcome1 -p MYSQL_USER=grafana -p MYSQL_DATABASE=grafana | oc create -f -
