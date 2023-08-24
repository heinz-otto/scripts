#!/bin/bash
# this script will ping and return the avgr time append to the api url for uptime kuma, if succeeded.
# wget -4 -O push.sh https://raw.githubusercontent.com/heinz-otto/scripts/master/Bash/PushUptimeKuma.sh
# chmod +x push.sh
# sudo cp push.sh /usr/local/bin/
# entry in crontab: crontab -e
# * * * * * /usr/local/bin/push.sh 10.6.0.1 'http://kumahost:kumaport/api/push/8T8wmYE28s?status=up&msg=OK&ping='

if [ -z "$2" ]; then
  echo "usage:"
  echo "${0##*/} <monitored IP> <given API url uptime kuma> [number of pings]"
  echo "${0##*/} 10.6.0.1 'http://kumahost:kumaport/api/push/8T8wmYE28s?status=up&msg=OK&ping='"
  echo "${0##*/} 10.6.0.1 <url> 5"  # average 5 pings
  exit
fi

ip=$1
url=$2
count=${3:-"1"}
zeit=$(timeout 0.2 ping -c $count $ip|awk -F'[/]' '/^rtt/{print $5}')
if [ -z "$zeit" ] ; then
  echo "host not reachable"
else
  echo "${url}${zeit}"
  # wget -q "${url}${zeit}"
fi