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

	# install swarm https://github.com/docker/swarm/ http://docs.docker.com/swarm/
	# http://docs.docker.com/swarm/discovery/ http://matthewkwilliams.com/index.php/2015/04/03/swarming-raspberry-pi-docker-swarm-discovery-options/
	apt-get install -y golang git
	/bin/mkdir -p /usr/local/src/gocode; export GOPATH=/usr/local/src/gocode; export PATH=${GOPATH}/bin:${PATH}
	cp -f /vagrant/resources/swarm/swarm.sh /etc/profile.d/swarm.sh
	chmod +x /etc/profile.d/swarm.sh
	go get github.com/tools/godep
	/bin/mkdir -p /usr/local/src/gocode/src/github.com/docker/
	cd /usr/local/src/gocode/src/github.com/docker/
	git clone https://github.com/docker/swarm
	cd swarm
	# get latest stable tag
	git checkout v0.2.0-rc2
	#rm -rf Godeps/_workspace/src/github.com/samalba
	#rm -rf /usr/local/src/gocode/src/github.com/samalba
	godep go install .

	# install compose https://github.com/docker/compose/releases
	# https://docs.docker.com/compose/
	curl -L https://github.com/docker/compose/releases/download/1.2.0rc3/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
	chmod +x /usr/local/bin/docker-compose
	curl -L https://raw.githubusercontent.com/docker/compose/1.2.0rc3/contrib/completion/bash/docker-compose > /etc/bash_completion.d/docker-compose
}
echo "setup ubuntu"

disableFirewall
installUtilities