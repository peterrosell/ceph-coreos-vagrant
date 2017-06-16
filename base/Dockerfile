FROM ubuntu:16.04
#FROM blitznote/debootstrap-amd64:16.04

#ENV DEBIAN_FRONTEND noninteractive


# install common packages
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -yq curl net-tools sudo \
    && curl -sSL 'https://ceph.com/git/?p=ceph.git;a=blob_plain;f=keys/release.asc' | apt-key add - \
    && echo "deb http://download.ceph.com/debian-hammer xenial main" > /etc/apt/sources.list.d/ceph.list \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -yq \
<<<<<<< HEAD
        ceph=10.2.7-1xenial \
        ceph-common=10.2.7-1xenial \
        ceph-fuse=10.2.7-1xenial \
        ceph-mds=10.2.7-1xenial \
        librbd1=10.2.7-1xenial \
        python-rados=10.2.7-1xenial \
        python-cephfs=10.2.7-1xenial \
        python-rbd=10.2.7-1xenial \
        librados2=10.2.7-1xenial \
=======
        ceph=0.94.10-1xenial \
        ceph-common=0.94.10-1xenial \
        ceph-fuse=0.94.10-1xenial \
        ceph-mds=0.94.10-1xenial \
        librbd1=0.94.10-1xenial \
        python-rados=0.94.10-1xenial \
        python-cephfs=0.94.10-1xenial \
        python-rbd=0.94.10-1xenial \
        librados2=0.94.10-1xenial \
>>>>>>> 5d356c8... disable authx, base ubuntu16.04
     && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# install etcdctl
RUN VERSION=2.3.7 ; URL=$(curl https://github.com/coreos/etcd/releases/download/v$VERSION/etcd-v$VERSION-linux-amd64.tar.gz | \
   sed 's/.*href="\(.*\)".*/\1/g' | sed 's/\&amp\;/\&/g') ; \
   curl "$URL" | tar -zOx etcd-v$VERSION-linux-amd64/etcdctl > /usr/local/bin/etcdctl \
   && chmod +x /usr/local/bin/etcdctl

# install confd
RUN VERSION=0.11.0 ; URL=$(curl https://github.com/kelseyhightower/confd/releases/download/v$VERSION/confd-$VERSION-linux-amd64 | \
   sed 's/.*href="\(.*\)".*/\1/g' | sed 's/\&amp\;/\&/g') ; \
   curl "$URL" > /usr/local/bin/confd \
   && chmod +x /usr/local/bin/confd

# Add shared confd configuration
ADD . /app
