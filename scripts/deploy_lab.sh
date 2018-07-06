TYPE=$1
TEMPLATE=rhel7

#echo "Cleaning up data dirs..."
#ssh root@storage /cloud/scripts/osev3/cleanup.sh

if [ "$TYPE" == "oso" ]; then
	TEMPLATE=centos7
	echo "- using $TEMPLATE base image"
	ssh root@hv4.home.nicknach.net /cloud/scripts/new.sh omaster01 $TEMPLATE 16384 2 52:54:00:18:55:49 &
	ssh root@hv3.home.nicknach.net /cloud/scripts/new.sh omaster02 $TEMPLATE 16384 2 52:54:00:19:57:49 &
	ssh root@hv5.home.nicknach.net /cloud/scripts/new.sh omaster03 $TEMPLATE 16384 2 52:54:00:18:58:49 &
	ssh root@hv4.home.nicknach.net /cloud/scripts/new.sh onode01 $TEMPLATE 16384 2 52:54:00:18:56:49 &
	ssh root@hv3.home.nicknach.net /cloud/scripts/new.sh onode02 $TEMPLATE 16385 2 52:54:00:18:57:49 &
	ssh root@hv5.home.nicknach.net /cloud/scripts/new.sh onode03 $TEMPLATE 16384 2 52:54:00:12:58:49 &
    ssh root@hv4.home.nicknach.net /cloud/scripts/new.sh oinfra01 $TEMPLATE 16384 2 52:54:00:01:58:49 &
    ssh root@hv3.home.nicknach.net /cloud/scripts/new.sh oinfra02 $TEMPLATE 16384 2 52:54:00:02:58:49 &
    ssh root@hv5.home.nicknach.net /cloud/scripts/new.sh oinfra03 $TEMPLATE 16384 2 52:54:00:03:58:49 &

elif [ "$TYPE" == "ocp" ]; then
	echo "- using $TEMPLATE base image"
	ssh root@hv4.home.nicknach.net /cloud/scripts/new.sh master01 $TEMPLATE 16384 2 52:54:00:fb:09:ec &
	ssh root@hv3.home.nicknach.net /cloud/scripts/new.sh master02 $TEMPLATE 16384 2 52:54:00:18:58:01 &
	ssh root@hv5.home.nicknach.net /cloud/scripts/new.sh master03 $TEMPLATE 16384 2 52:54:00:18:58:02 &
	ssh root@hv4.home.nicknach.net /cloud/scripts/new.sh node01 $TEMPLATE 16384 2 52:54:00:db:14:7d &
	ssh root@hv3.home.nicknach.net /cloud/scripts/new.sh node02 $TEMPLATE 16384 2 52:54:00:68:4a:e3 &
	ssh root@hv5.home.nicknach.net /cloud/scripts/new.sh node03 $TEMPLATE 16384 2 52:54:00:68:54:49 &
	ssh root@hv4.home.nicknach.net /cloud/scripts/new.sh infra01 $TEMPLATE 16384 2 52:54:00:18:58:03 &
	ssh root@hv3.home.nicknach.net /cloud/scripts/new.sh infra02 $TEMPLATE 16384 2 52:54:00:18:59:04 &
	ssh root@hv5.home.nicknach.net /cloud/scripts/new.sh infra03 $TEMPLATE 16384 2 52:54:00:18:73:04 &
else
	echo "Unrecognized deployment type, idiot.  Use 'ocp|oso'"
	exit 1 
fi

echo "Done!"

