#### # This is a howto on deploying a more complete prometheus stack onto Openshift Container Platform 3.9. 
##### # Some components of prometheus (alerting) are in the pending 3.9 release, however, fall far short of expectations.  This document is to be used as a stop gap until RH can officially production-ize Prometheus and GA it as a part of Openshift.

###### # make sure you deploy your 3.9 cluster with promtheus/alertmanager/alertbuffer and that you have PVs allocated
##### # deploy the node exporter
```
oc create -f node-exporter.yaml -n openshift-metrics
oc adm policy add-scc-to-user -z prometheus-node-exporter -n openshift-metrics hostaccess
oc annotate ns openshift-metrics openshift.io/node-selector= --overwrite
```
