#!/bin/bash
# this script will ping the server side tunnel interface and restart the local interface if failes. 
# wget -4 -O keepwg.sh https://raw.githubusercontent.com/heinz-otto/scripts/master/Bash/keepwg.sh
# chmod +x keepwg.sh
# sudo cp keepwg.sh /usr/local/bin/
# entry in crontab: sudo crontab -e
# */5 * * * * /usr/local/bin/keepwg.sh 10.6.0.1 >> /var/log/keepwg.log 2>&1
if [ -z "$1" ]; then
  echo "usage:"
  echo "${0##*/} <Tunnel IP Server> [wireguard interface name]"
  echo "${0##*/} 10.6.0.1 # Tunnel IP from wg server"
  echo "${0##*/} 10.6.0.1 wg1 # other Interface than wg0 (default)"
  exit
fi

WG_GWIP=$1
WG_IF=${2:-"wg0"}
echo $(date) $(/usr/bin/vcgencmd measure_temp 2>/dev/null )
if ! /bin/ping -c 1 $WG_GWIP 2>&1 >/dev/null
then
  echo "Error - restart Interface $WG_IF"
  /usr/bin/systemctl restart wg-quick@${WG_IF}
  else echo "IP $WG_GWIP is reachable over Interface $WG_IF"
fi
