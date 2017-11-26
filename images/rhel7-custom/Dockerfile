FROM registry.access.redhat.com/rhel7.4

ENV TEST_FILE_NAME=somefile.txt

RUN echo "testing…" > /etc/test.txt
COPY $TEST_FILE_NAME /tmp/

COPY repo.home.nicknach.net_repo_rhel-7-server-rpms.repo /etc/yum.repos.d/

RUN rpm --import http://repo.home.nicknach.net/keys/RPM-GPG-KEY-redhat-release
RUN rpm --import http://repo.home.nicknach.net/keys/RPM-GPG-KEY-EPEL-7
RUN rpm --import http://repo.home.nicknach.net/keys/7fa2af80.pub

CMD sleep 60