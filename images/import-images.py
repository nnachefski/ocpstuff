#!/usr/bin/python3
import sys, os, argparse
from subprocess import DEVNULL, STDOUT, check_call

parser = argparse.ArgumentParser(description='Import images for disconnected OCP installs')
parser.add_argument('source', action="store", help='brew-pulp-docker01.web.prod.ext.phx2.redhat.com:8888')
parser.add_argument('dest', action="store", help='destination, Ex: foo.tar.gz OR atomic.home.nicknach.net:5000')
parser.add_argument('-d', action="store_true", default=False, help='debug mode')
#parser.add_argument('--witharg', action="store", dest="witharg")
args = parser.parse_args()

uri_string = False

if args.d: print("\n"+str(args)+"\n")

if args.dest.endswith(("tar.gz", "tgz")):
	uri_string = 'tarball:%s'%(args.dest)
	if args.d: 
		print("using tarball '%s' as the target"%args.dest)
else:
	try:
		check_call(['curl', '-k', 'http://%s/v1/_ping'%(args.source)], stdout=DEVNULL, stderr=STDOUT)
	except:
		raise
	else:
		if args.d: print("success checking source '%s'"%(args.source))
		
	try:
		check_call(['curl', '-k', 'http://%s/v1/_ping'%(args.dest)], stdout=DEVNULL, stderr=STDOUT)
	except:
		raise
	else:
		if args.d: print("success checking target '%s'"%(args.dest))
	
	uri_string = 'docker://%s'%(args.dest)
	
	if args.d: 
		print("using registry '%s' as the target"%args.dest)




tag = 'v3.9.0.20171214.114003'
src_registry = 'brew-pulp-docker01.web.prod.ext.phx2.redhat.com:8888'
dst_registry = 'atomic.home.nicknach.net:5000'

list = (
'openshift3/ose-ansible',
'openshift3/ose-cluster-capacity',
'openshift3/ose-deployer',
'openshift3/ose-docker-builder',
'openshift3/ose-docker-registry',
'openshift3/ose-egress-http-proxy',
'openshift3/ose-egress-router',
'openshift3/ose-f5-router',
'openshift3/ose-federation',
'openshift3/ose-haproxy-router',
'openshift3/ose-keepalived-ipfailover',
'openshift3/ose-pod',
'openshift3/ose-sti-builder',
'openshift3/ose',
'openshift3/container-engine',
'openshift3/efs-provisioner',
'openshift3/node',
'openshift3/openvswitch',
'openshift3/logging-auth-proxy',
'openshift3/logging-curator',
'openshift3/logging-deployer',
'openshift3/logging-elasticsearch',
'openshift3/logging-fluentd',
'openshift3/logging-kibana',
'openshift3/metrics-cassandra',
'openshift3/metrics-deployer',
'openshift3/metrics-hawkular-metrics',
'openshift3/metrics-hawkular-openshift-agent',
'openshift3/metrics-heapster',
'openshift3/jenkins-1-rhel7',
'openshift3/jenkins-2-rhel7',
'openshift3/jenkins-slave-base-rhel7',
'openshift3/jenkins-slave-maven-rhel7',
'openshift3/jenkins-slave-nodejs-rhel7',
'jboss-amq-6/amq63-openshift',
'jboss-datagrid-7/datagrid71-openshift',
'jboss-datagrid-7/datagrid71-client-openshift',
'jboss-datavirt-6/datavirt63-openshift',
'jboss-datavirt-6/datavirt63-driver-openshift',
'jboss-decisionserver-6/decisionserver64-openshift',
'jboss-processserver-6/processserver64-openshift',
'jboss-eap-6/eap64-openshift',
'jboss-eap-7/eap70-openshift',
'jboss-webserver-3/webserver31-tomcat7-openshift',
'jboss-webserver-3/webserver31-tomcat8-openshift',
'rhscl/mongodb-32-rhel7',
'rhscl/mysql-57-rhel7',
'rhscl/perl-524-rhel7',
'rhscl/php-56-rhel7',
'rhscl/postgresql-95-rhel7',
'rhscl/python-35-rhel7',
'redhat-sso-7/sso70-openshift',
'rhscl/ruby-24-rhel7',
'redhat-openjdk-18/openjdk18-openshift',
'redhat-sso-7/sso71-openshift',
'rhscl/nodejs-6-rhel7',
'rhscl/mariadb-101-rhel7',
	)

'''
if os.getuid() != 0:
	print("root is required")
	sys.exit(2)
'''

pass_list=[]
for i in list:
	#check_call(['skopeo', '--insecure-policy', 'inspect', '--tls-verify=false', "docker://%s/%s:%s"%(src_registry, i, tag)], )#stdout=DEVNULL, stderr=STDOUT)
	#sys.exit()
	try:
		check_call(['skopeo', '--insecure-policy', 'inspect', '--tls-verify=false', "docker://%s/%s:%s"%(src_registry, i, tag)], stdout=DEVNULL, stderr=STDOUT)
	except KeyboardInterrupt:
		print("\nbye...")
		sys.exit(1)
	except:
	 	print("- failed to inspect docker://%s/%s:%s"%(src_registry, i, tag))
	else:
		#print("- inspected %s/%s:%s"%(src_registry, i, tag))
		pass_list.append(i)

for i in pass_list:
	#check_call(['skopeo', '--insecure-policy', 'copy', '--src-tls-verify=false', '--dest-tls-verify=false',  "docker://%s/%s:%s"%(src_registry, i, tag), "docker://%s/%s:latest"%(dst_registry, i)], )#stdout=DEVNULL, stderr=STDOUT)
	#sys.exit()
	try:
		check_call(['skopeo', '--insecure-policy', 'copy', '--src-tls-verify=false', '--dest-tls-verify=false',  "docker://%s/%s:%s"%(src_registry, i, tag), "docker://%s/%s:latest"%(dst_registry, i)], stdout=DEVNULL, stderr=STDOUT)
	except KeyboardInterrupt:
		print("\bye...")
		sys.exit(1)
	except:
		print("- failed to save docker://%s/%s:%s"%(dst_registry, i, 'latest'))
	else:
		print("- saved docker://%s/%s:%s"%(dst_registry, i, 'latest'))
    
  

    
    
