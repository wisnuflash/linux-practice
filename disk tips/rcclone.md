```java
rclone mount trusmicorp-bucket:trusmicorp-bucket /mnt/test-rc --allow-non-empty --allow-root --vfs-cache-mode full --daemon
```
## unmount storage
```java
fusermount -u ~/directory
```

rclone mount aws:dbdell /mnt/aws-test --daemon