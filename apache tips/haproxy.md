# HAProxy Configuration Cheat Sheet 🚀

HAProxy adalah load balancer yang handal untuk membagi beban lalu lintas HTTP dan TCP. Berikut adalah konfigurasi dasar dan fitur pentingnya.

---

## 1. Struktur Dasar Konfigurasi
```ini
global
    log /dev/log local0
    maxconn 4096
    daemon

defaults
    log global
    mode http
    option httplog
    timeout connect 5000ms
    timeout client 50000ms
    timeout server 50000ms
```

---

## 2. Frontend: Mengatur Akses Klien
```ini
frontend http_front
    bind *:80
    mode http
    default_backend web_servers
```
- `bind *:80` → Dengarkan koneksi di port 80
- `default_backend web_servers` → Meneruskan request ke backend

---

## 3. Backend: Load Balancing
```ini
backend web_servers
    mode http
    balance roundrobin
    option httpchk GET /
    server web1 192.168.1.101:80 check
    server web2 192.168.1.102:80 check
```
- `balance roundrobin` → Load balancing dengan metode round-robin
- `option httpchk GET /` → Mengecek kesehatan server backend
- `check` → Mengaktifkan health check pada server

---

## 4. Mode Load Balancing
| Mode | Deskripsi |
|------|-----------|
| `roundrobin` | Bergiliran ke semua server |
| `leastconn` | Mengarahkan ke server dengan koneksi paling sedikit |
| `source` | Menjaga sesi berdasarkan IP klien (sticky session) |

---

## 5. Mengaktifkan HAProxy Stats
```ini
listen stats
    bind *:8080
    mode http
    stats enable
    stats uri /stats
    stats refresh 10s
    stats auth admin:password
```
📌 **Akses di Browser:** `http://<IP-HAProxy>:8080/stats`
📌 **Login:** `admin / password`

---

## 6. SSL Termination (HTTPS)
```ini
frontend https_front
    bind *:443 ssl crt /etc/haproxy/certs/server.pem
    mode http
    default_backend web_servers
```
- `ssl crt /etc/haproxy/certs/server.pem` → Menggunakan sertifikat SSL
- Konversi Sertifikat ke PEM:
```sh
cat server.crt server.key > /etc/haproxy/certs/server.pem
```

---

## 7. Redirect HTTP ke HTTPS
```ini
frontend http_front
    bind *:80
    redirect scheme https if !{ ssl_fc }
```
📌 **Redirect otomatis ke HTTPS jika akses HTTP**

---

## 8. Sticky Session
```ini
backend web_servers
    balance roundrobin
    cookie JSESSIONID prefix
    server web1 192.168.1.101:80 check cookie web1
    server web2 192.168.1.102:80 check cookie web2
```
📌 **Memastikan user tetap di server yang sama selama sesi berlangsung**

---

## 9. Logging
Tambahkan logging ke file syslog:
```ini
global
    log /var/log/haproxy.log local0
```
Cek log dengan:
```sh
tail -f /var/log/haproxy.log
```

---

## 10. Restart & Cek Konfigurasi
```sh
haproxy -c -f /etc/haproxy/haproxy.cfg  # Cek konfigurasi
systemctl restart haproxy                # Restart HAProxy
systemctl status haproxy                 # Cek status
```

---

## 🎯 Kesimpulan
HAProxy adalah solusi load balancing yang kuat dan fleksibel. Dengan konfigurasi di atas, Anda bisa dengan cepat mengatur load balancing HTTP, HTTPS, sticky sessions, dan monitoring stats.

💡 **Butuh fitur tambahan? Jangan ragu untuk menyesuaikan konfigurasi ini!** 🚀
