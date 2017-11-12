#!/usr/bin/python
import sys,os

#url = 'brew-pulp-docker01.web.prod.ext.phx2.redhat.com:8888'
url = 'registry.access.redhat.com'
image_dir = '/home/data'
tag = 'latest'

list = [
    "openshift3/ose-haproxy-router",
    "openshift3/ose-deployer",
    "openshift3/ose-sti-builder",
    "openshift3/ose-docker-builder",
    "openshift3/ose-pod",
    "openshift3/ose-docker-registry",
    "openshift3/logging-deployer",
    "openshift3/logging-elasticsearch",
    "openshift3/logging-kibana",
    "openshift3/logging-fluentd",
    "openshift3/logging-auth-proxy",
    "openshift3/metrics-deployer",
    "openshift3/metrics-hawkular-metrics",
    "openshift3/metrics-cassandra",
    "openshift3/metrics-heapster",
    "rhscl/mongodb-26-rhel7",
    "rhscl/mongodb-32-rhel7",
    "rhscl/mysql",
    "rhscl/nodejs-4-rhel7",
    "rhscl/perl-520-rhel7",
    "rhscl/perl-524-rhel7",
    "rhscl/php-56-rhel7",
    "rhscl/php-70-rhel7",
    "rhscl/postgresql-94-rhel7",
    "rhscl/postgresql-95-rhel7",
    "rhscl/python-27-rhel7",
    "rhscl/python-34-rhel7",
    "rhscl/python-35-rhel7",
    "rhscl/s2i-base-rhel7",
    "redhat-sso-7/sso70-openshift",
	]

for i in list:
	cmd = "docker pull %s/%s:%s"%(url,i, tag)
	print " - "+cmd
	os.system(cmd)

#	print "docker save -o %s/%s.tar %s/%s:%s"%(image_dir, i, url, i, tag)
#	print os.system("docker save -o %s/%s.tar %s/%s:%s"%(image_dir, i, url, i, tag))
