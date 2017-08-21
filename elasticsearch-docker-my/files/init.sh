#!/bin/bash
yum clean all
yum makecache
yum install -y net-tools wget tree unzip sudo
echo "192.168.31.185 soft.home" >> /etc/hosts
mkdir /root/soft
wget -O /root/soft/jdk-8u144-linux-x64.rpm http://soft.home/jdk-8u144-linux-x64.rpm
rpm -ivh /root/soft/jdk-8u144-linux-x64.rpm
JAVA_HOME=/usr/java/jdk1.8.0_144
PATH=$PATH:$JAVA_HOME/bin:$JAVA_HOME/jre/lib 
CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
export JAVA_HOME PATH CLASSPATH
echo "JAVA_HOME=/usr/java/jdk1.8.0_144" >> /root/.bash_profile
echo "PATH=$PATH:$JAVA_HOME/bin:$JAVA_HOME/jre/lib " >> /root/.bash_profile
echo "CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar" >> /root/.bash_profile
echo "export JAVA_HOME PATH CLASSPATH" >> /root/.bash_profile
echo "alias vim=vi" >> /root/.bash_profiles

echo "* soft nofile 65536" >> /etc/security/limits.conf
echo "* hard nofile 65536" >> /etc/security/limits.conf
echo "* soft nproc  2048"  >> /etc/security/limits.conf
echo "* hard nproc  2048"  >> /etc/security/limits.conf
echo "vm.max_map_count=262144"   >> /etc/sysctl.conf
sysctl -w vm.max_map_count=262144
groupadd elasticsearch
useradd elasticsearch -g elasticsearch -p vagrant
mkdir -p /home/elasticsearch
cd /home/elasticsearch
wget http://soft.home/elasticsearch-5.5.1.zip
unzip elasticsearch-5.5.1.zip
sed -i 's/-Xms2g/-Xms256m/' /home/elasticsearch/elasticsearch-5.5.1/config/jvm.options
sed -i 's/-Xmx2g/-Xmx256m/' /home/elasticsearch/elasticsearch-5.5.1/config/jvm.options
echo "http.host: 0.0.0.0" >> /home/elasticsearch/elasticsearch-5.5.1/config/elasticsearch.yml
chown -R elasticsearch:elasticsearch /home/elasticsearch