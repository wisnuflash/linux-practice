# To install and configure an NFS server on Ubuntu, follow these steps:

## 1. Install NFS Server
First, ensure your system is up-to-date and install the NFS server package:
```python
sudo apt update
sudo apt install nfs-kernel-server
```
## 2. Create the Directory to Share
Create the directory you want to share over the network. For example, to share /srv/nfs_share:
```python
sudo mkdir -p /srv/nfs_share
```
Set the appropriate permissions for the directory:
```python
sudo chown nobody:nogroup /srv/nfs_share
sudo chmod 755 /srv/nfs_share
```
## 3. Configure the NFS Exports
Edit the /etc/exports file to define the directories to be shared and their permissions. Open the file in a text editor:
```python
sudo nano /etc/exports
```
Add the following line to share the directory with a specific client or subnet. Replace client_ip_or_subnet with the appropriate value:
```python
/srv/nfs_share client_ip_or_subnet(rw,sync,no_subtree_check)
```
For example, to share with all clients on the local network 192.168.1.0/24:
```python
/srv/nfs_share 192.168.1.0/24(rw,sync,no_subtree_check)
```
## 4. Apply the Export Settings
Apply the new export settings:
```python
sudo exportfs -ra
```
## 5. Allow NFS through the Firewall
If you are using UFW (Uncomplicated Firewall), you need to allow NFS traffic:
```python
sudo ufw allow from client_ip_or_subnet to any port nfs
```
For example, to allow all clients on the local network 192.168.1.0/24:
```python
sudo ufw allow from 192.168.1.0/24 to any port nfs
```
## 6. Start and Enable the NFS Server
Start the NFS server and enable it to start on boot:
```python
sudo systemctl start nfs-kernel-server
sudo systemctl enable nfs-kernel-server
```
## 7. Verify the NFS Server
To verify that the NFS server is running and sharing the directory correctly, use the following command:
```python
sudo exportfs -v
```
This should display the shared directory and the permissions associated with it.

## 8. Mount the NFS Share on a Client (Optional)
To mount the NFS share on a client machine, follow these steps:

**Install NFS Common Package on Client:**
```python
sudo apt update
sudo apt install nfs-common
```
Create a Mount Point:
```python
sudo mkdir -p /mnt/nfs_share
```
Mount the NFS Share:

```python
sudo mount server_ip:/srv/nfs_share /mnt/nfs_share
```
Replace server_ip with the IP address of your NFS server.

**Make the Mount Permanent:**
To ensure the NFS share is mounted automatically on boot, add an entry to the client’s /etc/fstab file:
```python
sudo nano /etc/fstab
```
Add the following line:
```python
server_ip:/srv/nfs_share /mnt/nfs_share nfs defaults 0 0
```
Save and exit the file.

By following these steps, you can set up and configure an NFS server on Ubuntu, allowing you to share directories with client machines over the network.


