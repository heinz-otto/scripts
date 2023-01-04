#!/bin/bash
# This script is based on this code https://techoverflow.net/2021/08/19/how-to-automatically-re-resolve-dns-in-wireguard-on-linux/
# This script installs a systemd timer template named WireguardReResolveDNS.(service|timer)
# to run every 30 seconds. Requires that wireguard-tools is installed.
# This script will enable the timer service for every wg interface

export NAME=wg-reresolve-dns@
cat >/etc/systemd/system/${NAME}.service <<EOF
[Unit]
Description=${NAME}
[Service]
Type=oneshot
ExecStart=/usr/share/doc/wireguard-tools/examples/reresolve-dns/reresolve-dns.sh %i
EOF

cat >/etc/systemd/system/${NAME}.timer <<EOF
[Unit]
Description=${NAME} timer
[Timer]
Unit=${NAME}%i.service
OnCalendar=*-*-* *:*:00,30
Persistent=true
[Install]
WantedBy=timers.target
EOF

r='^DNS = 192'

for interface in $(wg show interfaces); do
   f="/etc/wireguard/${interface}.conf"
   n="/etc/wireguard/${interface}.new"
   if grep "$r" "$f" ; then
      while true; do
        # '< /dev/tty' to read directly from the terminal not from /dev/stdin wich is the pipe
        read -p "Die conf hat einen DNS Eintrag - entfernen? " yn < /dev/tty 
        case $yn in
             [Yy]* ) sed /"$r"/d "$f" > $n; mv $f ${interface}.sav; mv $n $f; resolvconf -d wg0; break;; # delete the old DNS entry in resolvconf without restart wg0
             [Nn]* ) break;;
             * ) echo "Please answer yes or no.";;
        esac
      done
      systemctl enable --now wg-reresolve-dns@${interface}.timer
   fi
done
