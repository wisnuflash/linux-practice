I have installed both php5.6 and php7.0 from PPA on Ubuntu according to this manual

http://lornajane.net/posts/2016/php-7-0-and-5-6-on-ubuntu

But I didn't get how to install extensions using pecl for php5.6 or php7.0.

For example I have already installed version of libevent or amqp in php5.6.

Now when I type pecl install libevent and my active php version is php7.0 (using update-alternatives --set php /usr/bin/php7.0),peclreturns message thatlibevent` already installed.

But it was installed only for php5.6 (when this version was active) and now I want to do it for php7.0.

Which commands could help me?

UPD

I have found this commands for switch pecl to php7.0 and packet them to executable bash scripts:

#!/bin/bash

sudo update-alternatives --set php /usr/bin/php7.0

sudo pecl config-set php_ini /etc/php/7.0/cli/php.ini
sudo pecl config-set ext_dir /usr/lib/php/20151012/
sudo pecl config-set bin_dir /usr/bin/
sudo pecl config-set php_bin /usr/bin/php7.0
sudo pecl config-set php_suffix 7.0
and for php5.6

#!/bin/bash

sudo update-alternatives --set php /usr/bin/php5.6

sudo pecl config-set php_ini /etc/php/5.6/cli/php.ini
sudo pecl config-set ext_dir /usr/lib/php/20131226/
sudo pecl config-set bin_dir /usr/bin/
sudo pecl config-set php_bin /usr/bin/php5.6
sudo pecl config-set php_suffix 5.6
But they are not help, pecl still gives me list of already installed extensions to php5.6, even if I switched to php7.

pecl list
Installed packages, channel pecl.php.net:
=========================================
Package  Version State
amqp     1.7.1   stable
libevent 0.1.0   beta
stats    1.0.3   stable
It should be empty for php7.0 !

How to solve the problem?

UPD

For amqp I have just installed php-amqp package without using pecl.

apt-get install php-amqp
And libevent still not exists for php7. But I hadn't found a way to switch pecl installation between 5.6 and 7 version, so question is still open.
