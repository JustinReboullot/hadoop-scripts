#!/bin/bash
set -e
set -x

# Everything is runned by hduser
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
[ $(whoami) = hduser ] || exec sudo -u hduser $DIR/$(basename $0)

# Check that we have java and hadoop installed
ls $DIR/ >/dev/null || (echo "Directory not accessible"; exit 35)
ls /usr/local/hadoop/bin/hadoop > /dev/null || (echo "hadoop not installed"; exit 4)
ls /usr/lib/jvm/jdk > /dev/null || (echo "java not installed"; exit 3)

# Edit configuration files
cd /usr/local/hadoop/etc/hadoop
sed -i.bak 's=<configuration>=<configuration>\<property>\<name>fs\.default\.name\</name>\<value>hdfs://localhost:9000\</value>\</property>=g' core-site.xml
sed -i.bak 's=<configuration>=<configuration>\<property>\<name>yarn\.nodemanager\.aux-services</name>\<value>mapreduce_shuffle</value>\</property>\<property>\<name>yarn.nodemanager.aux-services.mapreduce.shuffle.class</name>\<value>org\.apache\.hadoop\.mapred\.ShuffleHandler</value>\</property>=g' yarn-site.xml
cp mapred-site.xml.template mapred-site.xml
sed -i.bak 's=<configuration>=<configuration>\<property>\<name>mapreduce\.framework\.name</name>\<value>yarn</value>\</property>=g' mapred-site.xml
sed -i.bak 's=<configuration>=<configuration>\<property>\<name>dfs\.replication</name>\<value>1\</value>\</property>\<property>\<name>dfs\.namenode\.name\.dir</name>\<value>file:/home/hduser/mydata/hdfs/namenode</value>\</property>\<property>\<name>dfs\.datanode\.data\.dir</name>\<value>file:/home/hduser/mydata/hdfs/datanode</value>\</property>=g' hdfs-site.xml

cd /usr/local/hadoop/

# Format Namenode
./bin/hdfs namenode -format

# Start DFS
./sbin/start-dfs.sh
(jps | grep -q " DataNode") || (echo "Error: DataNode not started"; exit 15)
(jps | grep -q " NameNode") || (echo "Error: NameNode not started";exit 15)
(jps | grep -q " SecondaryNameNode") || (echo "Error: SecondaryNameNode not started";exit 15)

# Start yarn
sleep 15
./sbin/start-yarn.sh
(jps | grep -q " ResourceManager") || (echo "Error: ResourceManager not started";exit 15)
(jps | grep -q " NodeManager") || (echo "Error: NodeManager not started";exit 15)

# Check status
jps

# Example
./bin/hadoop jar ./share/hadoop/mapreduce/hadoop-mapreduce-examples-2.2.0.jar pi 20 100

# Python basic wordcount
ls $DIR/data.txt $DIR/mapper.py $DIR/reducer.py >/dev/null || (echo "files not found"; exit 30)
./bin/hdfs dfs -copyFromLocal $DIR/data.txt sample
./bin/hadoop jar ./share/hadoop/tools/lib/hadoop-streaming-2.2.0.jar \
  -file $DIR/mapper.py    -mapper $DIR/mapper.py \
  -file $DIR/reducer.py   -reducer $DIR/reducer.py \
  -input sample -output sample-wordcount-output
./bin/hdfs dfs -cat sample-wordcount-output/part-00000
./bin/hdfs dfs -rm -r sample-wordcount-output/
./bin/hdfs dfs -rm sample
