#!/bin/bash
echo "ddos-block-install started..."

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi
echo "setup iptables"
sudo iptables -t mangle -A PREROUTING -m conntrack --ctstate INVALID -j DROP
sudo iptables -t mangle -A PREROUTING -p tcp ! --syn -m conntrack --ctstate NEW -j DROP
sudo iptables -t mangle -A PREROUTING -p tcp -m conntrack --ctstate NEW -m tcpmss ! --mss 536:65535 -j DROP
echo "success"
echo "install package "
sudo apt install dnsutils -y
sudo apt-get install net-tools -y
sudo apt-get install tcpdump -y 
sudo apt-get install dsniff -y
sudo apt install grepcidr -y 
echo "installed"
echo "install ddos"
wget https://github.com/jgmdev/ddos-deflate/archive/master.zip -O ddos.zip
unzip ddos.zip
cd ddos-deflate-master
./install.sh
echo "suscces installed all"
