#### # To make the [lb] instance also serve the wildcard domain, add this config to /etc/haproxy/haproxy.cfg
```
frontend  atomic-openshift-app-80
    bind *:80
    default_backend atomic-openshift-app-80
    mode http
    option tcplog

frontend  atomic-openshift-app-443
    bind *:443
    default_backend atomic-openshift-app-443
    mode tcp
    option tcplog

backend atomic-openshift-app-80
    balance source
    mode http
    server      infra01 10.1.4.80:80 check
    server      infra02 10.1.3.81:80 check
    server      infra03 10.1.5.82:80 check

backend atomic-openshift-app-443
    balance source
    mode tcp
    server      infra01 10.1.4.80:443 check
    server      infra02 10.1.3.81:443 check
    server      infra03 10.1.5.82:443 check

```