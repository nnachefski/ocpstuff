FROM registry.access.redhat.com/rhel7.4

ENV KEYS_URL=http://repo.home.nicknach.net/keys

COPY repofiles/*.repo /etc/yum.repos.d/

RUN rpm --import $KEYS_URL/RPM-GPG-KEY-redhat-release
RUN rpm --import $KEYS_URL/RPM-GPG-KEY-EPEL-7
RUN rpm --import $KEYS_URL/7fa2af80.pub

CMD sleep 60