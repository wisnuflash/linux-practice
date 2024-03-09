#!/bin/bash
echo "ddos-block-install started..."

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi
sudo apt install libapache2-mod-security2 -y
sudo a2enmod headers
sudo systemctl restart apache2
sudo cp /etc/modsecurity/modsecurity.conf-recommended /etc/modsecurity/modsecurity.conf
sudo rm -rf /usr/share/modsecurity-crs
sudo apt install git -y 
sudo git clone https://github.com/coreruleset/coreruleset /usr/share/modsecurity-crs
sudo mv /usr/share/modsecurity-crs/crs-setup.conf.example /usr/share/modsecurity-crs/crs-setup.conf
sudo mv /usr/share/modsecurity-crs/rules/REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf.example /usr/share/modsecurity-crs/rules/REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf

echo "tambah config security"
additional_text="
# Contoh teks tambahan
# Baris pertama yang ingin ditambahkan
# Baris kedua yang ingin ditambahkan
"

# Menambahkan teks ke dalam file
sudo sed -i '/# END modsecurity.conf/,/^$/d' /etc/apache2/mods-available/security2.conf
sudo sed -i '/<IfModule security2_module>/a\'"$additional_text" /etc/apache2/mods-available/security2.conf

echo "Teks telah ditambahkan ke dalam file /etc/apache2/mods-available/security2.conf."
