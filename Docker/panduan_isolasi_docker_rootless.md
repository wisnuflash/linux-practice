# Panduan Lengkap Isolasi Docker per User SSH (Docker Rootless)

Panduan ini mendokumentasikan langkah demi langkah konfigurasi **Docker Rootless** pada server Linux (termasuk OpenCloudOS / RHEL / CentOS / Debian / Ubuntu) agar setiap pengguna SSH hanya dapat melihat dan mengelola container miliknya sendiri.

---

## Ringkasan Alur Kerja

1. **Cabut Hak Akses Global:** Hapus user dari grup `docker` agar tidak bisa mengakses soket utama (`/var/run/docker.sock`).
2. **Setup Dependency & User Namespace:** Konfigurasi `uidmap`, `subuid`, dan `subgid`.
3. **Konfigurasi systemd & PAM:** Memperbaiki session D-Bus dan mengaktifkan `linger` agar service tetap hidup.
4. **Instalasi Daemon Rootless:** Menjalankan daemon Docker di dalam *user space* akun masing-masing.
5. **Verifikasi:** Memastikan isolasi container berhasil.

---

## Tahap 1: Konfigurasi di Sisi Server (Sebagai `root` atau `sudo`)

Lakukan langkah-langkah berikut menggunakan akun administrator (`root`):

### 1. Cabut User dari Grup Docker Global
```bash
sudo gpasswd -d <nama_user> docker
```

### 2. Pasang Prasyarat & Rootless Extras
- **Untuk OpenCloudOS / RHEL / Rocky Linux / AlmaLinux:**
  ```bash
  sudo dnf install -y shadow-utils dbus-daemon docker-ce-rootless-extras
  ```
- **Untuk Ubuntu / Debian:**
  ```bash
  sudo apt-get update && sudo apt-get install -y uidmap dbus-user-session docker-ce-rootless-extras
  ```

### 3. Periksa Alokasi subuid dan subgid
Pastikan user memiliki rentang alokasi ID:
```bash
grep <nama_user> /etc/subuid
grep <nama_user> /etc/subgid
```
*Jika output kosong, tambahkan rentang ID:*
```bash
sudo usermod -v 100000-165535 -w 100000-165535 <nama_user>
```

### 4. Aktifkan Lingering Sesi
Agar proses container user tetap berjalan di latar belakang meskipun sesi SSH ditutup:
```bash
sudo loginctl enable-linger <nama_user>
```

---

## Tahap 2: Mengatasi Error `Failed to connect to bus: Permission denied`

Error ini umum terjadi di OpenCloudOS/RHEL jika modul PAM systemd belum memicu runtime user atau socket D-Bus terkunci.

### 1. Pastikan Service User Manager Berjalan
Dapatkan UID user terlebih dahulu:
```bash
USER_UID=$(id -u <nama_user>)
```

Mulai ulang service systemd manager untuk user tersebut:
```bash
sudo systemctl restart user@${USER_UID}.service
sudo systemctl status user@${USER_UID}.service
```
*Pastikan statusnya `active (running)`.*

### 2. Perbaiki Permission Direktori Runtime
```bash
sudo chown -R <nama_user>:<nama_user> /run/user/${USER_UID}
sudo chmod 700 /run/user/${USER_UID}
```

### 3. Pastikan PAM SSH Mengaktifkan systemd
Buka `/etc/pam.d/sshd` dan pastikan baris berikut aktif (tidak ada tanda pagar `#`):
```text
session   optional   pam_systemd.so
```

---

## Tahap 3: Setup Docker Rootless di Akun User

Keluarlah dari root, lalu masuk ke server langsung via SSH menggunakan akun user tersebut (`ssh <nama_user>@ip-server`):

### 1. Ekspor Environment Variable Runtime
Pastikan shell user mengenali runtime path systemd:
```bash
export XDG_RUNTIME_DIR=/run/user/$(id -u)
export DBUS_SESSION_BUS_ADDRESS="unix:path=${XDG_RUNTIME_DIR}/bus"
```

Uji koneksi ke systemd:
```bash
systemctl --user status
```
*Jika berhasil, pohon proses systemd user akan muncul tanpa error permission.*

### 2. Jalankan Script Setup Rootless
```bash
dockerd-rootless-setuptool.sh install
```

### 3. Aktifkan Service Docker Rootless
```bash
systemctl --user enable --now docker
```

Periksa status service:
```bash
systemctl --user status docker
```

### 4. Simpan Konfigurasi ke `~/.bashrc`
Agar setiap kali login SSH Docker CLI langsung terhubung ke socket rootless miliknya sendiri:
```bash
cat << 'EOF' >> ~/.bashrc

# Docker Rootless Environment
export XDG_RUNTIME_DIR=/run/user/$(id -u)
export DOCKER_HOST=unix:///run/user/$(id -u)/docker.sock
export PATH=/usr/bin:$PATH
EOF

source ~/.bashrc
```

---

## Tahap 4: Alternatif Manual (Jika Tanpa `systemd --user`)

Jika sistem environment Anda tidak mengizinkan session bus `systemd --user`, daemon dapat dijalankan secara mandiri di latar belakang:

1. Buat direktori runtime lokal:
   ```bash
   mkdir -p ~/.docker/run
   ```
2. Tambahkan ke `~/.bashrc`:
   ```bash
   cat << 'EOF' >> ~/.bashrc
   export XDG_RUNTIME_DIR=/home/$(whoami)/.docker/run
   export DOCKER_HOST=unix:///home/$(whoami)/.docker/run/docker.sock
   export PATH=/usr/bin:$PATH

   # Auto-start rootless daemon jika belum berjalan
   if ! docker info >/dev/null 2>&1; then
       nohup dockerd-rootless.sh > ~/.docker/dockerd.log 2>&1 &
       sleep 2
   fi
   EOF
   source ~/.bashrc
   ```

---

## Tahap 5: Pengujian dan Verifikasi Isolasi

1. **Jalankan container uji coba di akun user A:**
   ```bash
   docker run -d --name web-user-a nginx:alpine
   docker ps
   ```
   *Container `web-user-a` akan muncul di daftar.*

2. **Login sebagai user B atau root:**
   - Jalankan `docker ps` dari user B: daftar container akan kosong.
   - Jalankan `docker ps` dari root (daemon Docker Engine utama): container `web-user-a` **tidak akan terlihat**, membuktikan bahwa container terisolasi secara sempurna di dalam user namespace masing-masing.