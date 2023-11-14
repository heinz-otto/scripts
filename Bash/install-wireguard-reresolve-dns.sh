#!/bin/bash
# This script is based on this code https://techoverflow.net/2021/08/19/how-to-automatically-re-resolve-dns-in-wireguard-on-linux/
# This script installs a systemd timer template named WireguardReResolveDNS.(service|timer)
# to run every 30 seconds. Requires that wireguard-tools is installed.
# This script will enable the timer service for every wg interface
# finally it will patch the systemd service to LogLevel=notice because the timer will log extensivly 3 messages per time
# you could check if timer is installed and running: systemctl list-timers 

# run this Script as root https://www.linuxjournal.com/content/automatically-re-start-script-root-0
if [[ $UID -ne 0 ]]; then
   sudo -p 'Restarting as root, password: ' bash $0 "$@"
   exit $?
fi

# check if wireguard-tools installed and install on demand
if ! apt list wireguard-tools; then
   apt install wireguard-tools
fi

export NAME=wg-reresolve-dns@
# create service and timer units
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

# remove DNS =  entry from all interfaces to prevent deadlock for resolving names
# remove active DNS entry from resolvconf without restart
# finally enable the timer
r='^DNS = 192'
for interface in $(wg show interfaces); do
   f="/etc/wireguard/${interface}.conf"
   n="/etc/wireguard/${interface}.new"
   if grep "$r" "$f" ; then
      while true; do
        # '< /dev/tty' to read directly from the terminal not from /dev/stdin wich is the pipe
        read -p "Die conf hat einen DNS Eintrag - entfernen? y/n " yn < /dev/tty 
        case $yn in
             [Yy]* ) sed /"$r"/d "$f" > $n; mv $f ${interface}.sav; mv $n $f; resolvconf -d wg0; break;; # delete the old DNS entry in resolvconf without restart wg0
             [Nn]* ) break;;
             * ) echo "Please answer yes or no.";;
        esac
      done
   fi
   systemctl enable --now wg-reresolve-dns@${interface}.timer
done

# modify systemd LogLevel from Standard 'info' to 'notice' 
sed -i 's/^#LogLevel=.*/LogLevel=notice/' /etc/systemd/system.conf
systemctl daemon-reexec
