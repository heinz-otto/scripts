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

get a Utils File local to FHEM
```
{ $data{f}='99_valetudoUtils.pm';; qx(wget -qO "./FHEM/$data{f}" "https://raw.githubusercontent.com/heinz-otto/scripts/master/fhem/$data{f}");; CommandReload(undef, $data{f}) }
```
replace them with the svn file
```
{ $data{f}='99_valetudoUtils.pm';;{ Svn_GetFile("contrib/AttrTemplate/$data{f}", "FHEM/$data{f}", sub(){CommandReload(undef, $data{f})}) } }
```
