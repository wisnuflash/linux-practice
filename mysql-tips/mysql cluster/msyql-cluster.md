# Install Percona XtraDB Cluster on Debian or Ubuntu

## Install from Repository
Update the sytem:
```python
sudo apt update
```
Install the necessary packages:
```python
sudo apt install -y wget gnupg2 lsb-release curl
```
Download the repository package
```python
wget https://repo.percona.com/apt/percona-release_latest.generic_all.deb
```
Install the package with dpkg:
```python
sudo dpkg -i percona-release_latest.generic_all.deb
```
Refresh the local cache to update the package information:
```python
sudo apt update
```
Enable the release repository for Percona XtraDB Cluster:
```python
sudo percona-release setup pxc80
```
Install the cluster:
```python
sudo apt install -y percona-xtradb-cluster
```

# Configure nodes for write-set replication
1. Stop the Percona XtraDB Cluster server. After the installation completes the server is not started. You need this step if you have started the server manually.
```python
sudo service mysql stop
```
2. Edit the configuration file of the first node to provide the cluster settings.If you use Debian or Ubuntu, edit /etc/mysql/mysql.conf.d/mysqld.cnf:
```python
wsrep_provider=/usr/lib/galera4/libgalera_smm.so
wsrep_cluster_name=pxc-cluster
wsrep_cluster_address=gcomm://192.168.70.61,192.168.70.62,192.168.70.63
```
3. Configure node 1.
```python
wsrep_node_name=pxc1
wsrep_node_address=192.168.70.61
pxc_strict_mode=ENFORCING
```
4. Set up node 2 and node 3 in the same way: Stop the server and update the configuration file applicable to your system. All settings are the same except for wsrep_node_name and wsrep_node_address.

For node 2
```python
wsrep_node_name=pxc2
wsrep_node_address=192.168.70.62
```
For node 3

```python
wsrep_node_name=pxc3
wsrep_node_address=192.168.70.63
```
5. Set up the traffic encryption settings. Each node of the cluster must use the same SSL certificates.
```python
[mysqld]
wsrep_provider_options=”socket.ssl_key=server-key.pem;socket.ssl_cert=server-cert.pem;socket.ssl_ca=ca.pem”

[sst]
encrypt=4
ssl-key=server-key.pem
ssl-ca=ca.pem
ssl-cert=server-cert.pem
```