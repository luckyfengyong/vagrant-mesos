#!/bin/bash

#ssh
SSH_RES_DIR=/vagrant/resources/ssh
RES_SSH_COPYID_ORIGINAL=$SSH_RES_DIR/ssh-copy-id.original
RES_SSH_COPYID_MODIFIED=$SSH_RES_DIR/ssh-copy-id.modified
RES_SSH_CONFIG=$SSH_RES_DIR/config
#zookeeper
ZOOKEEPER_PREFIX=/usr/local/zookeeper
ZOOKEEPER_CONF=$ZOOKEEPER_PREFIX/conf
ZOOKEEPER_VERSION=zookeeper-3.4.6
ZOOKEEPER_ARCHIVE=$ZOOKEEPER_VERSION.tar.gz
ZOOKEEPER_MIRROR_DOWNLOAD=http://apache.mirror.rafal.ca/zookeeper/stable/$ZOOKEEPER_ARCHIVE
ZOOKEEPER_RES_DIR=/vagrant/resources/zookeeper
#mesos
MESOS_VERSION=0.21.1
MESOS_ARCHIVE=mesos-$MESOS_VERSION.tar.gz
MESOS_MIRROR_DOWNLOAD=http://www.apache.org/dist/mesos/$MESOS_VERSION/$MESOS_ARCHIVE
K8SMESOS_RES_DIR=/vagrant/resources/k8smesos
#etcd
ETCD_PREFIX=/usr/local/etcd
ETCD_VERSION=v2.0.12
ETCD_ARCHIVE=etcd-$ETCD_VERSION-linux-amd64.tar.gz
ETCD_MIRROR_DOWNLOAD=https://github.com/coreos/etcd/releases/download/$ETCD_VERSION/$ETCD_ARCHIVE
ETCD_RES_DIR=/vagrant/resources/etcd
#java
JAVA_ARCHIVE=jdk-7u76-linux-x64.tar.gz
#ant
ANT_ARCHIVE=apache-ant-1.9.5-bin.zip
ANT_MIRROR_DOWNLOAD=http://mirror.sdunix.com/apache/ant/binaries/$ANT_ARCHIVE
#maven
MAVEN_ARCHIVE=apache-maven-3.2.5-bin.zip
MAVEN_MIRROR_DOWNLOAD=http://apache.mirror.rafal.ca/maven/maven-3/3.2.5/binaries/$MAVEN_ARCHIVE
#scala
SCALA_VERSION=scala-2.11.6
SCALA_ARCHIVE=$SCALA_VERSION.tgz
SCALA_MIRROR_DOWNLOAD=http://www.scala-lang.org/files/archive/$SCALA_ARCHIVE
SCALA_RES_DIR=/vagrant/resources/scala
#zookeeper
ZOOKEEPER_PREFIX=/usr/local/zookeeper
ZOOKEEPER_CONF=$ZOOKEEPER_PREFIX/conf
ZOOKEEPER_VERSION=zookeeper-3.4.6
ZOOKEEPER_ARCHIVE=$ZOOKEEPER_VERSION.tar.gz
ZOOKEEPER_MIRROR_DOWNLOAD=http://apache.mirror.rafal.ca/zookeeper/stable/$ZOOKEEPER_ARCHIVE
ZOOKEEPER_RES_DIR=/vagrant/resources/zookeeper
#spark
SPARK_VERSION=spark-1.4.0-bin-hadoop2.6
SPARK_ARCHIVE=$SPARK_VERSION.tgz
SPARK_MIRROR_DOWNLOAD=http://www.apache.org/dist/spark/spark-1.4.0/$SPARK_ARCHIVE
SPARK_RES_DIR=/vagrant/resources/spark
function resourceExists {
	FILE=/vagrant/resources/$1
	if [ -e $FILE ]
	then
		return 0
	else
		return 1
	fi
}

function fileExists {
	FILE=$1
	if [ -e $FILE ]
	then
		return 0
	else
		return 1
	fi
}

#echo "common loaded"
