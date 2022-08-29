#!/bin/ash
# Install packages
opkg update
opkg install wireguard-tools luci-app-wireguard luci-proto-wireguard 
#optional 
opkg install qrencode nano tcpdump-mini

# Configuration parameters
WG_IF="vpn"
WG_PORT="51820"
WG_ADDR="192.168.9.1/24"
WG_ADDR6="fdf1:e8a1:8d3f:9::1/64"

# Generate keys
if [ ! -f ./*.key ]; then 
  echo 'Erzeuge keys'
  umask go=
  wg genkey | tee wgserver.key | wg pubkey > wgserver.pub
fi

# Server private key
WG_KEY="$(cat wgserver.key)"

# Configure firewall
uci rename firewall.@zone[0]="lan"
uci rename firewall.@zone[1]="wan"
uci del_list firewall.lan.network="${WG_IF}"
uci add_list firewall.lan.network="${WG_IF}"
uci -q delete firewall.wg
uci set firewall.wg="rule"
uci set firewall.wg.name="Allow-WireGuard-${WG_IF}"
uci set firewall.wg.src="wan"
uci set firewall.wg.dest_port="${WG_PORT}"
uci set firewall.wg.proto="udp"
uci set firewall.wg.target="ACCEPT"
uci commit firewall
service firewall restart

# Configure network
uci -q delete network.${WG_IF}
uci set network.${WG_IF}="interface"
uci set network.${WG_IF}.proto="wireguard"
uci set network.${WG_IF}.private_key="${WG_KEY}"
uci set network.${WG_IF}.listen_port="${WG_PORT}"
uci set network.${WG_IF}.mtu='1420'
uci add_list network.${WG_IF}.addresses="${WG_ADDR}"
uci add_list network.${WG_IF}.addresses="${WG_ADDR6}"
uci commit network
# service network restart - doesnt work at this point
/etc/init.d/network restart
