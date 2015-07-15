vagrant-mesos-swarm-latest on Ubuntu 14.04
================================

# Introduction

Vagrant project to spin up a cluster of 6 virtual machines with docker latest (1.5.0), swarm v0.3.0-rc3, spark v1.4.0, compose 1.2.0rc3, zookeepr r3.4.5, mesos latest (0.22.0), marathon (0.8.1) and chronos (2.3.2).

1. mesosnode1 : zookeeper + mesos master + marathon + chronos
2. mesosnode2 : mesos slave with docker
3. mesosnode3 : mesos slave with docker
4. mesosnode4 : mesos slave with docker
5. mesosnode5 : mesos slave with docker
6. mesosnode6 : mesos slave with docker

TODO: Kubernetes-Mesos (https://github.com/mesosphere/kubernetes-mesos)

TODO: Mesos-DNS https://mesosphere.github.io/mesos-dns/docs/

TODO: Weave-DNS, Consul DNS, Sky-DNS

# Getting Started

1. [Download and install VirtualBox](https://www.virtualbox.org/wiki/Downloads)
2. [Download and install Vagrant](http://www.vagrantup.com/downloads.html).
3. Run ```vagrant box add Ubuntu https://oss-binaries.phusionpassenger.com/vagrant/boxes/latest/ubuntu-14.04-amd64-vbox.box```
4. Git clone this project, and change directory (cd) into this project (directory).
5. Run ```vagrant up``` to create the VM.
6. Run ```vagrant ssh``` to get into your VM. The VM name in vagrant is mesosnode1, mesosnode2 ... mesosnoden. While the ip of VMs depends on the scale of your mesos cluster. If it is less then 10, the IP will be 10.211.56.101, .... 10.211.56.10n. Or you could run ```ssh``` directly with ip of VMs and username/password of demo/demo, and then execute "su - root" with password of vagrant.
7. Run ```vagrant destroy``` when you want to destroy and get rid of the VM.
8. The directory of /vagrant is mounted in each VM by vagrant if you want to access host machine from VM. You could also use win-sshfs if you want to access the local file system of VM from host machine. Please refer to http://code.google.com/p/win-sshfs/ for details.

Some gotcha's.

* Make sure you download Vagrant v1.7.1 or higher and VirtualBox 4.3.20 or higher with extension package
* Make sure when you clone this project, you preserve the Unix/OSX end-of-line (EOL) characters. The scripts will fail with Windows EOL characters. If you are using Windows, please make sure the following configuration is configured in your .gitconfig file which is located in your home directory ("C:\Users\yourname" in Win7 and after, and "C:\Documents and Settings\yourname" in WinXP). Refer to http://git-scm.com/book/en/v2/Customizing-Git-Git-Configuration for details of git configuration.
```
[core]
    autocrlf = false
    safecrlf = true
```
* Make sure you have 10Gb of free memory for the VMs. You may change the Vagrantfile to specify smaller memory requirements.
* This project has NOT been tested with the other providers such as VMware for Vagrant.
* You may change the script (common.sh) to point to a different location for etcd, kubernetes to be downloaded from.

# Advanced Stuff

If you have the resources (CPU + Disk Space + Memory), you may modify Vagrantfile to have even more mesos slave. Just find the line that says "numNodes = 6" in Vagrantfile and increase that number. The scripts should dynamically provision the additional slaves for you.

# Start mesos Cluster

## Start Zookeeper

SSH into mesosnode1 and run the following command to start Zookeeper.

```
/usr/share/zookeeper/bin/zkServer.sh start
```

### Test Zookeeper
Run the following command to make sure you can connect Zookeeper. Refer to http://zookeeper.apache.org/doc/r3.4.6/zookeeperStarted.html for more details

```
/usr/share/zookeeper/bin/zkCli.sh -server mesosnode1:2181
```

Or Run following command to send command to Zookeeper. Refer to https://zookeeper.apache.org/doc/r3.4.6/zookeeperAdmin.html#sc_zkCommands for more details

```
echo ruok | nc mesosnode1 2181
```

## Start mesos

SSH into mesosnode1 and run the following command to start mesos master.

```
setsid /usr/bin/mesos-init-wrapper master
setsid /usr/bin/marathon
setsid /usr/bin/chronos
```

SSH into other nodes and run the following command to start mesos slave.

```
setsid /usr/bin/mesos-init-wrapper slave
```

Please refer to https://github.com/deric/mesos-deb-packaging/blob/master/mesos-init-wrapper for how to configure parameters when start mesos master or slave.

Please refer to http://mesosphere.github.io/marathon/docs/command-line-flags.html for how to configure parameters when start marathon.

### Test mesos

Access http://10.211.56.101:5050/ for GUI of mesos.

Please refer to http://mesos.apache.org/gettingstarted/ for how to build and run mesos example on Ubuntu 14.04

### Test marathon

Access http://10.211.56.101:8080/ for GUI of marathon.

Follow the examples in https://github.com/mesosphere/marathon/tree/master/examples to test the marathon.

Run the following command to create a docker application with specification of docker.json

```
curl -X POST -H "Content-Type: application/json" http://mesosnode1:8080/v2/apps -d@docker.json
```

Run the following command to query and delete the application

```
curl -X GET -H "Content-Type: application/json" mesosnode1:8080/v2/apps | python -m json.tool
curl -X DELETE -H "Content-Type: application/json" mesosnode1:8080/v2/apps/${appid} | python -m json.tool
```

Please refer to http://mesosphere.github.io/marathon/docs/rest-api.html for all the REST API of marathon.

Please refer to http://mesosphere.github.io/marathon/docs/constraints.html for constraints of marathon.

Please refer to http://mesosphere.github.io/marathon/docs/native-docker.html for how to create docker application in marathon.

### Test chronos

Access http://10.211.56.101:4400/ for GUI of chronos.

Please refer to https://github.com/mesos/chronos for more details of chronos

# Start Spark on Mesos

## Cluster Mode

Run the following command to start Spark framework on Mesos with cluster mode

```
/usr/local/spark/sbin/start-mesos-dispatcher.sh -m mesos://mesosnode1:5050
```

After that submit Spark job to mesos-dispatcher as follows

```
spark-submit --deploy-mode cluster --master mesos://mesosnode1:7077  --executor-memory 512m --executor-cores 1 --class org.apache.spark.examples.SparkPi $SPARK_HOME/lib/spark-examples-1.4.0-hadoop2.6.0.jar 100
```

By default Spark scheduler works with fine grain mode. Within fine grain mode, when Spark driver gets offer from Mesos, it will try to dispatch pending task to the offer. Each task consumes cpu of spark.task.cpus. If there is no executor in the offer, Spark will ask Mesos to create spark executor first with memory of "max(OVERHEAD_FRACTION * sc.executorMemory, OVERHEAD_MINIMUM) + sc.executorMemory" (By default, it will be 512m + 384m) and cpu of spark.mesos.mesosExecutor.cores. 

To configure coarse mode, configure "spark.mesos.coarse true" in spark-defaults.conf. Within coarse mode, when Spark driver gets offers from Mesos, it will try to start executor with memory of "max(OVERHEAD_FRACTION * sc.executorMemory, OVERHEAD_MINIMUM) + sc.executorMemory" (By default, it will be 512m + 384m) and cpu of all the allocated cpu. 

Mesos executor will try to find spark binaries by $SPARK_HOME or user could define spark.mesos.executor.home as "/usr/local/spark" in /usr/local/spark/conf/spark-defaults.conf. Please refer to https://spark.apache.org/docs/latest/running-on-mesos.html for more configuration parameters. 

## Client Mode

Run the following command to start a Spark client on Mesos with client mode

```
spark-shell --master mesos://mesosnode1:5050
```

or

```
spark-submit --master mesos://mesosnode1:5050 --executor-memory 512m --executor-cores 1 --class org.apache.spark.examples.SparkPi $SPARK_HOME/lib/spark-examples-1.4.0-hadoop2.6.0.jar 100
```

Access http://10.211.56.101:4040 for Spark GUI if above command is executed in mesosnode1. 

Mesos executor will try to find spark binaries by $SPARK_HOME or user could define spark.mesos.executor.home as "/usr/local/spark" in /usr/local/spark/conf/spark-defaults.conf. Please refer to https://spark.apache.org/docs/latest/running-on-mesos.html for more configuration parameters. 

# Start Swarm on Mesos

Run the following command to start Swarm on Mesos

```
swarm manage -c mesos-experimental --cluster-opt mesos.address=10.211.56.101 --cluster-opt mesos.port=3375 --host 10.211.56.101:4375  10.211.56.101:5050
```

Run the following command to verify the Swarm on Mesos

```
docker -H tcp://10.211.56.101:4375 info
docker -H tcp://10.211.56.101:4375 run -d -m 300M -c 1 --name sleep ubuntu /bin/sleep 1000000000
```

https://github.com/docker/swarm/tree/master/cluster/mesos

https://github.com/docker/swarm/

http://docs.docker.com/swarm/

http://docs.docker.com/swarm/discovery/

http://matthewkwilliams.com/index.php/2015/04/03/swarming-raspberry-pi-docker-swarm-discovery-options/

# Start Compose

https://docs.docker.com/compose/

# Start etcd

setsid /usr/local/etcd/etcd --listen-peer-urls 'http://10.211.62.101:2380,http://10.211.62.101:7001' --listen-client-urls 'http://10.211.62.101:2379,http://10.211.62.101:4001' --advertise-client-urls 'http://10.211.62.101:2379,http://10.211.62.101:4001' >"/tmp/etcd.log" 2>&1 &

# Test etcd

Run the following command to make sure etcd works

```
etcdctl --peers 10.211.62.101:4001 set key1 value1
```

Refer to https://github.com/coreos/etcd/blob/master/Documentation/admin_guide.md for more info of etcd

# Go programming

goclipse: http://goclipse.googlecode.com/svn/trunk/goclipse-update-site/

golang: https://golang.org/doc/

## Start Weave

### Weave DNS

http://weave.works/guides/weave-docker-ubuntu-simple.htm
http://weave.works/guides/weave-docker-coreos-simple.html