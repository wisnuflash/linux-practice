#!/bin/bash
echo "ddos-block-install started..."

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi
sudo apt install libapache2-mod-security2 -y
sudo a2enmod headers
sudo a2enmod security2
sudo systemctl restart apache2
sudo cp /etc/modsecurity/modsecurity.conf-recommended /etc/modsecurity/modsecurity.conf
wget https://github.com/coreruleset/coreruleset/archive/refs/tags/v3.3.0.tar.gz
sudo mkdir /etc/crs3
sudo tar -xzvf v3.3.0.tar.gz --strip-components 1 -C /etc/crs3
sudo cp /etc/crs3/crs-setup.conf.example /etc/crs3/crs-setup.conf
sudo mv /etc/crs3/rules/REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf.example /etc/crs3/rules/REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf
sudo mv /etc/crs3/rules/RESPONSE-999-EXCLUSION-RULES-AFTER-CRS.conf.example /etc/crs3/rules/RESPONSE-999-EXCLUSION-RULES-AFTER-CRS.conf
echo 'IncludeOptional /etc/crs3/crs-setup.conf' >> /etc/apache2/mods-enabled/security2.conf
echo 'IncludeOptional /etc/crs3/plugins/*-config.conf' >> /etc/apache2/mods-enabled/security2.conf
echo 'IncludeOptional /etc/crs3/plugins/*-before.conf' >> /etc/apache2/mods-enabled/security2.conf
echo 'IncludeOptional /etc/crs3/rules/*.conf' >> /etc/apache2/mods-enabled/security2.conf
echo 'IncludeOptional /etc/crs3/plugins/*-after.conf' >> /etc/apache2/mods-enabled/security2.conf
