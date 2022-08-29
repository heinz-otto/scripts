#!/bin/ash

if [ -z "$1" ]; then
  echo "usage: ./wireguard-import-key client-public-key [client-preshared-key [username]]"
  exit
fi

# Configuration parameters
# WG_IF="vpn"           # interfacename to add client configs
# only one wireguard interface should exist
WG_IF=$(uci show network|grep proto=.wireguard| cut -d '.' -f 2)

WG_PUB=$1
WG_PSK=$2
username=$3
#create username if empty
#[ -z $username ] && username="${WG_IF}_peer_${peer_IP}"

WG_PORT=$(uci get network.${WG_IF}.listen_port)
WG_ADDR=$(uci get network.${WG_IF}.addresses|awk '{print $1}')
WG_ADDR6=$(uci get network.${WG_IF}.addresses|awk '{print $2}')

#get the highest last digit number from the IPv4 Address Field inside all configured peers 
peer_IP=$(uci show network|grep wireguard_${WG_IF}....allowed_ips|cut -d= -f2|sort -V|tail -1| cut -d '.' -f 4 | cut -d '/' -f 1)
[ -z $peer_IP ] && peer_IP=${WG_ADDR: -4:1}
#simpel next digit
#peer_IP=$((peer_IP+1))

# Add VPN peers to network config
uci add network wireguard_${WG_IF}
uci set network.@wireguard_${WG_IF}[-1].public_key="${WG_PUB}"
[ -z ${WG_PSK} ] || uci set network.@wireguard_${WG_IF}[-1].preshared_key="${WG_PSK}"
[ -z ${username} ] || uci set network.@wireguard_${WG_IF}[-1].description="${WG_IF}_${username}"
uci add_list network.@wireguard_${WG_IF}[-1].allowed_ips="${WG_ADDR%.*}.${peer_IP}/32"
uci add_list network.@wireguard_${WG_IF}[-1].allowed_ips="${WG_ADDR6%:*}:${peer_IP}/128"
uci add_list network.@wireguard_${WG_IF}[-1].persistent_keepalive='25'

uci commit network
#network restart is needed
