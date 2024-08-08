#!/bin/bash
echo "install mysql "
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi
sudo apt-get update 
wget https://dev.mysql.com/get/mysql-apt-config_0.8.32-1_all.deb
sudo dpkg -i mysql-apt-config_0.8.32-1_all.deb 
sudo apt-get update 
sudo apt-get install mysql-cluster-community-data-node