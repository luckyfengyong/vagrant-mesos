#!/bin/bash
source "/vagrant/scripts/common.sh"

#http://mesosphere.com/docs/getting-started/datacenter/install/
#/usr/bin/mesos-init-wrapper

function setupMesos {
	echo "zk://mesosnode1:2181/mesos" > /etc/mesos/zk
	echo "1" > /etc/mesos-master/quorum
	#disable auto start of upstart
	rm -rf /etc/init/mesos-master.conf
	rm -rf /etc/init/marathon.conf
	rm -rf /etc/init/mesos-slave.conf
	rm -rf /etc/init/chronos.conf
	mkdir -p /etc/marathon/conf
	echo '604800' > /etc/marathon/conf/task_launch_timeout
	#cp -f $K8SMESOS_RES_DIR/k8smesos.sh /etc/profile.d/k8smesos.sh
}

function installMesos {
	echo "install mesos"
    #https://mesosphere.com/docs/tutorials/install_ubuntu_debian/#step-0 http://mesos.apache.org/gettingstarted/
	sudo apt-key adv --keyserver keyserver.ubuntu.com --recv E56151BF
	DISTRO=$(lsb_release -is | tr '[:upper:]' '[:lower:]')
	CODENAME=$(lsb_release -cs)
	echo "deb http://repos.mesosphere.io/${DISTRO} ${CODENAME} main" |  sudo tee /etc/apt/sources.list.d/mesosphere.list
	apt-get -y update
	#to build mesos source code/framework http://mesos.apache.org/gettingstarted/
	apt-get -y install openjdk-7-jdk
	apt-get -y install g++
	apt-get -y install autoconf libtool
	apt-get -y install build-essential python-dev python-boto libcurl4-nss-dev libsasl2-dev maven libapr1-dev libsvn-dev
	apt-get -y install mesos marathon chronos
	
	# for centos
	# rpm -Uvh http://repos.mesosphere.io/el/6/noarch/RPMS/mesosphere-el-repo-6-2.noarch.rpm
	# yum install -y mesos marathon chronos
	# if resourceExists $MESOS_ARCHIVE; then
	#	echo "install mesos example from remote file"
	#else
	#	curl -o /vagrant/resources/$MESOS_ARCHIVE -O -L $MESOS_MIRROR_DOWNLOAD
	#fi
	#tar -xzf /vagrant/resources/$MESOS_ARCHIVE -C /usr/local
	#ln -s /usr/local/mesos-$MESOS_VERSION /usr/local/mesos
	# update device-mapper otherwise docker fail to start
	#yum -y update
	#service docker start
	#chkconfig docker on
	
	# install development environment for kubernetes-mesos
	# https://github.com/mesosphere/kubernetes-mesos/blob/master/DEVELOP.md
	# https://github.com/mesosphere/kubernetes-mesos
	#yum install -y golang
	#curl -L https://protobuf.googlecode.com/files/protobuf-2.5.0.tar.gz | \
	#tar xz && (cd protobuf-2.5.0/ && ./configure --prefix=/usr && make && make install)
	#mkdir -pv /usr/local/gocode && \
	#(export GOPATH=/usr/local/gocode; cd $GOPATH && go get github.com/tools/godep && \
	#ln -sv $GOPATH/bin/godep /usr/local/bin/godep)
	#cd $GOPATH
	#mkdir -p src/github.com/mesosphere/kubernetes-mesos
	#git clone https://github.com/mesosphere/kubernetes-mesos.git src/github.com/mesosphere/kubernetes-mesos
	#cd src/github.com/mesosphere/kubernetes-mesos
	#make bootstrap
}

echo "setup mesos"
installMesos
setupMesos
