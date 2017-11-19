FROM registry.access.redhat.com/rhel7.4

ENV TEST_FILE_NAME=somefile.txt

RUN echo "testing…" > /etc/test.txt
COPY $TEST_FILE_NAME /tmp/

CMD sleep 60