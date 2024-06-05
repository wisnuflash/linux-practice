# load balance nginx
### install nginx terlebih dahulu
```console
sudo apt update
sudo apt install nginx
```

### tambahkan text ini di /etc/nginx/nginx.conf
```console
upstream backend {
        server backend1.example.com;
        server backend2.example.com;
        server backend3.example.com;
        # Optional: enable health checks
        # health_check;
    }
```
### buat file di /etc/nginx/conf.d/yourdomain.conf 
```console
server {
    listen 80;
    server_name test.jossproject.site;

    location / {
        proxy_pass http://backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}

server {
    listen 443 ssl;
    server_name test.jossproject.site;

    ssl_certificate /path/to/cert.pem;
    ssl_certificate_key /path/to/key.pem;

    location / {
        proxy_pass http://backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```
### hapus lah file default di /etc/nginx/sites-available dan sites-enabled
```console
sudo rm /etc/nginx/sites-available/default
sudo rm /etc/nginx/sites-available/default
```
### test config nginx ##
```java
sudo nginx -t 
sudo systemctl restart nginx 
```
