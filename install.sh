#!/bin/bash
#l2i (Wegare)
printf 'ctrl+c' | crontab -e > /dev/null
opkg update && opkg install xl2tpd strongswan-default fping
wget --no-check-certificate "https://raw.githubusercontent.com/wegare123/l2i/main/l2i.sh" -O /usr/bin/l2i
wget --no-check-certificate "https://raw.githubusercontent.com/wegare123/l2i/main/autorekonek-l2i.sh" -O /usr/bin/autorekonek-l2i
chmod +x /usr/bin/l2i
chmod +x /usr/bin/autorekonek-l2i
rm -r ~/install.sh
mkdir -p ~/akun/
touch ~/akun/l2i.txt
sleep 2
echo "install selesai"
echo "untuk memulai tools silahkan jalankan perintah 'l2i'"
				