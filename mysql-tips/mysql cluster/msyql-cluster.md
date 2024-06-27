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

