#!/bin/bash
# this script will ping the server side tunnel interface and restart the local interface if failes. 
# file=dyn_dns.sh
# wget -4 -O ${file} https://raw.githubusercontent.com/heinz-otto/scripts/master/Bash/${file}
# chmod +x ${file}
# sudo cp ${file} /usr/local/bin/
# entry in crontab: sudo crontab -e
# */5 * * * * /usr/local/bin/dyn_dns.sh >> /var/log/dyn_dns.log 2>&1
# */5 * * * * /usr/local/bin/dyn_dns.sh >/dev/null 2>&1
ip_current=$(cat /tmp/ip_current)
ip=$(dig @resolver4.opendns.com myip.opendns.com +short)
if [ "$ip" != "$ip_current" ]; then
    echo 'reregister ddns for sub.domain.tld'
    curl -su dynUser:password https://dyndns.kasserver.com
    echo $ip>/tmp/ip_current
  else
    echo 'ip not changed'
fi
