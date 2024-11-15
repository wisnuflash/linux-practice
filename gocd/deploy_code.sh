#!/bin/bash

echo "transfer code"

rsync -avz  --progress $NOT_INCLUDE_FILES $SOURCE_PATH $GO_USER@$GO_HOST:$TARGET_PATH

echo "transfer code"