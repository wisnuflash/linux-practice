sudo apt install openvpn-systemd-resolved
Setelah paket terinstal, konfigurasikan klien untuk menggunakannya, dan untuk mengirim semua permintaan DNS melalui antarmuka VPN. Buka berkas VPN klien:

nano client1.ovpn
Sekarang hapus komentar pada baris berikut yang Anda tambahkan sebelumnya:

klien1.ovpn
script-security 2
up /etc/openvpn/update-systemd-resolved
down /etc/openvpn/update-systemd-resolved
down-pre
dhcp-option DOMAIN-ROUTE .
Mengonfigurasi Klien yang menggunakanupdate-resolv-conf
Jika sistem Anda tidak digunakan systemd-resolveduntuk mengelola DNS, periksa apakah distribusi Anda menyertakan /etc/openvpn/update-resolv-confskrip sebagai gantinya:

ls /etc/openvpn
Output
update-resolv-conf
Jika klien Anda menyertakan update-resolv-confberkas tersebut, maka edit berkas konfigurasi klien OpenVPN yang Anda transfer sebelumnya:

nano client1.ovpn
Hapus komentar pada tiga baris yang Anda tambahkan untuk menyesuaikan pengaturan DNS:

klien1.ovpn
script-security 2
up /etc/openvpn/update-resolv-conf
down /etc/openvpn/update-resolv-conf
