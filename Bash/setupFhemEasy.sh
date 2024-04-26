#!/bin/bash
# Setup FHEM
# von debian.fhem.de installieren - siehe aktuelle Anleitung dort https://debian.fhem.de/
# temporärer Workaround wenn mal das Paket nicht signiert ausgeliefert wird   
# echo "deb [trusted=yes] http://debian.fhem.de/nightly/ /" >> /etc/apt/sources.list
if [[ "$(apt list fhem)" =~ "installed" ]] ;then
    echo fhem ist bereits installiert
else
  # get debian version strings with dot sourcing
  . /etc/os-release
  if [ $VERSION_ID -ge 10 ] ;then
    apt install gpg
    if wget -qO - https://debian.fhem.de/archive.key | gpg --dearmor > /usr/share/keyrings/debianfhemde-archive-keyring.gpg ;then
      echo "deb [signed-by=/usr/share/keyrings/debianfhemde-archive-keyring.gpg] https://debian.fhem.de/nightly/ /" >> /etc/apt/sources.list
      key='ok'
    fi
  else 
    if [ "$(wget -qO - http://debian.fhem.de/archive.key | apt-key add -)" = "OK" ] ;then
      echo "deb http://debian.fhem.de/nightly/ /" >> /etc/apt/sources.list
      key='ok'
    fi
  fi
  if [ $key = 'ok' ] ;then
    apt-get update
    apt-get install fhem -y
  else
    echo Es gab ein Problem mit dem debian.fhem.de/archive.key
    exit 1
  fi
fi
