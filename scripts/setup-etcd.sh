#!/bin/bash
source "/vagrant/scripts/common.sh"

#https://github.com/coreos/etcd/releases/

function setupetcd {
	echo "creating etcd environment variables"
	cp -f $ETCD_RES_DIR/etcd.sh /etc/profile.d/etcd.sh
}

function installetcd {
	echo "install etcd"
	FILE=/vagrant/resources/$ETCD_ARCHIVE
	if resourceExists $ETCD_ARCHIVE; then
		echo "install etcd from local file"
	else
		curl -o $FILE -O -L $ETCD_MIRROR_DOWNLOAD
	fi
	tar -xzf $FILE -C /usr/local
	ln -s /usr/local/etcd-$ETCD_VERSION-linux-amd64 /usr/local/etcd
}


echo "setup etcd"
installetcd
setupetcd

