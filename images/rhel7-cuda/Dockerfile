FROM registry.access.redhat.com/rhel7.4

#ENV DNN=http://repo.home.nicknach.net/repo/nvidia/cudnn-8.0-linux-x64-v6.0.tgz \
	CUDA=cuda-8-0

ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility
ENV NVIDIA_REQUIRE_CUDA="cuda>=8.0" 
	
#RUN yum -y install wget cmake gcc gcc-c++ git make patch pciutils unzip vim-enhanced && yum clean all
#RUN yum -y install $CUDA && yum clean all

#RUN wget -q $DNN -O /tmp/cudnn.tar.gz

#RUN export CUDA_HOME="/usr/local/cuda" CUDA_PATH="${CUDA_HOME}" PATH="${CUDA_HOME}/bin${PATH:+:${PATH}}" LD_LIBRARY_PATH="${CUDA_HOME}/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}"; 
#RUN echo -e 'export CUDA_HOME=/usr/local/cuda \nexport CUDA_PATH=${CUDA_HOME} \nexport PATH=${CUDA_HOME}/bin:${PATH} \nexport LD_LIBRARY_PATH=${CUDA_HOME}/lib64:/usr/local/lib:$LD_LIBRARY_PATH \n' >> ~/.bashrc;
#RUN cd /tmp && tar -C /usr/local -xf /tmp/cudnn.tar.gz && /bin/rm /tmp/cudnn.tar.gz
#RUN ldconfig
#RUN nvidia-smi
CMD sleep 60