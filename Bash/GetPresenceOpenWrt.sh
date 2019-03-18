#!/bin/bash
# Some Parameter, Devicename in FHEM and MAC Address as parameter 
DEV=$1
MAC=$2
hosturl="http://192.168.56.80:8088"
# From here ssh command in one String between ' '
# This commands running remotely in OpenWrt.
ssh root@wrt1900 '
  # Url zu FHEM
  u='"$hosturl"'/fhem?cmd=set%20'"$DEV"'%20
  if (
      for m in $(
                 for w in $(iwinfo |grep -oE "wlan\d-\d|wlan\d")
                 do
                   iwinfo $w assoclist | grep -o -E "([[:xdigit:]]{1,2}:){5}[[:xdigit:]]{1,2}"
                 done
                )
      do
        [ "$m" = '"$MAC"' ] && exit 0
      done
      exit 1
    )
  then
   c=present
  else
   c=absent
  fi
  # tue nur etwas wenn sich c geändert hat, 
  # das muss noch geändert werden
  if [ "$c1" != "$c" ] ; then wget -qs $u$c ; c1=$c ; fi
'
