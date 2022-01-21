get the template to local FHEM

FHEM command

get the template
```
"wget -qO ./FHEM/lib/AttrTemplate/ottos.template https://raw.githubusercontent.com/heinz-otto/scripts/master/fhem/valetudo.template";sleep 5;{ AttrTemplate_Initialize() }"
```
remove template
```
"rm ./FHEM/lib/AttrTemplate/ottos.template";sleep 1;{ AttrTemplate_Initialize() }"
```
