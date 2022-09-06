#!/bin/ash
# Code is inspired from https://openwrt.org/docs/guide-user/services/vpn/wireguard/start
# https://www.gnu.org/software/bash/manual/html_node/Shell-Parameter-Expansion.html

if [ -z "$1" ]; then
  echo "usage:"
  echo "wireguard-import-key.sh 'PublicKey' ['PresharedKey' ['username' ['AllowedIPs']]]"
  echo "echo 'PublicKey [PresharedKey [username [AllowedIPs]'|xargs ./wireguard-import-key.sh"
  exit
fi

# Configuration parameters
# WG_IF="vpn"           # interfacename to add client configs
# if more than one wireguard interface - the last one will win
for WG_IF in $(uci show network|grep proto=.wireguard| cut -d '.' -f 2);do echo "wireguard interface $WG_IF exist"; done

WG_PUB=$1
WG_PSK=$2
username=$3
AllowedIPs=$4

WG_PORT=$(uci get network.${WG_IF}.listen_port)
WG_ADDR=$(uci get network.${WG_IF}.addresses|awk '{print $1}')
WG_ADDR6=$(uci get network.${WG_IF}.addresses|awk '{print $2}')

#get the highest last digit number from the IPv4 Address Field inside all configured peers 
WG_ADDR=${WG_ADDR%/*} # strip network mask
peer_IP=$(uci show network|grep wireguard_${WG_IF}....allowed_ips|cut -d= -f2|sort -V|tail -1| cut -d '.' -f 4 | cut -d '/' -f 1)
[ -z $peer_IP ] && peer_IP=${WG_ADDR#*.*.*.}  
# next digit
peer_IP=$((peer_IP+1))

# create username if empty
username=${username:-"${WG_IF}_peer_${peer_IP}"}

# Add VPN peers to network config
uci add network wireguard_${WG_IF}
uci set network.@wireguard_${WG_IF}[-1].public_key="${WG_PUB}"
[ -z ${WG_PSK} ] || uci set network.@wireguard_${WG_IF}[-1].preshared_key="${WG_PSK}"
uci set network.@wireguard_${WG_IF}[-1].description=${username} 
uci add_list network.@wireguard_${WG_IF}[-1].persistent_keepalive='25'

# if AllowedIPs provided otherwise generate 
if [ -z ${AllowedIPs} ] ;then
   uci add_list network.@wireguard_${WG_IF}[-1].allowed_ips="${WG_ADDR%.*}.${peer_IP}/32"
   uci add_list network.@wireguard_${WG_IF}[-1].allowed_ips="${WG_ADDR6%:*}:${peer_IP}/128"
 else
   for AllowedIP in $(echo $AllowedIPs| tr ',' ' ');do 
     uci add_list network.@wireguard_${WG_IF}[-1].allowed_ips="$AllowedIP" 
   done
fi 

if [ -f /etc/wireguard/keys/_priv ];then
  mv /etc/wireguard/keys/_priv /etc/wireguard/keys/${username}_priv
fi

uci commit network

echo "created wireguard peer for Interface ${WG_IF} with Name ${username}"
echo a final network restart is needed
