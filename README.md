Cara install modsecurity versi 2.9.6 di ubuntu 22.04

sudo apt update

sudo apt install -y \
    apache2-dev \
    build-essential \
    libcurl4-openssl-dev \
    libgeoip-dev \
    libpcre++-dev \
    libxml2-dev \
    libyajl-dev \
    pkg-config \
    zlib1g-dev
    
wget https://github.com/owasp-modsecurity/ModSecurity/releases/download/v2.9.6/modsecurity-2.9.6.tar.gz \
wget https://github.com/owasp-modsecurity/ModSecurity/releases/download/v2.9.6/modsecurity-2.9.6.tar.gz.sha256 \
sha256sum -c modsecurity-2.9.6.tar.gz.sha256 \
tar -xvzf modsecurity-2.9.6.tar.gz 

INSTALL MOD SECURITY 

cd modsecurity-2.9.6 \
./autogen.sh  \
./configure \
make \
sudo make install  \
sudo cp /usr/local/modsecurity/lib/mod_security2.so /usr/lib/apache2/modules/  \
sudo cp /usr/local/modsecurity/unicode.mapping /etc/apache2/ \
sudo a2enmod security2  \
sudo a2enmod header 

## DOWNLOAD OWASP 

gpg --keyserver pgp.mit.edu --recv 0x38EEACA1AB8A6E72  \
gpg --edit-key 36006F0E0BA167832158821138EEACA1AB8A6E72  \
gpg> trust \
Your decision: 5 (ultimate trust)  \
Are you sure: Yes  \
gpg> quit \
wget https://github.com/coreruleset/coreruleset/archive/refs/tags/v4.0.0.tar.gz \
wget https://github.com/coreruleset/coreruleset/releases/download/v4.0.0/coreruleset-4.0.0.tar.gz.asc \
gpg --verify coreruleset-4.0.0.tar.gz.asc v4.0.0.tar.gz \
mkdir /etc/crs4  \
tar -xzvf v4.0.0.tar.gz --strip-components 1 -C /etc/crs4  \
cd /etc/crs4 \
mv crs-setup.conf.example crs-setup.conf 

#edit file /etc/apache2/mods-enabled/security2.conf

tambahkan baris ini 

IncludeOptional /etc/crs4/crs-setup.conf  \
IncludeOptional /etc/crs4/plugins/*-config.conf  \
IncludeOptional /etc/crs4/plugins/*-before.conf  \
IncludeOptional /etc/crs4/rules/*.conf \
IncludeOptional /etc/crs4/plugins/*-after.conf  

SETELAH ITU RESTART APACHE2 

sudo systemctl restart apache2  

Memverifikasi bahwa CRS aktif

curl 'https://www.example.com/?foo=/etc/passwd&bar=/bin/sh'
