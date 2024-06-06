# Jenkin with GIthub

```c
sudo su 
passwd jenkins
su jenkins
ssh-keygen
ssh-copy-id jenkins@hotsname
```
### tampilkan public key
```c
cat .ssh/id_rsa.pub
```
#### setelah itu copy ke dalam github
#### copy juga private key ke jenkins
```c
cat .ssh/id_rsa
```
#### setelah itu verifikasi github public key 
```python
ssh -T git@github.com
```