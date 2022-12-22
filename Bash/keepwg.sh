#!/bin/bash
# wget -4 https://raw.githubusercontent.com/heinz-otto/scripts/master/Bash/keepwg.sh
# chmod +x keepwg.sh
# entry in crontab: sudo crontab -e
#*/5 * * * * /home/otto/keepwg.sh 10.6.0.1 >> /home/otto/keepwg.log 2>&1
if [ -z "$1" ]; then
  echo "usage:"
  echo "${0##*/} <Tunnel IP Server> [wireguard interface name]"
  echo "${0##*/} 10.6.0.1 # Tunnel IP from wg server"
  echo "${0##*/} 10.6.0.1 wg1 # other Interface than wg0 (default)"
  exit
fi

WG_GWIP=$1
WG_IF=${2:-"wg0"}
date
if ! /bin/ping -c 1 $WG_GWIP
then
  /usr/bin/systemctl restart wg-quick@${WG_IF}
  echo "restart interface $WG_IF"
  else echo "Interface $WG_IF with IP $WG_GWIP is reachable"
fi
