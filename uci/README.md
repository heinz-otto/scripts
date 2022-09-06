Here some Scripts for special OpenWrt with busybox and uci environment. Note: shell is ash,  wget is only uclient-fetch and shell parameter expansion is limited
# Manage wireguard setup on OpenWrt
Make a complete setup: install software for wireguard Server and generate an interface with defaults - according to the proposal from [OpenWrt Wiki ](https://openwrt.org/docs/guide-user/services/vpn/wireguard/server)

privateKEY, IP=192.168.9.1/24, Port=51820, IFname=vpn
```
./wireguard-setup-server.sh
./wireguard-setup-server.sh $(wg genkey) '10.6.0.1/24' 51821 wg0
```
import a Peer public key or create a new Peer
```
./wireguard-import-key.sh <public key> ['PresharedKey' ['username' ['AllowedIPs']]]
./wireguard-import-key.sh $(wg genkey | tee /etc/wireguard/keys/vpnUser1_priv | wg pubkey) $(wg genpsk) "vpnUser1"
```
export all or one config from known public key or peer name as text or qr code
```
./wireguard-export-conf.sh [<PublicKey|Name>] [-qr]
```
fetch all necessary scripts
```
url='https://raw.githubusercontent.com/heinz-otto/scripts/master/uci/'
for fname in import-key export-conf setup-server; do 
   wget -O wireguard-${fname}.sh ${url}wireguard-${fname}.sh
done
chmod +x wireguard-*.sh
```
copy a pivpn (wireguard) **server** configuration to OpenWrt
```
export remote=user@host
sudo -sE <<-'EOS'
WG_IF=wg0
WG_KEY=$( wg showconf $WG_IF|grep PrivateKey| awk '{printf($3)}' )
WG_ADDR=$( ip addr show $WG_IF|grep 'inet '|grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'| tr -d $'\n' )/32
WG_PORT=$( wg showconf $WG_IF|grep ListenPort| awk '{printf($3)}' )
# transfer to OpenWrt Router
echo "$WG_KEY $WG_ADDR $WG_PORT $WG_IF"|ssh ${remote} 'xargs ./wireguard-setup-server.sh'
EOS
```
copy a pivpn (wireguard) **peer** configuration to OpenWrt
```
sudo -sE <<-'EOS'
for username in $( cat /etc/wireguard/wg0.conf|grep "### begin " | awk '{printf ($3 " ")}' ); do
   for var in PublicKey PresharedKey AllowedIPs; do
       val=$( cat /etc/wireguard/wg0.conf|grep "### begin ${username}" -A4|grep ${var}| awk '{printf($3)}' )
       eval "${var}='${val}'"
   done
   echo "$PublicKey $PresharedKey $username $AllowedIPs"|ssh ${remote} 'xargs ./wireguard-import-key.sh'
done
ssh ${remote} '/etc/init.d/network restart'
EOS
```
