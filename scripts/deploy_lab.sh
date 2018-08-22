TYPE=$1
TEMPLATE=rhel75

if [ "$TYPE" == "oso" ]; then
	TEMPLATE=centos7
	echo "- using $TEMPLATE base image"
elif [ "$TYPE" == "ocp" ]; then
	echo "- using $TEMPLATE base image"
else
	echo "Unrecognized deployment type, idiot.  Use 'ocp|oso'"
	exit 1 
fi

ssh root@storage.home.nicknach.net /cloud/scripts/new.sh lb $TEMPLATE 4196 2 52:54:00:18:58:16 &
ssh root@hv4.home.nicknach.net /cloud/scripts/new.sh master01 $TEMPLATE 16384 2 52:54:00:fb:09:ec &
ssh root@hv3.home.nicknach.net /cloud/scripts/new.sh master02 $TEMPLATE 16384 2 52:54:00:18:58:01 &
ssh root@hv5.home.nicknach.net /cloud/scripts/new.sh master03 $TEMPLATE 16384 2 52:54:00:18:58:02 &
ssh root@hv4.home.nicknach.net /cloud/scripts/new.sh node01 $TEMPLATE 16384 2 52:54:00:db:14:7d &
ssh root@hv3.home.nicknach.net /cloud/scripts/new.sh node02 $TEMPLATE 16384 2 52:54:00:68:4a:e3 &
ssh root@hv5.home.nicknach.net /cloud/scripts/new.sh node03 $TEMPLATE 16384 2 52:54:00:68:54:49 &
ssh root@hv4.home.nicknach.net /cloud/scripts/new.sh infra01 $TEMPLATE 16384 2 52:54:00:18:58:03 &
ssh root@hv3.home.nicknach.net /cloud/scripts/new.sh infra02 $TEMPLATE 16384 2 52:54:00:18:59:04 &
ssh root@hv5.home.nicknach.net /cloud/scripts/new.sh infra03 $TEMPLATE 16384 2 52:54:00:18:73:04 &

echo "Done!"

