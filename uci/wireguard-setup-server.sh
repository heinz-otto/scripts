#!/bin/sh
# Code is based on https://openwrt.org/docs/guide-user/services/vpn/wireguard/server
# usage: ./wireguard-setup-server.sh KEY ADDR PORT IFname
# usage with pipe: echo "KEY ADDR PORT IFname"|xargs ./wireguard-setup-server.sh
# create new wireguard server interface ./wireguard-setup-server.sh $(wg genkey) "192.168.10.1/24" 51830 vpn10

# Configuration parameters, read from input or setting defaults
# if parameter is empty the string is expanded https://www.gnu.org/software/bash/manual/html_node/Shell-Parameter-Expansion.html
WG_KEY=$1
WG_ADDR=${2:-"192.168.9.1/24"}
WG_PORT=${3:-"51820"}
WG_IF=${4:-"vpn"}
WG_SUB=${WG_ADDR%/*}; WG_SUB=${WG_SUB%.*}; WG_SUB=${WG_SUB#*.*.}
WG_ADDR6=${5:-"fdf1:e8a1:8d3f:${WG_SUB}::1/64"}
# base path for confing & key files if exists
WG_DIR="/etc/wireguard" 
WG_DIR_KEYS="${WG_DIR}/keys"
mkdir -p ${WG_DIR_KEYS}

# Install packages
if [ -z $(opkg list-installed|grep -o kmod-wireguard) ]; then
    opkg update
    opkg install wireguard-tools luci-app-wireguard luci-proto-wireguard 
    #optional 
    opkg install qrencode nano tcpdump-mini
 else
    echo "software already installed"
fi

# read or generate servers private key, a new key will only saved in the config
if [ -z ${WG_KEY} ]; then
    if [ -f "${WG_DIR_KEYS}/wgserver.key" ]; then 
      echo 'read key from file'
      WG_KEY=$(cat "${WG_DIR_KEYS}/wgserver.key")
    else
      echo 'create new key'
      WG_KEY=$(wg genkey)
    fi
fi

# Configure firewall
uci rename firewall.@zone[0]="lan"
uci rename firewall.@zone[1]="wan"
uci del_list firewall.lan.network="${WG_IF}"
uci add_list firewall.lan.network="${WG_IF}"
for rule in $(uci show firewall|awk -F. 'match($3,/Allow-WireGuard-'$WG_IF'/) { print $1"."$2 }') ; do
   uci -q delete $rule
done
uci add firewall rule
uci set firewall.@rule[-1].name="Allow-WireGuard-${WG_IF}"
uci set firewall.@rule[-1].src='wan'
uci set firewall.@rule[-1].dest_port="${WG_PORT}"
uci set firewall.@rule[-1].proto='udp'
uci set firewall.@rule[-1].target='ACCEPT'
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
