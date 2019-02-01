yum -y -d1 install libvirt libtool rpm-build qemu-kvm kernel-devel kernel-headers dhcp dstat iotop tcpdump ipa-client xorg-x11-xauth virt-manager libvirt-daemon-kvm libvirt-devel git wget golang-bin gcc-c++ net-tools
cp /lib/systemd/system/dhcrelay.service /etc/systemd/system/
sed 's/pid/pid 10.1.11.60/' -i /etc/systemd/system/dhcrelay.service
systemctl --system daemon-reload
systemctl enable dhcrelay --now
firewall-cmd --set-default-zone trusted
echo "systemctl restart dhcrelay" > /etc/cron.hourly/dhcrelay && chmod +x /etc/cron.hourly/dhcrelay
sysctl net.ipv4.ip_forward=1
echo "net.ipv4.ip_forward = 1" | sudo tee /etc/sysctl.d/99-ipforward.conf
sysctl -p /etc/sysctl.d/99-ipforward.conf
sed -i '/listen_tls/s/^#listen_tls/listen_tls/' /etc/libvirt/libvirtd.conf
sed -i '/listen_tcp/s/^#listen_tcp/listen_tcp/' /etc/libvirt/libvirtd.conf
sed -i '/auth_tcp/s/^#auth_tcp/auth_tcp/' /etc/libvirt/libvirtd.conf && sed -i '/auth_tcp/s/^auth_tcp = "sasl"/auth_tcp = "none"/' /etc/libvirt/libvirtd.conf
sed -i '/tcp_port/s/^#tcp_port/tcp_port/' /etc/libvirt/libvirtd.conf
sed -i '/LIBVIRTD_ARGS/s/^#LIBVIRTD_ARGS/LIBVIRTD_ARGS/' /etc/sysconfig/libvirtd
sudo virsh pool-define /dev/stdin <<EOF
<pool type='dir'>
  <name>default</name>
  <target>
    <path>/var/lib/libvirt/images</path>
  </target>
</pool>
EOF
sudo virsh pool-start default
sudo virsh pool-autostart default
#echo dns=dnsmasq >> /etc/NetworkManager/NetworkManager.conf
#echo server=/ocp4.home.nicknach.net/10.1.3.100 | sudo tee /etc/NetworkManager/dnsmasq.d/openshift.conf
systemctl enable libvirtd
systemctl restart libvirtd
mkdir -p /root/go/src/github.com/openshift && mkdir -p /root/go/bin && mkdir -p /tmp/go/bin
curl https://raw.githubusercontent.com/golang/dep/master/install.sh | sh
export GOPATH=/root/go && echo GOPATH=/root/go >> /etc/environment
export PATH=$PATH:$GOPATH/bin && echo PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/root/bin:/root/go/bin >> /etc/environment
cd /root/go/src/github.com/openshift && git clone https://github.com/openshift/installer.git

cd /root/go/src/github.com/openshift/installer
TAGS=libvirt hack/build.sh


