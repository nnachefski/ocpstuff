##### # register w/ rhn
```
subscription-manager register --username=nnachefs@redhat.com 
```
##### # subscribe to the proper channels for install
```
subscription-manager attach --pool 8a85f98260c27fc50160c323263339ff
subscription-manager repos --enable=rhel-7-server-rpms --enable=rhel-server-rhscl-7-rpms --enable=rhel-7-server-satellite-6.4-rpms --enable=rhel-7-server-satellite-maintenance-6-rpms --enable=rhel-7-server-ansible-2.6-rpms
```
##### # install the satellite provisioner
```
yum install -y satellite
```
##### # open the fw up 
```
firewall-cmd --set-default-zone trusted
```
##### # run the installer
```
satellite-installer --scenario satellite --foreman-admin-password welcome1 --foreman-proxy-puppetca true --foreman-proxy-tftp true --enable-foreman-plugin-discovery --foreman-proxy-dhcp true --foreman-proxy-dhcp-managed true --foreman-proxy-dhcp-interface "eth0" 
```
