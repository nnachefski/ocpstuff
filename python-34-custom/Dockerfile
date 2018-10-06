FROM rhel7-custom

USER 1001

ENV SKIP_REPOS_ENABLE=true \
SKIP_REPOS_DISABLE=true

RUN yum install -y -d1 python34 python34-pip python34
RUN pip3 install --upgrade pip
