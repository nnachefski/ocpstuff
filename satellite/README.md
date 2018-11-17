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
satellite-installer --scenario satellite --foreman-initial-organization "nicknach" --foreman-initial-location "home" --foreman-admin-password welcome1 --foreman-proxy-puppetca true --foreman-proxy-tftp true --enable-foreman-plugin-discovery --foreman-proxy-dhcp true --foreman-proxy-dhcp-managed true --foreman-proxy-dhcp-interface "eth0"
satellite-installer --scenario satellite --foreman-proxy-dhcp-managed false
```
###### # to disable puppet
```
--no-enable-puppet --puppet-agent false --puppet-server false --foreman-proxy-puppet false
```
##### # to copy the foreman ssh key
```
curl https://satellite.home.nicknach.net:9090/ssh/pubkey >> /root/.ssh/authorized_keys
```
##### # add files to a repo manually
```
do hammer repository upload-content --product nicknach-extras --name nicknach-extras --organization "nicknach" --path  $i
```
