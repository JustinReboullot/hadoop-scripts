#!/bin/bash
set -e
set -x

# Except specified otherwise, everything is runned by hduser
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
[ $(whoami) = hduser ] || exec sudo -u hduser $DIR/$(basename $0)

# Network configuration
sudo hostname master
hostname | sudo tee /etc/hostname >> /dev/null
sudo ifconfig eth0 $(hostname) netmask 255.255.255.0 up

ssh-copy-id -i /home/hduser/.ssh/id_rsa.pub hduser@slave || ( echo "Vérifiez que slave est bien lancé et le réseau des machines bien configurées dans VMware" && exit 30 );
ssh hduser@master echo "connection to master ok"
ssh hduser@slave echo "connection to slave ok"

# Master configuration
cd /usr/local/hadoop/etc/hadoop
cat <<END > slaves
master
slave
END
sed -i.bak 's=<configuration>=<configuration>\<property>\<name>fs\.default\.name\</name>\<value>hdfs://master:54310\</value>\</property>=g' core-site.xml
sed -i.bak 's=<configuration>=<configuration>\<property>\<name>yarn\.nodemanager\.aux-services</name>\<value>mapreduce_shuffle</value>\</property>\<property>\<name>yarn.nodemanager.aux-services.mapreduce.shuffle.class</name>\<value>org\.apache\.hadoop\.mapred\.ShuffleHandler</value>\</property>=g' yarn-site.xml
cp mapred-site.xml.template mapred-site.xml
sed -i.bak 's=<configuration>=<configuration>\<property>\<name>mapreduce\.framework\.name</name>\<value>yarn</value>\</property>=g' mapred-site.xml
sed -i.bak 's=<configuration>=<configuration>\<property>\<name>dfs\.replication</name>\<value>1\</value>\</property>\<property>\<name>dfs\.namenode\.name\.dir</name>\<value>file:/home/hduser/mydata/hdfs/namenode</value>\</property>\<property>\<name>dfs\.datanode\.data\.dir</name>\<value>file:/home/hduser/mydata/hdfs/datanode</value>\</property>=g' hdfs-site.xml
scp core-site.xml yarn-site.xml mapred-site.xml hdfs-site.xml hduser@slave:$PWD/

cd /usr/local/hadoop

# Format Namenode
./bin/hdfs namenode -format

# Start DFS
./sbin/start-dfs.sh
(jps | grep -q " DataNode") || (echo "Error: DataNode not started"; exit 15)
(ssh hduser@slave jps | grep -q " DataNode") || (echo "Error: DataNode not started on slave"; exit 15)
(jps | grep -q " NameNode") || (echo "Error: NameNode not started";exit 15)
(jps | grep -q " SecondaryNameNode") || (echo "Error: SecondaryNameNode not started";exit 15)

jps
ssh hduser@slave jps

# Start yarn
sleep 15
./sbin/start-yarn.sh
(jps | grep -q " ResourceManager") || (echo "Error: ResourceManager not started";exit 15)
(jps | grep -q " NodeManager") || (echo "Error: NodeManager not started";exit 15)
(ssh hduser@slave jps | grep -q " NodeManager") || (echo "Error: NodeManager not started";exit 15)

jps
ssh hduser@slave jps

