FROM python:3.5

USER root

ENV APP_DIR=/opt/tf

#RUN rpm -ivh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
RUN yum -y install python34-pip python34-devel gcc gcc-c++ && yum clean all
RUN pip3 install --no-cache-dir --upgrade pip
RUN pip3 install --no-cache-dir tensorflow-gpu
RUN pip3 install --no-cache-dir jupyter
RUN pip3 install --no-cache-dir matplotlib
RUN pip3 install --no-cache-dir keras

#setup dir
RUN mkdir -p $APP_DIR
COPY *.ipynb $APP_DIR/
COPY data $APP_DIR/data
COPY figures $APP_DIR/figures

WORKDIR "$APP_DIR"

# Set up our notebook config.
COPY jupyter_notebook_config.py /root/.jupyter/
COPY run_jupyter.sh /

EXPOSE 6006 8888

USER 1001

CMD /run_jupyter.sh --allow-root