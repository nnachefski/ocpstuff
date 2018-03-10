#!/bin/bash
# ./new.sh domain rhel7 8192 4 <optional MAC> 

HOST=`printf '%s' $1`
HOME="/var/lib/libvirt/images"
IM="$HOME/$HOST.qcow2"
UM="$HOME/$HOST-1.qcow2"
TIM="/images/templates/$2-template.qcow2"
MEM=`printf '%s' $3`
CPU=`printf '%s' $4`
NIC=`printf '%s' $5`
BASE='home.nicknach.net'

rm -rf $IM
echo "cloning $TIM to $IM"
cp $TIM $IM

echo "making vm..."
RUNLINE="virt-install --vnc --accelerate --hvm --noautoconsole --os-type linux --os-variant=rhel7 --boot hd --connect qemu:///system -n $HOST -r $MEM --vcpus=$CPU --disk path=$IM,bus=virtio --network bridge=virbr0,model=virtio"

if [ -z "$NIC" ];
then
    echo "no MAC specified..."
    RUNLINE="$RUNLINE "
else
    echo "adding MAC $NIC"
    RUNLINE="$RUNLINE,mac=$NIC"
fi

## create the docker-pool disk
qemu-img create -f qcow2 $UM 15G
RUNLINE="$RUNLINE --disk path=$UM,bus=virtio "

if [[ $HOST == infra* ]] || [[ $HOST == node* ]];
then
CNS_DISK="$HOME/$HOST-2.qcow2"
    echo "adding CNS disk '$CNS_DISK'"
    qemu-img create -f qcow2 $CNS_DISK 50G
    RUNLINE="$RUNLINE --disk path=$CNS_DISK,bus=virtio"
fi

echo "Executing: $RUNLINE"
eval $RUNLINE


