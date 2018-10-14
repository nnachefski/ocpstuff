subscription-manager register --username=rgupta@redhat.com --password <REDACTED> --force
subscription-manager attach --pool=8a85f98260c27fc50160c323247e39e0 
subscription-manager repos --disable="*"
subscription-manager repos \
   --enable=rhel-7-server-rpms \
   --enable=rhel-7-server-extras-rpms \
   --enable=rhel-7-server-ose-3.9-rpms \
   --enable=rhel-7-fast-datapath-rpms \
   --enable=rhel-server-rhscl-7-rpms \
   --enable=rhel-7-server-optional-rpms \
   --enable=rhel-7-server-ansible-2.4-rpms \
   --enable=rh-gluster-3-for-rhel-7-server-rpms
yum install -y yum-utils wget git net-tools bind-utils iptables-services bridge-utils bash-completion nfs-utils dstat mlocate
yum install -y atomic atomic-openshift-clients
yum install -y docker docker-logrotate
yum install -y cns-deploy heketi-client
cat <<EOF > /etc/sysconfig/docker-storage-setup
DEVS=$DOCKER_DEV
VG=docker-vg
WIPE_SIGNATURES=true
EOF
container-storage-setup
yum -y update
