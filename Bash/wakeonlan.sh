#!/bin/bash
#first shot
MAC=11:22:33:44:55:66
Broadcast=255.255.255.255
PortNumber=9
echo -e $(echo $(printf 'f%.0s' {1..12}; printf "$(echo $MAC | sed 's/://g')%.0s" {1..16}) | sed -e 's/../\\x&/g') | nc -w1 -u -b $Broadcast $PortNumber
