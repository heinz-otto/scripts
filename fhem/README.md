get the template to local FHEM

FHEM command
```
# get
"wget -qO ./FHEM/lib/AttrTemplate/ottos.template https://raw.githubusercontent.com/heinz-otto/scripts/master/fhem/valetudo.template";sleep 5;{ AttrTemplate_Initialize() }
# remove
"rm ./FHEM/lib/AttrTemplate/ottos.template";sleep 1;{ AttrTemplate_Initialize() }
```
