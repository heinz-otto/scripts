#!/bin/bash
# Laufzeit des Scripts messen Zeitmessung Start.
REAL_STARTTIME=$(date +%s) #(($STARTTIME - $PRE_NETWORK_DURATION))
echo ""
echo "Script started at $(date --date="@$REAL_STARTTIME" --utc)."

for((i=10; i>0; i--))
do
   #echo $i
   bash fhemcmd.sh 8083 "set Aktor01 toggle"
   #perl fhemcmd.pl 8083 "set Aktor01 toggle"
   #perl /opt/fhem/fhem.pl 7072 "set Aktor01 toggle"
   #sleep 1   # Eine Sekunde anhalten
done

# sleep 5

# Laufzeit des Scripts messen Berechnung und Ausgabe
ENDTIME=$(date +%s) 
DURATION=$(($ENDTIME - $REAL_STARTTIME)) 
echo -n "Script finished at $(date --date="@$ENDTIME" --utc)"
echo " time was  $(($DURATION/60)) min $(($DURATION%60)) sec ($DURATION seconds)"
