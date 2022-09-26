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

for interface in $(wg show interfaces); do
   systemctl enable --now wg-reresolve-dns@${interface}.timer
done
