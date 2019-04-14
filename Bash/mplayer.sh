#!/bin/sh
# Das Script simuliert den mplayer Aufruf im Text2Speech Modul von FHEM
# attr MyTTS TTS_MplayerCall /opt/fhem/mplayer.sh
# zum Test ausgeben
#echo Parameteranzahl $# > /tmp/mplay.txt;

# falls volume nicht vorhanden = 1
volume=1;
# hw Format für mplayer hw=1.0 Format für play hw:1,0 beachte Doppelpunkt und Komma!
device=hw:0,0;
# Dateinamen und Volume ermitteln
while [ $# -gt 0 ]; do
	#echo $1 >> /tmp/mplay.txt;
	if [ $1 = -volume ]; then
		shift;
		#echo $1 >> /tmp/mplay.txt;
		if [ $1 -lt 100 ]; then
			volume=0.$(($1));
		fi    
	elif [ $1 = -ao ]; then
		shift;
		#-ao alsa:device=
		#echo $1 >> /tmp/mplay.txt;
		device=${1#*=};
	elif [ -e $1 ]; then
		file=$1;
	fi
	shift;
done
# zum Test ausgeben
#echo $device $volume $file >> /tmp/mplay.txt;
AUDIODEV=$device play -q -v $volume $file;
exit 0;
