#!/bin/bash
set -e
set -x

echo "hduser:ensae" | sudo chpasswd
sudo chown hduser:hadoop /home/hduser/.ssh/authorized_keys

cat << END >> /etc/hosts
192.168.1.100    master
192.168.1.101    slave
END

sudo hostname slave
hostname | sudo tee /etc/hostname >> /dev/null
sudo ifconfig eth0 $(hostname) netmask 255.255.255.0 up

sudo -u hduser /usr/local/hadoop/sbin/stop-dfs.sh
sudo -u hduser /usr/local/hadoop/sbin/stop-yarn.sh

echo "Ready for being used by my master"