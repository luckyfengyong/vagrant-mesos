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
	echo 'docker,mesos' > /etc/mesos-slave/containerizers
	echo '5mins' > /etc/mesos-slave/executor_registration_timeout
	echo 'resources=cpus(*):8; mem(*):15360; disk(*):710534; ports(*):[31000-32000]' > /etc/mesos-slave/resources
}

function installMesos {
	echo "install mesos"
    #https://mesosphere.com/docs/tutorials/install_ubuntu_debian/#step-0 http://mesos.apache.org/gettingstarted/
	sudo apt-key adv --keyserver keyserver.ubuntu.com --recv E56151BF
	DISTRO=$(lsb_release -is | tr '[:upper:]' '[:lower:]')
	CODENAME=$(lsb_release -cs)
	echo "deb http://repos.mesosphere.io/${DISTRO} ${CODENAME} main" |  sudo tee /etc/apt/sources.list.d/mesosphere.list
	apt-get -y update
	apt-get -y install mesos marathon chronos
	
	#for centos
	#rpm -Uvh http://repos.mesosphere.io/el/6/noarch/RPMS/mesosphere-el-repo-6-2.noarch.rpm
	#yum install -y mesos
	#if resourceExists $MESOS_ARCHIVE; then
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
}

echo "setup mesos"
installMesos
setupMesos
