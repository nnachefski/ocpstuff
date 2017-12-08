FROM registry.access.redhat.com/rhel7.4

ENV KEYS_URL=http://repo.home.nicknach.net/keys

COPY repos/*.repo /etc/yum.repos.d/
COPY certs/*.crt /etc/pki/ca-trust/source/
COPY gpgkeys/* /etc/pki/rpm-gpg/ 

RUN rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release
RUN rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7
RUN rpm --import /etc/pki/rpm-gpg/7fa2af80.pub

CMD sleep 60