#!/bin/sh
# For FHEM, will restore "last known good configuration" if something goes wrong
# the script will give all paths below $rd including the 2 last backups
# select one by hand and exit after restore

# PS3 is a bash prompt statement
PS3='Select Number for Path to restore: '
# base directory
rd=/opt/fhem/restoreDir/

# get all subdir's
dirs=($(ls $rd))
dirs2=()
# loop for date directories, take only the last two
for dir in "${dirs[@]}"
 do
   dat=($(ls $rd$dir))
   dirs2+=($dir/${dat[-1]} $dir/${dat[-2]})
done
# select, prompt, execute and exit
select dir in "${dirs2[@]}"
 do
   case $dir in
        $dir)   sudo -su fhem cp -R $rd$dir/* /opt/fhem/;;
   esac
   exit
done
