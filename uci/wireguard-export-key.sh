#!/bin/ash
# usage:
# ./wireguard-export-key.sh                # export all peers
# ./wireguard-export-key.sh <PublicKey>    # export config for PublicKey

WG_PUB=$1
# Configuration parameters
# WG_IF="vpn"           # interfacename to add client configs
# if more than one wireguard interface - the last one will win
for WG_IF in $(uci show network|grep proto=.wireguard| cut -d '.' -f 2); do 
  echo "interface $WG_IF"
done
WG_HOST=$( ip addr show $( uci get network.wan.device ) | grep 'inet '|grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'|head -1 )

# functions
function export_all () {
  for i in $( uci show network | grep -oE "wireguard_${WG_IF}\[\d+\].public_key"|grep -oE "\[\d+\]"|grep -oE '\d+' ) ;do
     print_config $( uci get network.@wireguard_${WG_IF}[$i].public_key )
	 #echo $i
	 #echo $( uci get network.@wireguard_${WG_IF}[$i].public_key )
  done 
}

function print_config () {
WG_PUB=$1
# get index for given public key
for index in $( uci show network | grep -oE "wireguard_${WG_IF}\[\d+\].public_key"|grep -oE "\[\d+\]"|grep -oE '\d+' ) ;do
   key=$(uci get network.@wireguard_${WG_IF}[$index].public_key)
   [ "$key" = "$WG_PUB" ] && i=$index
done 
WG_IPS=$( uci get network.@wireguard_${WG_IF}[$i].allowed_ips|tr ' ' ',' )
WG_ADDR=$( uci get network.@wireguard_${WG_IF}[$i].allowed_ips|cut -d ' ' -f 1 )
WG_PSK=$( uci -q get network.@wireguard_${WG_IF}[$i].preshared_key )
WG_PORT=$( uci get network.${WG_IF}.listen_port )
username=$( uci -q get network.@wireguard_${WG_IF}[$i].description )

# output config
cat <<-EOF
########## config for peer ${username:-noname}
[Interface]
Address = ${WG_ADDR}
PrivateKey = $(cat /etc/wireguard/keys/${username}_priv 2> /dev/null || echo private key not found)

[Peer]
PublicKey = $(uci get network.${WG_IF}.private_key|wg pubkey)
AllowedIPs = ${WG_IPS}
Endpoint = ${WG_HOST}:${WG_PORT}
$( [ -z ${WG_PSK} ] || echo PresharedKey = ${WG_PSK} )

EOF
}

# main, if no argument than export all
if [ -z ${WG_PUB} ] ;then 
  export_all
else 
  print_config ${WG_PUB}
fi
