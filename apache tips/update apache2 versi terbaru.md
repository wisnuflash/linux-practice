## update apache 2.4.58 ###
```console
sudo add-apt-repository ppa:ondrej/apache2
sudo apt-get update 
sudo apt-get upgrade apache2
```
## setup apache pertama  kali 
```console
sudo a2enmod rewrite
sudo a2enmod headers
```
### tambahkan baris ini di apache2.conf
```python
<Directory /var/www/html>
	Options -Indexes
	AllowOverride All
  	ServerSignature Off
	Require all granted
</Directory>
```
### tambahkan index.php di /mods-enabled/dir.conf

