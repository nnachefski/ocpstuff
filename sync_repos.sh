export REPODIR=/var/www/html/repo

# rhel-server-rhscl-7-rpms
for repo in nvidia rhel-7-fast-datapath-rpms rhel-7-server-ose-3.7-rpms rhel-server-rhscl-7-rpms rhel-7-server-optional-rpms rh-gluster-3-for-rhel-7-server-rpms rhel-7-server-extras-rpms rhel-7-server-rpms epel;
do
  echo "############## ${repo} ##################"
  reposync --gpgcheck -lm --repoid=${repo} --download_path=$REPODIR
  createrepo $REPODIR/${repo}
done


