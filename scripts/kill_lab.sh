## destroy(rm) the OCP lab
ssh root@hv4.home.nicknach.net virsh destroy master01
ssh root@hv3.home.nicknach.net virsh destroy master02
ssh root@hv5.home.nicknach.net virsh destroy master03
ssh root@hv4.home.nicknach.net virsh destroy node01
ssh root@hv3.home.nicknach.net virsh destroy node02
ssh root@hv5.home.nicknach.net virsh destroy node03
ssh root@hv5.home.nicknach.net virsh destroy lb
ssh root@hv4.home.nicknach.net virsh destroy infra01
ssh root@hv3.home.nicknach.net virsh destroy infra02
ssh root@hv5.home.nicknach.net virsh destroy infra03
ssh root@hv4.home.nicknach.net virsh undefine --domain master01
ssh root@hv3.home.nicknach.net virsh undefine --domain master02
ssh root@hv5.home.nicknach.net virsh undefine --domain master03
ssh root@hv4.home.nicknach.net virsh undefine --domain node01
ssh root@hv3.home.nicknach.net virsh undefine --domain node02
ssh root@hv5.home.nicknach.net virsh undefine --domain node03
ssh root@hv5.home.nicknach.net virsh undefine --domain lb
ssh root@hv4.home.nicknach.net virsh undefine --domain infra01
ssh root@hv3.home.nicknach.net virsh undefine --domain infra02
ssh root@hv5.home.nicknach.net virsh undefine --domain infra03
ssh root@hv3.home.nicknach.net rm -rf /var/lib/libvirt/images/master02*.qcow2
ssh root@hv4.home.nicknach.net rm -rf /var/lib/libvirt/images/master01*.qcow2
ssh root@hv5.home.nicknach.net rm -rf /var/lib/libvirt/images/master03*.qcow2
ssh root@hv3.home.nicknach.net rm -rf /var/lib/libvirt/images/node02*.qcow2
ssh root@hv4.home.nicknach.net rm -rf /var/lib/libvirt/images/node01*.qcow2
ssh root@hv5.home.nicknach.net rm -rf /var/lib/libvirt/images/node03*.qcow2
ssh root@hv3.home.nicknach.net rm -rf /var/lib/libvirt/images/infra02*.qcow2
ssh root@hv4.home.nicknach.net rm -rf /var/lib/libvirt/images/infra01*.qcow2
ssh root@hv5.home.nicknach.net rm -rf /var/lib/libvirt/images/infra03*.qcow2
ssh root@hv5.home.nicknach.net rm -rf /var/lib/libvirt/images/lb*.qcow2

echo "Cleaning up data dirs..."
ssh root@storage.home.nicknach.net /cloud/scripts/osev3/nfs_cleanup.sh

echo "Done!"
