#!/bin/bash
source "/vagrant/scripts/common.sh"

function disableFirewall {
	echo "disabling firewall"
	/sbin/iptables-save
	ufw disable
}

function installUtilities {
	echo "install utilities"

	# run docker command inside docker http://www.therightcode.net/run-docker-into-a-container-on-a-mac/
	# install docker in ubuntu http://docs.docker.com/installation/ubuntulinux/
	apt-get update -y
	apt-get install -y curl
	curl -sSL https://get.docker.com/ubuntu/ | sh
	# Configure docker daemon to bind to both TCP and domain socket
	echo 'DOCKER_OPTS="-H tcp://0.0.0.0:2375 -H unix:///var/run/docker.sock"' >> /etc/default/docker
	service docker restart

	# install swarm https://github.com/docker/swarm/ http://docs.docker.com/swarm/
	# http://docs.docker.com/swarm/discovery/ http://matthewkwilliams.com/index.php/2015/04/03/swarming-raspberry-pi-docker-swarm-discovery-options/
	apt-get install -y git cgdb bison

	FILE=/vagrant/resources/go1.4.linux-amd64.tar.gz
	if resourceExists go1.4.linux-amd64.tar.gz; then
		echo "install golang from local file"
	else
		curl -o $FILE -O -L https://storage.googleapis.com/golang/go1.4.linux-amd64.tar.gz
	fi
	tar -C /usr/local -xzf $FILE

	/bin/mkdir -p /usr/local/src/gocode; export GOPATH=/usr/local/src/gocode; export PATH=$PATH:/usr/local/go/bin:/usr/local/src/gocode/bin
	go get github.com/tools/godep
	
	cp -f /vagrant/resources/swarm/swarm.sh /etc/profile.d/swarm.sh
	chmod +x /etc/profile.d/swarm.sh
	/bin/mkdir -p /usr/local/src/gocode/src/github.com/docker/
	cd /usr/local/src/gocode/src/github.com/docker/
	git clone https://github.com/docker/swarm
	cd swarm
	# get latest stable tag
	git checkout v0.3.0-rc3
	#rm -rf Godeps/_workspace/src/github.com/samalba
	#rm -rf /usr/local/src/gocode/src/github.com/samalba
	godep go install .

	# install compose https://github.com/docker/compose/releases
	# https://docs.docker.com/compose/
	# https://github.com/docker/compose/blob/master/CONTRIBUTING.md
	curl https://bootstrap.pypa.io/ez_setup.py -o - | python
	apt-get install -y python2.7-dev libyaml-dev python-pip
	pip install docker-py "ipython[all]"
	curl -L https://github.com/docker/compose/releases/download/1.3.0rc3/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
	chmod +x /usr/local/bin/docker-compose
	curl -L https://raw.githubusercontent.com/docker/compose/1.2.0/contrib/completion/bash/docker-compose > /etc/bash_completion.d/docker-compose
}
echo "setup ubuntu"

disableFirewall
installUtilities