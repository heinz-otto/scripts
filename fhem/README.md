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

get a utils file local to FHEM
```
{ my $f ='99_valetudoUtils.pm';; qx(wget -qO "./FHEM/$f" "https://raw.githubusercontent.com/heinz-otto/scripts/master/fhem/$f");; fhem("sleep 2;;reload $f") }
```
replace the file with the original svn file
```
{ my $f ='99_valetudoUtils.pm';;{ Svn_GetFile("contrib/AttrTemplate/$f", "FHEM/$f", sub(){CommandReload(undef, $f)}) } }
```
