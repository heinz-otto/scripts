#!/bin/ash
# Code is based on https://openwrt.org/docs/guide-user/services/vpn/wireguard/server
# usage: ./wireguard-setup-server.sh KEY ADDR PORT IFname
# usage with pipe: echo "KEY ADDR PORT IFname"|xargs ./wireguard-setup-server.sh

# Configuration parameters, read from input or setting defaults
WG_KEY=$1
WG_ADDR=$2; [ -z "${WG_ADDR}" ] && WG_ADDR="192.168.9.1/24"
WG_PORT=$3; [ -z "${WG_PORT}" ] && WG_PORT="51820"
WG_IF=$4 ;  [ -z "${WG_IF}" ] && WG_IF="vpn"
WG_ADDR6="fdf1:e8a1:8d3f:9::1/64"
# base path for confing & key files if exists
WG_DIR="/etc/wireguard" 
WG_CONFIGS="configs"
WG_KEYS="keys"

# Install packages
if [ -z $(opkg list-installed|grep -o kmod-wireguard) ]; then
    opkg update
    opkg install wireguard-tools luci-app-wireguard luci-proto-wireguard 
    #optional 
    opkg install qrencode nano tcpdump-mini
 else
    echo "software already installed"
fi

# read or generate servers private key
if [ -z ${WG_KEY} ]; then
    if [ -f "${WG_DIR}/${WG_KEYS}/wgserver.key" ]; then 
      echo 'read key from file'
      WG_KEY=$(cat "${WG_DIR}/${WG_KEYS}/wgserver.key")
	else
      echo 'create new key'
      WG_KEY=$(wg genkey)
	fi
fi

################# not usable for more than one wg interface
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
/etc/init.d/firewall restart

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
/etc/init.d/network restart
