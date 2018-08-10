FROM openshift/rhel7-custom:latest

ENV DNN=http://repo.home.nicknach.net/repo/misc/cudnn-9.0-linux-x64-v7.1.tgz \
CUDA=cuda-9-0 \
NVIDIA_VISIBLE_DEVICES=0 \
NVIDIA_DRIVER_CAPABILITIES="compute,utility" \
NVIDIA_REQUIRE_CUDA="cuda>=9.0"

USER root

RUN yum install -y kernel kernel-devel kernel-headers

RUN yum -y install wget cmake gcc gcc-c++ git make patch pciutils unzip vim-enhanced && yum clean all

RUN export CUDA_HOME="/usr/local/cuda" CUDA_PATH="${CUDA_HOME}" PATH="${CUDA_HOME}/bin${PATH:+:${PATH}}" LD_LIBRARY_PATH="${CUDA_HOME}/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}"; 
RUN echo -e 'export CUDA_HOME=/usr/local/cuda \nexport CUDA_PATH=${CUDA_HOME} \nexport PATH=${CUDA_HOME}/bin:${PATH} \nexport LD_LIBRARY_PATH=${CUDA_HOME}/lib64:/usr/local/lib:$LD_LIBRARY_PATH \n' >> ~/.bashrc;

RUN yum -y install $CUDA && yum clean all

RUN ldconfig
RUN wget -q $DNN -O /tmp/cudnn.tar.gz
RUN cd /tmp && tar -C /usr/local -xf /tmp/cudnn.tar.gz && /bin/rm /tmp/cudnn.tar.gz
