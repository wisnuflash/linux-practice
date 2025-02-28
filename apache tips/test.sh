#!/bin/bash

# Minta user mengisi variabel
read -p "Masukkan Timezone (contoh: Asia/Jakarta): " TZ
read -p "Masukkan Versi PHP (contoh: php7.4): " PHP_VERSION
read -p "Masukkan Nama Domain: " DOMAIN_NAME

echo $TZ $PHP_VERSION $DOMAIN_NAME