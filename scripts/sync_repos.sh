## this script is used to syncronize my local repo server with the upstream RHN repos.  Cron this to run nightly

export REPODIR=repo

for repo in rh-gluster-3-client-for-rhel-7-server-rpms rhel-7-server-ose-3.9-rpms rhel-7-server-rpms rhel-7-fast-datapath-rpms rhel-server-rhscl-7-rpms rhel-7-server-optional-rpms rh-gluster-3-for-rhel-7-server-rpms rhel-7-server-extras-rpms epel nvidia;
do
  echo "############## ${repo} ##################"
  reposync --gpgcheck -lm --repoid=${repo} --download_path=$REPODIR
  createrepo $REPODIR/${repo}
done


