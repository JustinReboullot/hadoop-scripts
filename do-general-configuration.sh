#!/bin/bash
set -e
set -x

# Generic configuration
cd ~
sudo apt-get update

sudo apt-get install htop git inetutils-traceroute -y

( git clone https://github.com/nojhan/liquidprompt.git &&
  chmod a+r liquidprompt &&
  mkdir -p ~/.config &&
  echo "LP_HOSTNAME_ALWAYS=1" >> ~/.config/liquidpromptrc &&
  echo "source ~/liquidprompt/liquidprompt" >> ~/.bashrc
) || (echo "not important")

# Uncommment to install ssh 
sudo apt-get install openssh-server -y

# Add hadoop user
sudo addgroup hadoop
sudo useradd hduser -g hadoop -N
sudo adduser hduser sudo
sudo mkdir /home/hduser
sudo chown hduser:hadoop /home/hduser
usermod -d /home/hduser hduser
echo "hduser:ensae" | sudo chpasswd

# Generate keys
sudo -u hduser ssh-keygen -t rsa -P '' -f /home/hduser/.ssh/id_rsa
sudo -u hduser cp /home/hduser/.ssh/id_rsa.pub /home/hduser/.ssh/authorized_keys
sudo -u hduser ssh hduser@localhost echo "connection ok" || \
  sudo -u hduser ssh hduser@localhost echo "connection ok on 2nd try" || \
  sudo -u hduser ssh hduser@localhost echo "connection ok on 3nd try" || \
  (echo "not important")

# Download java jdk
sudo apt-get install openjdk-7-jdk -y

sudo update-alternatives --set java /usr/lib/jvm/java-7-openjdk-amd64/jre/bin/java
sudo update-alternatives --set javac /usr/lib/jvm/java-7-openjdk-amd64/bin/javac

cd /usr/lib/jvm
if [ -d java-7-openjdk-amd64 ]; then
sudo ln -s java-7-openjdk-amd64 jdk
elif [ -d java-7-openjdk-i386 ]; then
sudo ln -s java-7-openjdk-i386 jdk
else
echo "No java found"; exit 5;
fi
ls jdk > /dev/null


# Download Hadoop and set permissons
cd ~
if [ ! -f hadoop-2.2.0.tar.gz ]; then
	wget http://www.trieuvan.com/apache/hadoop/common/hadoop-2.2.0/hadoop-2.2.0.tar.gz
fi
sudo tar vxzf hadoop-2.2.0.tar.gz -C /usr/local
rm hadoop-2.2.0.tar.gz
cd /usr/local
sudo mv hadoop-2.2.0 hadoop
sudo chown -R hduser:hadoop hadoop

# Hadoop variables
echo export JAVA_HOME=/usr/lib/jvm/jdk/ >> ~/.bashrc
echo export HADOOP_INSTALL=/usr/local/hadoop >> ~/.bashrc
echo export PATH=\$PATH:\$HADOOP_INSTALL/bin >> ~/.bashrc
echo export PATH=\$PATH:\$HADOOP_INSTALL/sbin >> ~/.bashrc
echo export HADOOP_MAPRED_HOME=\$HADOOP_INSTALL >> ~/.bashrc
echo export HADOOP_COMMON_HOME=\$HADOOP_INSTALL >> ~/.bashrc
echo export HADOOP_HDFS_HOME=\$HADOOP_INSTALL >> ~/.bashrc
echo export YARN_HOME=\$HADOOP_INSTALL >> ~/.bashrc
sudo cp ~/.bashrc /home/hduser/.bashrc
sudo chown hduser:hadoop /home/hduser/.bashrc

# Modify JAVA_HOME 
cd /usr/local/hadoop/etc/hadoop
sudo -u hduser sed -i.bak s=\${JAVA_HOME}=/usr/lib/jvm/jdk/=g hadoop-env.sh
pwd

# Check that Hadoop is installed
/usr/local/hadoop/bin/hadoop version

# Create directories namenode and datanode
cd /home/hduser
sudo mkdir -p mydata/hdfs/namenode
sudo mkdir -p mydata/hdfs/datanode
sudo chown hduser:hadoop mydata/ -R
sudo chmod 755 mydata/ -R

# General network configuration
cat << END | sudo tee -a /etc/hosts >> /dev/null
192.168.1.99     ubuntu
192.168.1.100    master
192.168.1.101    slave
192.168.1.101    slave-1
192.168.1.102    slave-2
192.168.1.103    slave-3
192.168.1.104    slave-4
192.168.1.105    slave-5
192.168.1.106    slave-6
192.168.1.107    slave-7
192.168.1.108    slave-8
192.168.1.109    slave-9
END

echo "general configuration done"