#!/bin/bash
set -e
set -x

# Changing hostname and ip address
sudo hostname slave
hostname | sudo tee /etc/hostname >> /dev/null
sudo ifconfig eth0 $(hostname) netmask 255.255.255.0 up

echo "Ready for being used by my master"