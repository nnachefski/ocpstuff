## cleanup Openshift NFS mounts
DIR=/data/openshift/enterprise

for i in `ls $DIR`; do rm -rf $DIR/$i/*; done
rm -rf $DIR/metrics/.*
du -sh $DIR/*

