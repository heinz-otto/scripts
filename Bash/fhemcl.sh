#!/bin/bash
# Heinz-Otto Klas 2019
# send commands to FHEM over HTTP
# if no Argument, show usage

if [ $# -eq 0 ]
then
     echo 'fhemcl Usage'
     echo 'fhemcl [http://<hostName>:]<portNummer> "FHEM command1" "FHEM command2"'
     echo 'fhemcl [http://<hostName>:]<portNummer> filename'
     echo 'echo -e "set Aktor01 toggle" | [http://<hostName>:]<portNumber>'
     exit 1
fi

# split the first Argument
IFS=:
arr=($1)

# if only one then use as portNumber
# or use it as url
IFS=
if [ ${#arr[@]} -eq 1 ]
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

# get Token 
token=$(curl -s -D - "$hosturl/fhem?XHR=1" | awk '/X-FHEM-csrfToken/{print $2}')

# reading FHEM command, from Pipe, File or Arguments 
# Check to see if a pipe exists on stdin.
cmdarray=()
if [ -p /dev/stdin ]; then
        echo "Data was piped to this script!"
        # If we want to read the input line by line
        while IFS= read line; do
                echo "Pipe Line: ${line}"
				cmdarray+=("${line}")
        done
else
        # Checking the 2 parameter: filename exist or simple commands
        if [ -f "$2" ]; then
                echo "Filename specified: ${2}"
                echo "Reading File.."
				while IFS= read line; do
					echo "File Line: ${line}"
					cmdarray+=("${line}")
				done < ${2}
        else
		    echo "Reading further parameters"
		    for ((a=2; a<=${#}; a++)); do
                echo "command specified: ${!a}"
				cmdarray+=("${!a}")
			done
        fi
fi

# loop over all lines stepping up. For stepping down (i=${#cmdarray[*]}; i>0; i--)
for ((i=1; i<=${#cmdarray[*]}; i++));do 
    echo "proceeding Line ${i-1}:"${cmdarray[i-1]}
	# urlencode loop over String
    cmd=''
    for ((pos=0;pos<${#cmdarray[i-1]};pos++)); do
        c=${cmdarray[i-1]:$pos:1}
        [[ "$c" =~ [a-zA-Z0-9\.\~\_\-] ]] || printf -v c '%%%02X' "'$c"
        cmd+="$c"
    done
	# send command to FHEM and filter the output (tested with list...).
	# give only lines between, including the two Tags zurück, then remove all HTML Tags 
	curl -s --data "fwcsrf=$token" $hosturl/fhem?cmd=$cmd | sed -n '/<pre>/,/<\/pre>/p' |sed 's/<[^>]*>//g'
done
