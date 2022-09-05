Here some Scripts for special OpenWrt with busybox and uci environment. Note: shell is ash,  wget is only uclient-fetch and shell parameter expansion is limited
# Manage wireguard setup on OpenWrt
Setup software for wireguard Server and generate intreface with defaults - according to the proposal from [OpenWrt Wiki ](https://openwrt.org/docs/guide-user/services/vpn/wireguard/server)
generate new private KEY, IP=192.168.9.1, Port=51820, NAME=vpn
```
./wireguard-setup-server.sh
./wireguard-setup-server.sh $(wg genkey) '10.6.0.1' 51821 wg0
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
