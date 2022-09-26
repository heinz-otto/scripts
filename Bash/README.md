### To setup automatically re-resolve DNS in Wireguard on Linux
Sometimes an Client behind IPv6 DSL will not resolve the proper IP addresses and github seems not reachable with IPv6. Force IPv4 with -4 
```
wget -4 -qO- https://raw.githubusercontent.com/heinz-otto/scripts/master/Bash/install-wireguard-reresolve-dns.sh | sudo bash -
```
