# To add swap memory on an Ubuntu cloud image, you can follow these steps:

## Step 1: Check Existing Swap
 First, check if any swap is already enabled on the system:
```python
sudo swapon --show-
```
If no output is returned, it means no swap space is active.

## Step 2: Check Available Disk Space
Ensure there's enough disk space to create a swap file:
```python
df -h
```
## Step 3: Create a Swap File
You can create a swap file of 1GB (or adjust the size as needed):

```python
sudo fallocate -l 1G /swapfile
```
If fallocate is not available, you can use dd instead:

```python
sudo dd if=/dev/zero of=/swapfile bs=1M count=1024
```
## Step 4: Set Correct Permissions
Set the correct permissions for the swap file so it's only accessible by the root user:

```python
sudo chmod 600 /swapfile
```
## Step 5: Mark the File as Swap
Set up the swap file by marking it as swap space:

```python
sudo mkswap /swapfile
```
## Step 6: Enable the Swap File
Enable the swap file for immediate use:

```python
sudo swapon /swapfile
```
## Step 7: Verify the Swap
Check to make sure the swap is active:


```c
sudo swapon --show
```
You can also check using:

```python
free -h
```
## Step 8: Make Swap Permanent
To ensure the swap file is used after reboot, add it to the /etc/fstab file:


```python
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```
Optional: Adjust Swap Settings
You may want to adjust the swappiness value, which defines how aggressively the system swaps memory (default is usually 60). Lower values reduce swap usage, and higher values increase it.

To set swappiness to 10 (for example):

```python
sudo sysctl vm.swappiness=10
```
Make it persistent by adding it to the /etc/sysctl.conf file:

```python
echo 'vm.swappiness=10' | sudo tee -a /etc/sysctl.conf
```
This will create and activate swap memory on your Ubuntu cloud image.







