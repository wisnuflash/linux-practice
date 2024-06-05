# add disk on linux

```console
mkfs.ext4 /dev/sdb1
mount -t ext4 /dev/sdb1 /mnt/storage2
```
## mount on webserver folder

```console
sudo mkdir /media/web_files
sudo chown -R www-data:www-data /media/web_files/
sudo mkdir /var/www/html/external_files
sudo mount --bind /media/web_files/ /var/www/html/external_files/
```

## Adding a Samba (Windows) Share
Install CIFS Utilities:
Ensure you have the necessary utilities installed by running:


```console
sudo apt update
sudo apt install cifs-utils
```
Create a Mount Point:
Create a directory where the network share will be mounted:
```console
sudo mkdir /mnt/network_drive
```
Mount the Share:
Use the mount command to mount the network share:
```console
sudo mount -t cifs //server_ip_or_name/share_name /mnt/network_drive -o username=your_username,password=your_password
```
Replace server_ip_or_name with the IP address or hostname of the server, share_name with the name of the shared folder, and your_username and your_password with your network credentials.

Permanent Mount:
To make the mount persistent across reboots, add an entry to the /etc/fstab file:

```console
sudo nano /etc/fstab
```
Add the following line:
```console
//server_ip_or_name/share_name /mnt/network_drive cifs username=your_username,password=your_password 0 0
```
Save and exit the editor (Ctrl+X, Y, Enter).


[def]: xternal_files/file1.mp