#!/bin/bash

# Minta user mengisi variabel
read -p "Masukkan Timezone (contoh: Asia/Jakarta): " TZ
read -p "Masukkan Versi PHP (contoh: php7.4): " PHP_VERSION
read -p "Masukkan Nama Domain: " DOMAIN_NAME

# Set timezone
sudo timedatectl set-timezone "$TZ"

# Update dan upgrade sistem
sudo apt update && sudo apt upgrade -y 

# Tambah repository PHP Ondrej
sudo add-apt-repository ppa:ondrej/php -y
sudo apt update && sudo apt upgrade -y

# Install Apache dan PHP
sudo apt install -y apache2 openssl wget \
  libapache2-mod-"$PHP_VERSION" \
  "$PHP_VERSION"-imagick "$PHP_VERSION"-common "$PHP_VERSION"-curl \
  "$PHP_VERSION"-gd "$PHP_VERSION"-imap "$PHP_VERSION"-intl "$PHP_VERSION"-json \
  "$PHP_VERSION"-mbstring "$PHP_VERSION"-gmp "$PHP_VERSION"-bcmath "$PHP_VERSION"-mysql \
  "$PHP_VERSION"-ssh2 "$PHP_VERSION"-xml "$PHP_VERSION"-zip "$PHP_VERSION"-apcu \
  "$PHP_VERSION"-dev php-phpseclib

# Konfigurasi VirtualHost Apache
FILE="/etc/apache2/sites-available/default.conf"
cat <<EOM >"$FILE"
<VirtualHost *:80>
  ServerName $DOMAIN_NAME
  DirectoryIndex index.php index.html
  DocumentRoot /var/www/html

  <Directory /var/www/html>
    Options +FollowSymlinks -Indexes
    AllowOverride All
    Require all granted

    SetEnv HOME /var/www/html
    SetEnv HTTP_HOME /var/www/html
  </Directory>
</VirtualHost>
EOM

# Aktifkan konfigurasi Apache
sudo a2ensite default.conf
sudo a2dissite 000-default.conf 
sudo a2enmod rewrite headers

# Restart Apache
sudo systemctl restart apache2
