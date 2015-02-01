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
	rm -rf /etc/init//etc/init/chronos.conf
	mkdir -p /etc/marathon/conf
	echo '604800' > /etc/marathon/conf/task_launch_timeout
}

function installMesos {
	rpm -Uvh http://repos.mesosphere.io/el/6/noarch/RPMS/mesosphere-el-repo-6-2.noarch.rpm
	yum install -y mesos marathon chronos
	if resourceExists $MESOS_ARCHIVE; then
		echo "install mesos example from remote file"
	else
		curl -o /vagrant/resources/$MESOS_ARCHIVE -O -L $MESOS_MIRROR_DOWNLOAD
	fi
	tar -xzf /vagrant/resources/$MESOS_ARCHIVE -C /usr/local
	ln -s /usr/local/mesos-$MESOS_VERSION /usr/local/mesos
	# update device-mapper otherwise docker fail to start
	yum -y update
	service docker start
	chkconfig docker on	
}

echo "setup mesos"
installMesos
setupMesos
