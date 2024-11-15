#!/bin/bash

echo "run php composer first start"

ssh  $GO_USER@$GO_HOST "cd $TARGET_PATH && php8.2 /usr/local/bin/composer install"
ssh  $GO_USER@$GO_HOST "cd $TARGET_PATH && php8.2 /usr/local/bin/composer dump-autoload"
ssh  $GO_USER@$GO_HOST "cd $TARGET_PATH && php8.2 /usr/local/bin/composer dump-autoload"
echo "run php artisan first start"
ssh  $GO_USER@$GO_HOST "cd $TARGET_PATH  && php8.2 artisan clear-compiled"
ssh  $GO_USER@$GO_HOST "cd $TARGET_PATH  && php8.2 artisan route:clear"
ssh  $GO_USER@$GO_HOST "cd $TARGET_PATH  && php8.2 artisan view:clear"
ssh  $GO_USER@$GO_HOST "cd $TARGET_PATH  && php8.2 artisan cache:clear"
ssh  $GO_USER@$GO_HOST "cd $TARGET_PATH  && php8.2 artisan config:clear"
ssh  $GO_USER@$GO_HOST "cd $TARGET_PATH  && php8.2 artisan optimize"
echo "all done"