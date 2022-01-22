get the template to local FHEM

FHEM command

get the template
```
{ qx(wget -qO ./FHEM/lib/AttrTemplate/ottos.template https://raw.githubusercontent.com/heinz-otto/scripts/master/fhem/valetudo.template);; AttrTemplate_Initialize() }
```
```
{ qx(wget -qO ./FHEM/lib/AttrTemplate/ottos.template https://raw.githubusercontent.com/heinz-otto/scripts/master/fhem/sonos2mqtt.template);; AttrTemplate_Initialize() }
```
```
{ qx(wget -qO ./FHEM/lib/AttrTemplate/ottos.template https://raw.githubusercontent.com/heinz-otto/scripts/master/fhem/worx.template);; AttrTemplate_Initialize() }
```

remove template
```
{ qx(rm ./FHEM/lib/AttrTemplate/ottos.template);; AttrTemplate_Initialize() }
```
