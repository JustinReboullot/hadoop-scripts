#!/bin/bash
set -e
set -x

echo "hduser:ensae" | sudo chpasswd

# Network configuration
cat << END | sudo tail -a /etc/hosts >> /dev/null
192.168.1.100    master
192.168.1.101    slave
END
sudo hostname master
hostname | sudo tee /etc/hostname >> /dev/null
sudo ifconfig eth0 $(hostname) netmask 255.255.255.0 up
# from http://www.cyberciti.biz/tips/read-unixlinux-system-ip-address-in-a-shell-script.html
# address $(ifconfig  | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}')
cat <<END | tee /etc/network/interfaces > /dev/null
auto lo
iface eth0 inet static
address 192.168.1.100
network 192.168.1.0
netmask 255.255.255.0
broadcast 127.0.1.255
gateway 192.168.1.254
END

# everything from here is run by hduser
sudo -u hduser -s

ssh-copy-id -i /home/hduser/.ssh/id_rsa.pub hduser@slave || ( echo "Vérifiez que slave est bien lancé et le réseau des machines bien configurées dans VMware" && exit 30 );
ssh hduser@master echo "connection to master ok"
ssh hduser@slave echo "connection to slave ok"


./bin/stop-dfs.sh
ssh hduser@slave /usr/local/hadoop/etc/hadoop/sbin/stop-dfs.sh
ssh hduser@slave /usr/local/hadoop/etc/hadoop/sbin/stop-yarn.sh

cd /usr/local/hadoop/etc/hadoop
echo "master
slave" > slaves
cp core-site.xml.bak core-site.xml || cp core-site.xml core-site.xml.bak
sed -i 's=<configuration>=<configuration>\<property>\<name>fs\.default\.name\</name>\<value>hdfs://master:54310\</value>\</property>=g' core-site.xml
scp $PWD/core-site.xml hduser@slave:$PWD/core-site.xml

cd /usr/local/hadoop
./sbin/stop-dfs.sh
./sbin/stop-yarn.sh
ssh hduser@slave /usr/local/hadoop/sbin/stop-dfs.sh
ssh hduser@slave /usr/local/hadoop/sbin/stop-yarn.sh
./bin/hadoop namenode -format
./sbin/start-dfs.sh
./sbin/start-yarn.sh
