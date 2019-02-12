#!/bin/bash
# Befehle an FHEM senden
# Falls keine Angaben Hilfetext ausgeben
if [ $# -eq 0 ]
then
     echo 'fhemcmd bitte so verwenden'
     echo 'fhemcmd [http://<hostName>:]<portNummer> "FHEM Befehl"'
     echo 'fhemcmd [http://<hostName>:]<portNummer> Dateiname'
     echo 'echo -e "set Aktor01 toggle" | [http://<hostName>:]<portNummer>'
     exit 1
fi

# Ersten Parameter aufspalten und pruefen
IFS=:
Array=($1)

# Wenn nur ein Element, als Portnummer verwenden
# sonst als hosturl verwenden
IFS=
if [ ${#Array[@]} -eq 1 ]
then
    if [[ `echo "$1" | grep -E ^[[:digit:]]+$` ]]
    then
        hosturl=http://localhost:$1
	else
	    echo "$1 is not a Portnumber"
		exit 1
	fi
else
    hosturl=$1
fi

# Token holen
token=$(curl -s -D - "$hosturl/fhem?XHR=1" | awk '/X-FHEM-csrfToken/{print $2}')

# fhem cmd einlesen, entweder aus der Pipe, Datei oder zweiter Parameter 
# Check to see if a pipe exists on stdin.
cmdarray=()
if [ -p /dev/stdin ]; then
        echo "Data was piped to this script!"
        # If we want to read the input line by line
        while IFS= read line; do
                echo "Pipe Line: ${line}"
				cmdarray+=("${line}")
        done
        # Or if we want to simply grab all the data, we can simply use cat instead
        #cat
else
        # Checking the 2 parameter: filename exist or simple command
        if [ -f "$2" ]; then
                echo "Filename specified: ${2}"
                echo "Reading File.."
				while IFS= read line; do
					echo "File Line: ${line}"
					cmdarray+=("${line}")
				done < ${2}
        else
                echo "command as parameter specified: ${2}"
				cmdarray+=("${2}")
        fi
fi

# Schleife ueber alle Zeilen aufsteigend. Fuer absteigend(i=${#cmdarray[*]}; i>0; i--)
for ((i=1; i<=${#cmdarray[*]}; i++));do 
    echo "proceeding Line ${i-1}:"${cmdarray[i-1]}
    #oder perl uri_escape verwenden
    #cmd=$(perl -MURI::Escape -e 'print uri_escape($ARGV[0]);' "${cmdarray[i-1]}")
    # urlencode Schleife ueber String
    cmd=''
    for ((pos=0;pos<${#cmdarray[i-1]};pos++)); do
        c=${cmdarray[i-1]:$pos:1}
        [[ "$c" =~ [a-zA-Z0-9\.\~\_\-] ]] || printf -v c '%%%02X' "'$c"
        cmd+="$c"
    done
	# Befehl absetzen und Output filtern (mit list getestet).
	# der erste sed Ausdruck gibt Text zwischen den beiden Tags zurück, der zweite entfernt die Tags 
	curl -s --data "fwcsrf=$token" $hosturl/fhem?cmd=$cmd | sed -n '/<pre>/,/<\/pre>/p' |sed 's/<[^>]*>//g'
done
