# Dienste in Array
array=( mysql fhem habridge )

# Alle Elemente im Array durchlaufen
for dienst in ${array[*]}
do
   service $dienst stop
done

....

#Wieder starten (analog stop als Einzeiler)
for dienst in ${array[*]};do service $dienst start;done

# Alternativ in umgekehrter Reihenfolge 
for ((i=${#array[*]}; i>0; i--));do service ${array[i-1]} start;done
