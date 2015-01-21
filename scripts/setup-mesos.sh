#!/bin/bash
source "/vagrant/scripts/common.sh"

#http://mesosphere.com/docs/getting-started/datacenter/install/

function setupMesos {
	echo "zk://mesosnode1:2181/mesos" >> /etc/mesos/zk
	echo "1" >> /etc/mesos-master/quorum
	update-rc.d -f mesos-slave remove
}

function installMesos {
	rpm -Uvh http://repos.mesosphere.io/el/6/noarch/RPMS/mesosphere-el-repo-6-2.noarch.rpm
	yum install -y mesos marathon
}


echo "setup mesos"
installMesos
setupMesos
