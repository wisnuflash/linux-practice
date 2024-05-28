Cara install modsecurity versi 2.9.6 di ubuntu 22.04

sudo apt update

apt-get install apache2-dev libxml2-dev liblua5.1-0-dev libcurl4-gnutls-dev libyajl-dev make curl 
    
wget https://github.com/owasp-modsecurity/ModSecurity/releases/download/v2.9.6/modsecurity-2.9.6.tar.gz \
wget https://github.com/owasp-modsecurity/ModSecurity/releases/download/v2.9.6/modsecurity-2.9.6.tar.gz.sha256 \
sha256sum -c modsecurity-2.9.6.tar.gz.sha256 \
tar -xvzf modsecurity-2.9.6.tar.gz 

INSTALL MOD SECURITY 

cd modsecurity-2.9.6 \
./autogen.sh  \
sudo apt-get update \
sudo apt-get install libpcre3 libpcre3-dev \
./configure \
make \
sudo make install  \
sudo cp /usr/local/modsecurity/lib/mod_security2.so /usr/lib/apache2/modules/  \
sudo cp /usr/local/modsecurity/unicode.mapping /etc/apache2/ \
sudo a2enmod security2  \
sudo a2enmod header 
sudo nano /etc/modsecurity/modsecurity.conf \
Find the following line.

SecRuleEngine DetectionOnly

This config tells ModSecurity to log HTTP transactions, but takes no action when an attack is detected. Change it to the following, so ModSecurity will detect and block web attacks.

SecRuleEngine On

Then find the following line (line 186), which tells ModSecurity what information should be included in the audit log.

SecAuditLogParts ABDEFHIJZ

However, the default setting is wrong. You will know why later when I explain how to understand ModSecurity logs. The setting should be changed to the following.

SecAuditLogParts ABCEFHJKZ

Save and close the file. Then restart Apache for the change to take effect. (Reloding the web server isn’t enough.) \
SecRequestBodyLimit 536870912 \
SecRequestBodyNoFilesLimit 10485760 

sudo systemctl restart apache2

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
