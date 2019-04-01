FROM rhel7-custom:latest
## maintained by nnachefski@gmail.com

ENV APP_DIR=/opt/ethminer
ENV APP_VER=0.14.0
ENV STRATUM_P=us2.ethermine.org:4444
ENV STRATUM_S=us2.ethermine.org:14444
ENV WALLET_ID=0x4B17d141c77327978Ff9998205145F68216294Fd
ENV NODEID=ocp
ENV DEBUG=1

RUN yum -y install openssl-devel gmp-devel libffi libtool wget git libcurl-devel python-jsonrpclib.noarch libmicrohttpd && yum clean all

#setup dir
RUN mkdir -p $APP_DIR
WORKDIR "$APP_DIR"

COPY install_deps.sh .
RUN ./install_deps.sh
#RUN yum -y install boost-devel

RUN wget -q https://github.com/ethereum-mining/ethminer/releases/download/v$APP_VER/ethminer-$APP_VER-Linux.tar.gz
RUN tar -xzvf ethminer-*.tar.gz && cp bin/ethminer . && chmod +x ethminer && rm -rf ethminer-*.Linux.tar.gz

# GPU tuning
ENV GPU_FORCE_64BIT_PTR=0
ENV GPU_MAX_HEAP_SIZE=100
ENV GPU_USE_SYNC_OBJECTS=1
ENV GPU_MAX_ALLOC_PERCENT=100
ENV GPU_SINGLE_ALLOC_PERCENT=100

CMD ./ethminer -U --farm-recheck 200 -S $STRATUM_P -FS $STRATUM_S -O $WALLET_ID.$HOSTNAME -v $DEBUG
