export ANSIBLE_HOST_KEY_CHECKING=False
curl http://satellite.home.nicknach.net/pub/hosts_libvirt > hosts
curl http://satellite.home.nicknach.net/pub/prep.sh > prep.sh && chmod +x prep.sh
./prep.sh
mv hosts /etc/ansible -f
ansible "*" -m script -a "./prep.sh"

ansible-playbook /usr/share/ansible/openshift-ansible/playbooks/prerequisites.yml

