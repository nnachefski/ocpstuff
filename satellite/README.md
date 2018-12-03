## This howto describes how to setup a Red Hat Satellite Server to be used for disconnected install of Openshift.  
##### # This box would serve as a content repo for RPMs and Container Images.
##### # It can be used for both multi and single-master installations.
##### # Included in this repo, are job templates to perform varios Openshift-related tasks.  Such as node-prep, install, post-install steps (IPA integration for SSO and RBAC), istio installatioin, and nvidia driver and CUDA packages.
###### # You'll want plenty of storage on this host, recommended 200GB. 

##### # first, register the host w/ RHN Network (through a proxy is fine).
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
##### # list job templates from CLI
```
hammer job-template list
```
##### # export job template to erb files (these are for installing openshift, nvidia, and istio)
```
hammer job-template export --id 144 > ocp_apps.erb
hammer job-template export --id 139 > ocp_install.erb
hammer job-template export --id 141 > ocp_istio.erb
hammer job-template export --id 142 > ocp_node_post.erb
hammer job-template export --id 148 > ocp_node_post_snippet.erb
hammer job-template export --id 147 > ocp_node_pre_ga_snippet.erb
hammer job-template export --id 143 > ocp_nvidia.erb
```
##### # import the job templates
```
for i in `ls *.erb`; do hammer job-template import $i; done
```

##### # now connect to your satellite Web UI to configure you repos, content views, activation keys, and SDLC Library.