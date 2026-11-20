# Panduan Aktivasi Network Interface Baru via Cloud-Init (Tanpa Restart VM)

Dokumentasi ini menjelaskan langkah-langkah untuk mendeteksi dan mengaktifkan *network interface* baru beserta konfigurasi IP-nya yang telah diatur melalui **cloud-init** pada sistem operasi **Ubuntu 24.04 (Noble Numbat)** tanpa perlu melakukan *reboot* pada Virtual Machine (VM).

---

## Prasyarat
* Akses ke konsol VM atau sesi SSH dengan hak akses `sudo`.
* *Network interface* baru sudah ditambahkan melalui pengaturan *hypervisor* (Proxmox, OpenStack, VMware, dll.).
* Konfigurasi IP untuk *interface* baru sudah diperbarui pada pengaturan *cloud-init*.

---

## Langkah-Langkah Konfigurasi

### 1. Verifikasi Nama Interface Baru di OS
Ubuntu 24.04 menggunakan *Predictable Network Interface Names* (contoh: `ens4`, `enp0s4`, atau `eth1`). Pastikan *interface* baru sudah dikenali oleh kernel dan namanya sesuai dengan yang didefinisikan di *cloud-init*.

```bash
ip -br link
```
* **Hasil yang diharapkan:** Nama *interface* baru muncul dalam daftar (biasanya berstatus `DOWN` sebelum dikonfigurasi).

### 2. Perbarui Cache dan Jalankan Ulang Cloud-Init
Hapus *cache* status eksekusi *cloud-init* sebelumnya agar sistem menarik ulang metadata jaringan terbaru dari *hypervisor* dan menulisnya ke konfigurasi Netplan.

```bash
sudo cloud-init clean --logs
sudo cloud-init init --local
```

**Verifikasi File Konfigurasi Netplan:**
Periksa apakah pengaturan IP baru sudah masuk ke dalam file konfigurasi yang dihasilkan oleh *cloud-init*:

```bash
sudo cat /etc/netplan/50-cloud-init.yaml
```

### 3. Terapkan Konfigurasi Jaringan (Netplan)
Pada Ubuntu 24.04, Netplan bertindak sebagai antarmuka untuk `systemd-networkd` (Server) atau `NetworkManager` (Desktop). Jalankan perintah berikut untuk menerapkan perubahan dan mengaktifkan port secara langsung:

```bash
sudo netplan apply
```

> **⚠️ Peringatan Koneksi SSH:**
> Jika Anda terhubung melalui SSH dan terdapat kesalahan penulisan (*syntax error*) pada konfigurasi *cloud-init*, perintah `netplan apply` berisiko memutus koneksi utama Anda. Sebagai alternatif yang lebih aman, gunakan perintah:
> ```bash
> sudo netplan try
> ```
> Perintah ini akan mengembalikan konfigurasi ke pengaturan semula secara otomatis dalam 120 detik apabila koneksi terputus atau tidak dikonfirmasi.

### 4. Verifikasi Status Interface dan Konektivitas
Pastikan *interface* baru sudah dalam status `UP` dan mendapatkan alamat IP yang sesuai:

```bash
ip -br a
```

Lakukan pengujian koneksi ke *gateway* atau alamat IP lain di segmen jaringan yang sama:

```bash
ping -c 4 <IP_GATEWAY_ATAU_TUJUAN>
```

---

## Troubleshooting Singkat

* **Status interface masih `DOWN` setelah `netplan apply`:**
  Aktifkan *link* fisik virtual secara manual (ganti `ens4` dengan nama *interface* Anda):
  ```bash
  sudo ip link set ens4 up
  ```
* **File `/etc/netplan/50-cloud-init.yaml` tidak berubah:**
  Pastikan *datasource* pada *hypervisor* sudah menyinkronkan metadata terbaru ke VM, atau periksa *log* eksekusi melalui `/var/log/cloud-init.log`.