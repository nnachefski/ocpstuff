FROM rhel7-custom:latest

ENV DAQ_VERSION 2.0.6 \
    SNORT_VERSION 2.9.9.0

RUN yum -y install \
 https://www.snort.org/downloads/archive/snort/daq-${DAQ_VERSION}-1.centos7.x86_64.rpm \
 https://www.snort.org/downloads/archive/snort/snort-openappid-${SNORT_VERSION}-1.centos7.x86_64.rpm

RUN ln -s /usr/lib64/snort-${SNORT_VERSION}_dynamicengine \
       /usr/local/lib/snort_dynamicengine && \
    ln -s /usr/lib64/snort-${SNORT_VERSION}_dynamicpreprocessor \
       /usr/local/lib/snort_dynamicpreprocessor

# Cleanup.
RUN yum clean all && \
    rm -rf /var/log/* || true \
    rm -rf /var/tmp/* \
    rm -rf /tmp/*

RUN /usr/sbin/snort -V