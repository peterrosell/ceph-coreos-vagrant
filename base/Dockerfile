FROM ubuntu-debootstrap:14.04

ENV DEBIAN_FRONTEND noninteractive


# install common packages
RUN apt-get update && apt-get install -yq curl net-tools sudo

RUN curl -sSL 'https://ceph.com/git/?p=ceph.git;a=blob_plain;f=keys/release.asc' | apt-key add - \
   && echo "deb http://ceph.com/debian-giant trusty main" > /etc/apt/sources.list.d/ceph.list \
   && apt-get update 

RUN apt-get install -yq ceph

# install etcdctl
RUN VERSION=2.0.10 ; URL=$(curl https://github.com/coreos/etcd/releases/download/v$VERSION/etcd-v$VERSION-linux-amd64.tar.gz | \
   sed 's/.*href="\(.*\)".*/\1/g' | sed 's/\&amp\;/\&/g') ; \
   curl "$URL" | tar -zOx etcd-v$VERSION-linux-amd64/etcdctl > /usr/local/bin/etcdctl \
   && chmod +x /usr/local/bin/etcdctl

# install confd
RUN VERSION=0.9.0 ; URL=$(curl https://github.com/kelseyhightower/confd/releases/download/v$VERSION/confd-$VERSION-linux-amd64 | \
   sed 's/.*href="\(.*\)".*/\1/g' | sed 's/\&amp\;/\&/g') ; \
   curl "$URL" > /usr/local/bin/confd \
   && chmod +x /usr/local/bin/confd

# Add shared confd configuration
ADD . /app
