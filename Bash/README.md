### To setup automatically re-resolve DNS in Wireguard on Linux
This script install automatically two service units for using the reresolve-dns.sh script comes with wireguard-tools contrib folder. It will reconnect a wg interface to there endpoint behind a NAT Router if this router renews there IP Address (reconnect or reboot).

Sometimes an Client behind IPv6 DSL forces IPv6 addresses for resolving the names and github seems not to being reachable with IPv6. Force using IPv4 with the option -4 
```
wget -4 -qO- https://raw.githubusercontent.com/heinz-otto/scripts/master/Bash/install-wireguard-reresolve-dns.sh | sudo bash -
```
