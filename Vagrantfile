Vagrant.require_version ">= 1.4.3"
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
	numNodes = 3
	r = numNodes..1
	(r.first).downto(r.last).each do |i|
		config.vm.define "mesosnode#{i}" do |node|
			node.vm.box = "centos65"
			node.vm.box_url = "https://github.com/2creatives/vagrant-centos/releases/download/v6.5.3/centos65-x86_64-20140116.box"
			node.vm.provider "virtualbox" do |v|
			    v.name = "mesosnode#{i}"
			    v.customize ["modifyvm", :id, "--memory", "1536"]
			    if i == 1
			        v.customize ["modifyvm", :id, "--memory", "2048"]
			    end
			end
			if i < 10
				node.vm.network :private_network, ip: "10.211.56.10#{i}"
			else
				node.vm.network :private_network, ip: "10.211.56.1#{i}"
			end
			node.vm.hostname = "mesosnode#{i}"
			node.vm.provision "shell", path: "scripts/setup-centos.sh"
			node.vm.provision "shell", path: "scripts/setup-centos-ntp.sh"
			node.vm.provision "shell" do |s|
				s.path = "scripts/setup-centos-hosts.sh"
				s.args = "-t #{numNodes}"
			end
			if i != 1
				node.vm.provision "shell", path: "scripts/setup-mesosslave.sh"
			end
			if i == 1
				node.vm.provision "shell" do |s|
					s.path = "scripts/setup-centos-ssh.sh"
					s.args = "-s 2 -t #{numNodes}"
				end
				node.vm.provision "shell", path: "scripts/setup-zookeeper.sh"
				node.vm.provision "shell", path: "scripts/setup-mesos.sh"
			end
		end
	end
end