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
  "$PHP_VERSION"-xml "$PHP_VERSION"-zip \
  "$PHP_VERSION"-dev php-phpseclib "$PHP_VERSION"-iconv
  

# Konfigurasi VirtualHost Apache
FILE="/etc/apache2/sites-available/default.conf"
cat <<EOM | sudo tee "$FILE"
<VirtualHost *:80>
  #ServerName $DOMAIN_NAME
  DirectoryIndex index.php index.html
  DocumentRoot /var/www/html

  <Directory /var/www/html>
    Options +FollowSymlinks -Indexes
    AllowOverride All
    Require all granted

    SetEnv HOME /var/www/html
    SetEnv HTTP_HOME /var/www/html
  </Directory
  
  ErrorLog ${APACHE_LOG_DIR}/error.log
  CustomLog ${APACHE_LOG_DIR}/access.log combined  
</VirtualHost>
EOM

# Aktifkan konfigurasi Apache
sudo a2ensite default.conf
sudo a2dissite 000-default.conf 
sudo a2enmod rewrite headers

# Restart Apache
sudo systemctl restart apache2
sudo systemctl enable apache2

# Konfirmasi instalasi nfs-common
read -p "Apakah Anda ingin menginstall nfs-common? (y/n): " INSTALL_NFS
if [[ "$INSTALL_NFS" == "y" || "$INSTALL_NFS" == "Y" ]]; then
    sudo apt install -y nfs-common
    echo "nfs-common berhasil diinstal."
else
    echo "Instalasi nfs-common dibatalkan. Keluar dari skrip."
    exit 0
fi

# Meminta informasi NFS
read -p "Masukkan IP server NFS: " IP_NFS
read -p "Masukkan directory NFS (contoh: /files/files): " DIR_NFS
read -p "Masukkan directory target untuk di-mount (contoh: /mnt/nfs): " TARGET_NFS

# Pastikan directory target ada, jika tidak buat directory tersebut
if [ ! -d "$TARGET_NFS" ]; then
    echo "Direktori $TARGET_NFS tidak ditemukan, membuatnya..."
    sudo mkdir -p "$TARGET_NFS"
fi

# Mount sementara
sudo mount "$IP_NFS:$DIR_NFS" "$TARGET_NFS"

# Konfirmasi apakah ingin mount permanen
read -p "Apakah Anda ingin mount secara permanen? (y/n): " MOUNT_NFS
if [[ "$MOUNT_NFS" == "y" || "$MOUNT_NFS" == "Y" ]]; then
    echo "$IP_NFS:$DIR_NFS $TARGET_NFS nfs auto,nofail,noatime,nolock,intr,tcp,actimeo=1800 0 0" | sudo tee -a /etc/fstab
    echo "Mount berhasil ditambahkan ke /etc/fstab."
else
    echo "Mount permanen dibatalkan. Keluar dari skrip."
    exit 0
fi
