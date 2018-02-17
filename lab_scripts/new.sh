#!/bin/bash
## this scipt automates the creation of KVM VMs
## ./new.sh domain rhel7 8192 4 <optional MAC> 

HOST=`printf '%s' $1`
HOME="/var/lib/libvirt/images"
IM="$HOME/$HOST.qcow2"
UM="$HOME/$HOST-1.qcow2"
TIM="/images/templates/$2-template.qcow2"
SIM="/images/templates/$2-template-1.qcow2"
MEM=`printf '%s' $3`
CPU=`printf '%s' $4`
NIC=`printf '%s' $5`
BASE='home.nicknach.net'
DOCKER_DISK_SIZE=16384

rm -rf $IM
echo "cloning $TIM to $IM"
cp $TIM $IM

echo "making vm..."
RUNLINE="virt-install --connect qemu:///system -n $HOST -r $MEM --vcpus=$CPU --disk path=$IM,bus=virtio --vnc --noautoconsole --os-type linux --accelerate --hvm --boot hd -w bridge=virbr0,model=virtio"

if [ -z "$NIC" ];
then
    echo "not MAC specified..."
else
    echo "adding MAC $NIC"
    RUNLINE="$RUNLINE -m $NIC"
fi

dd if=/dev/zero of=$UM bs=1M count=$DOCKER_DISK_SIZE

RUNLINE="$RUNLINE --disk path=$UM,bus=virtio "

echo "Executing: $RUNLINE"
eval $RUNLINE
