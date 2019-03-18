MAC=$1
host=$2
user="root"
ssh $user@$host '
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
    echo 1
  else
    echo 0
  fi
'
