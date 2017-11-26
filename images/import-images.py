#!/usr/bin/python
import sys,os

image_dir = '/home/data'
tag = 'latest'

list = [
'registry.access.redhat.com/openshift3/ose-ansible',
'registry.access.redhat.com/openshift3/ose-cluster-capacity',
'registry.access.redhat.com/openshift3/ose-deployer',
'registry.access.redhat.com/openshift3/ose-docker-builder',
'registry.access.redhat.com/openshift3/ose-docker-registry',
'registry.access.redhat.com/openshift3/ose-egress-http-proxy',
'registry.access.redhat.com/openshift3/ose-egress-router',
'registry.access.redhat.com/openshift3/ose-f5-router',
'registry.access.redhat.com/openshift3/ose-federation',
'registry.access.redhat.com/openshift3/ose-haproxy-router',
'registry.access.redhat.com/openshift3/ose-keepalived-ipfailover',
'registry.access.redhat.com/openshift3/ose-pod',
'registry.access.redhat.com/openshift3/ose-sti-builder',
'registry.access.redhat.com/openshift3/ose',
'registry.access.redhat.com/openshift3/container-engine',
'registry.access.redhat.com/openshift3/efs-provisioner',
'registry.access.redhat.com/openshift3/node',
'registry.access.redhat.com/openshift3/openvswitch',
'registry.access.redhat.com/openshift3/logging-auth-proxy',
'registry.access.redhat.com/openshift3/logging-curator',
'registry.access.redhat.com/openshift3/logging-deployer',
'registry.access.redhat.com/openshift3/logging-elasticsearch',
'registry.access.redhat.com/openshift3/logging-fluentd',
'registry.access.redhat.com/openshift3/logging-kibana',
'registry.access.redhat.com/openshift3/metrics-cassandra',
'registry.access.redhat.com/openshift3/metrics-deployer',
'registry.access.redhat.com/openshift3/metrics-hawkular-metrics',
'registry.access.redhat.com/openshift3/metrics-hawkular-openshift-agent',
'registry.access.redhat.com/openshift3/metrics-heapster',
'registry.access.redhat.com/jboss-amq-6/amq63-openshift',
'registry.access.redhat.com/jboss-datagrid-7/datagrid71-openshift',
'registry.access.redhat.com/jboss-datagrid-7/datagrid71-client-openshift',
'registry.access.redhat.com/jboss-datavirt-6/datavirt63-openshift',
'registry.access.redhat.com/jboss-datavirt-6/datavirt63-driver-openshift',
'registry.access.redhat.com/jboss-decisionserver-6/decisionserver64-openshift',
'registry.access.redhat.com/jboss-processserver-6/processserver64-openshift',
'registry.access.redhat.com/jboss-eap-6/eap64-openshift',
'registry.access.redhat.com/jboss-eap-7/eap70-openshift',
'registry.access.redhat.com/jboss-webserver-3/webserver31-tomcat7-openshift',
'registry.access.redhat.com/jboss-webserver-3/webserver31-tomcat8-openshift',
'registry.access.redhat.com/openshift3/jenkins-1-rhel7',
'registry.access.redhat.com/openshift3/jenkins-2-rhel7',
'registry.access.redhat.com/openshift3/jenkins-slave-base-rhel7',
'registry.access.redhat.com/openshift3/jenkins-slave-maven-rhel7',
'registry.access.redhat.com/openshift3/jenkins-slave-nodejs-rhel7',
'registry.access.redhat.com/rhscl/mongodb-32-rhel7',
'registry.access.redhat.com/rhscl/mysql-57-rhel7',
'registry.access.redhat.com/rhscl/perl-524-rhel7',
'registry.access.redhat.com/rhscl/php-56-rhel7',
'registry.access.redhat.com/rhscl/postgresql-95-rhel7',
'registry.access.redhat.com/rhscl/python-35-rhel7',
'registry.access.redhat.com/redhat-sso-7/sso70-openshift',
'registry.access.redhat.com/rhscl/ruby-24-rhel7',
'registry.access.redhat.com/redhat-openjdk-18/openjdk18-openshift',
'registry.access.redhat.com/redhat-sso-7/sso71-openshift',
'registry.access.redhat.com/rhscl/nodejs-6-rhel7',
'registry.access.redhat.com/rhscl/mariadb-101-rhel7'
	]


for i in list:
    cmd = "skopeo inspect docker://%s"%(i)
    print " - "+cmd
    os.system(cmd)
    
    cmd = "docker pull %s:%s"%(i, tag)
    print " - "+cmd
    os.system(cmd)
    
    cmd = "docker save -o %s/%s.tar %s:%s"%(image_dir, i, i, tag)
    print " - "+cmd
    os.system(cmd)
    
    
