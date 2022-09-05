Here some Scripts for special OpenWrt with busybox and uci environment. wget is only uclient-fetch and shell parameter expansion is limited
# fetch more than one script
```
url='https://raw.githubusercontent.com/heinz-otto/scripts/master/uci/'
for fname in import-key export-conf setup-server; do 
   wget -O wireguard-${fname}.sh ${url}wireguard-${fname}.sh
done
chmod +x wireguard-*.sh
```
