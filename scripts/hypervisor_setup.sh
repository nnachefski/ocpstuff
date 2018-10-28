export DHCP_SERVER=10.1.11.60
export REPO_SERVER=http://repo.home.nicknach.net

yum-config-manager --disable \* && rm -rf /etc/yum.repos.d/*.repo && yum clean all
yum-config-manager --add-repo $REPO_SERVER/repo/rhel-7-server-rpms
yum-config-manager --add-repo $REPO_SERVER/repo/rhel-7-server-extras-rpms
yum-config-manager --add-repo $REPO_SERVER/repo/nvidia
yum-config-manager --add-repo $REPO_SERVER/repo/epel
rpm --import $REPO_SERVER/keys/7fa2af80.pub
rpm --import $REPO_SERVER/keys/RPM-GPG-KEY-EPEL-7
rpm --import $REPO_SERVER/keys/RPM-GPG-KEY-redhat-release
yum -y install virt-install virt-manager qemu-kvm libvirt dstat iotop tcpdump ipa-client dhcp xorg-x11-xauth
cp /lib/systemd/system/dhcrelay.service /etc/systemd/system/
sed 's/pid/pid $DHCP_SERVER/' -i /etc/systemd/system/dhcrelay.service
systemctl --system daemon-reload
systemctl enable dhcrelay --now
firewall-cmd --set-default-zone trusted
yum -y install cuda-9-0
