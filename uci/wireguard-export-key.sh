#!/bin/ash
# Code is inspired from https://openwrt.org/docs/guide-user/services/vpn/wireguard/start

# functions
function usage () {
   echo "./wireguard-export-key.sh [searchword] [-qr|-h|--help|--qrencode]"
   echo "./wireguard-export-key.sh                # export all peers"
   echo "./wireguard-export-key.sh <PublicKey>    # export config for PublicKey"
   echo "./wireguard-export-key.sh ConfigName -qr # export config for ConfigName as QR Code"
}

function print_config () {
  search=${1//[+=\/]/.}                                # replace base64 special chars with single . for awk regExp search
  for section in $(uci show network |grep "wireguard_${WG_IF}" |awk -F. 'match($3,/'${search}'/) { print $1"."$2 }'); do
    if [ -z ${section} ];then 
       echo "the word ${search} not found in config"
    else
        WG_IPS=$( uci get ${section}.allowed_ips|tr ' ' ',' )
        WG_ADDR=$( uci get ${section}.allowed_ips|cut -d ' ' -f 1 )
        WG_PSK=$( uci -q get ${section}.preshared_key )
        username=$( uci -q get ${section}.description )

        # output config
        printf "\n########## config for peer ${username:-noname} ##########\n"
        # begin heredoc read into variable
        read -r -d '' WG_CLIENT_CONFIG <<-EOF
        [Interface]
        Address = ${WG_ADDR}
        PrivateKey = $(cat /etc/wireguard/keys/${username}_priv 2> /dev/null || echo private key not found)
        [Peer]
        PublicKey = $(uci get network.${WG_IF}.private_key|wg pubkey)
        AllowedIPs = ${WG_IPS}
        Endpoint = ${WG_HOST}:${WG_PORT}
        $( [ -z ${WG_PSK} ] || echo PresharedKey = ${WG_PSK} )
        EOF
        # end heredoc

        if [ "$qr" = "1" ]; then
          qrencode -t ansiutf8 "$WG_CLIENT_CONFIG"
        else
          echo "$WG_CLIENT_CONFIG"
        fi
    fi
  done
}

function export_all () {
  # read all public keys in config 
  for i in $( uci show network | grep -oE "wireguard_${WG_IF}\[\d+\].public_key"|grep -oE "\[\d+\]"|grep -oE '\d+' ) ;do
     print_config $( uci get network.@wireguard_${WG_IF}[$i].public_key )
  done 
}

# main
WG_HOST=$( ip addr show $( uci get network.wan.device ) | grep 'inet '|grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'|head -1 )

# process commandline arguments
qr=
while [ "$1" != "" ]; do
    case $1 in
        -qr | --qrencode )      qr=1
                                ;;
        -h | --help )           usage
                                exit
                                ;;
        * )                     WG_PUB=$1
    esac
    shift
done

for WG_IF in $(uci show network|grep proto=.wireguard| cut -d '.' -f 2); do 
    echo "interface $WG_IF"
    WG_PORT=$( uci get network.${WG_IF}.listen_port )

    if [ -z ${WG_PUB} ] ;then 
      export_all
    else 
      print_config ${WG_PUB}
    fi
done
