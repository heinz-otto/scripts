##############################################
# $Id: myUtilsTemplate.pm 21509 2020-03-25 11:20:51Z rudolfkoenig $
# from myUtilsTemplate.pm
# 99_sonos2mqttUtils
# They are then available in every Perl expression.

package main;

use strict;
use warnings;

sub
sonos2mqttUtils_Initialize($$)
{
  my ($hash) = @_;
}

# Enter you functions below _this_ line.

sub sonos2mqtt
{ 
my ($NAME,$EVENT)=@_;
my @arr = split(' ',$EVENT);
my ($cmd,$vol,$text);
$cmd = $arr[0];

if($cmd eq 'devStateIcon') {return sonos2mqtt_devStateIcon($NAME)}
if($cmd eq 'sayText') { ($cmd,$text) = split(' ', $EVENT,2)}
if($cmd eq 'speak') { ($cmd,$vol,$text) = split(' ', $EVENT,3)}
my $tts = ReadingsVal('SonosBridge','tts','SonosTTS');

my $payload = $EVENT;
my $ret;
my $value;
my $uuid = ReadingsVal($NAME,'uuid','error');
if (@arr == 1){$payload = "leer"} else {$payload =~ s/$cmd //}

if($cmd eq 'mute')   {$value = $payload eq "true" ? "mute" : "unmute"; $ret = qq(sonos/$uuid/control { "command": "$value" } )}
if($cmd eq 'input')  {$value = $payload eq "TV" ? "tv" : $payload eq "Line_In" ? "line" : "queue"; $ret = qq(sonos/$uuid/control { "command": "switchto$value" } ) }
if($cmd eq 'leaveGroup') {$value = ReadingsVal($uuid,"groupName","all"); $ret = qq(sonos/$uuid/control { "command": "leavegroup",  "input": "$value" } ) }
if($cmd eq 'playUri') {fhem("set $NAME setAVTUri $payload; sleep 1; set $NAME play")}

if($cmd eq 'stop') {$ret = qq(sonos/$uuid/control { "command": "stop" })}
if($cmd eq 'play') {$ret = qq(sonos/$uuid/control { "command": "play" })}
if($cmd eq 'pause') {$ret = qq(sonos/$uuid/control { "command": "pause" })}
if($cmd eq 'toggle') {$ret = qq(sonos/$uuid/control { "command": "toggle" })}
if($cmd eq 'volumeUp') {$ret = qq(sonos/$uuid/control { "command": "volumeup" })}
if($cmd eq 'volumeDown') {$ret = qq(sonos/$uuid/control { "command": "volumedown" })}
if($cmd eq 'next') {$ret = qq(sonos/$uuid/control { "command": "next" })}
if($cmd eq 'previous') {$ret = qq(sonos/$uuid/control { "command": "previous" })}
if($cmd eq 'volume') {$ret = qq(sonos/$uuid/control { "command": "volume", "input": $payload })}
if($cmd eq 'joinGroup') {$ret = qq(sonos/$uuid/control { "command": "joingroup",  "input": "$payload"})}
if($cmd eq 'setAVTUri') {$ret = qq(sonos/$uuid/control { "command": "setavtransporturi",  "input": "$payload"})}
if($cmd eq 'notify') {$ret = qq(sonos/$uuid/control { "command":"notify","input":{"trackUri":"$arr[2]","onlyWhenPlaying":false,"timeout":100,"volume":$arr[1],"delayMs":700}})}
if($cmd eq 'x_raw_payload') {$ret = qq(sonos/$uuid/control $payload)}
 
if($cmd eq 'sayText') { fhem("setreading $tts text ".ReadingsVal($tts,'text',' ').' '.$text.";sleep 0.4 tts;set $tts tts [$tts:text];sleep $tts:playing:.0 ;set $NAME notify [$tts:vol] [$tts:httpName];deletereading $tts text")}
if($cmd eq 'speak') { fhem("set $tts tts $text;sleep $tts:playing:.0 ;set $NAME notify $vol [$tts:httpName]")}
if($cmd eq 'playFav') {
	use JSON;use HTML::Entities;use Encode qw(encode decode);
	my $enc = 'UTF8';my $uri='';my $search=(split(' ', $EVENT,2))[1];
	$search=~s/[\/()]/./g;
	my $dev = (devspec2array('model=sonos2mqtt_bridge'))[0];
	my $decoded = decode_json(ReadingsVal($dev,'Favorites',''));
	my @array=@{$decoded->{'Result'}};
	foreach (@array) {if (encode($enc, decode_entities($_->{'Title'}))=~/$search/i)
	                   {$uri = $_->{'TrackUri'} }
		    };
			fhem("set $NAME playUri $uri") if ($uri ne '');
}

if($cmd eq 'test') {Log 1, "Das Device $NAME hat ausgeloest, die uuid ist >$uuid< der Befehl war >$cmd< der Teil danach sah so aus: $payload"}

return $ret;
}
#######
sub sonos2mqtt_devStateIcon
{
my ($name) = @_;
my $wpix = '210px';
my $master = ReadingsVal($name,'Master',$name);
my $inGroup = ReadingsNum($name,'inGroup','0');
my $isMaster = ReadingsNum($name,'isMaster','0');
my $inCouple = ReadingsNum($name,'inCouple','0');
my $Input = ReadingsVal($name,'Input','');
my $cover = ReadingsVal($name,'currentTrack_AlbumArtUri','');
my $mutecmd = ReadingsVal($name,'mute','0') eq 'false'?'true':'false';
my $mystate = $isMaster ? Value($name) : Value((devspec2array('DEF='.ReadingsVal($name,'coordinatorUuid','0')))[0]);
my $playpic = $mystate eq 'PLAYING'
  ? 'rc_PAUSE@red'    : $mystate eq 'PAUSED_PLAYBACK'
  ? 'rc_PLAY@green'   : $mystate eq 'STOPPED'
  ? 'rc_PLAY@green'   : $mystate eq 'TRANSITIONING'
  ? 'rc_PLAY@blue'    : 'rc_PLAY@yellow';
my $mutepic = $mutecmd eq 'true'?'rc_MUTE':'rc_VOLUP';
my $line2 = '';
my $title = $mystate eq 'TRANSITIONING' ? 'Puffern...' : ReadingsVal($name,'enqueuedMetadata_Title','FEHLER');
my $linePic = ($inGroup and !$isMaster and !$inCouple) ? "<a href=\"/fhem?cmd.dummy=set $name leaveGroup&XHR=1\">".FW_makeImage('rc_LEFT')."</a>" : "";
if ($isMaster) {$linePic .= " <a href=\"/fhem?cmd.dummy=set $name toggle&XHR=1\">".FW_makeImage($playpic)."</a>"};
   $linePic .= "&nbsp;&nbsp"
            ."<a href=\"/fhem?cmd.dummy=set $name volumeDown&XHR=1\">".FW_makeImage('rc_VOLDOWN')."</a>"
            ."<a href=\"/fhem?cmd.dummy=set $name previous&XHR=1\">".FW_makeImage('rc_PREVIOUS')."</a>"
            ."<a href=\"/fhem?cmd.dummy=set $name next&XHR=1\">".FW_makeImage('rc_NEXT')."</a>"
            ."<a href=\"/fhem?cmd.dummy=set $name volumeUp&XHR=1\">".FW_makeImage('rc_VOLUP')."</a>"
            ."&nbsp;&nbsp"
            ."<a href=\"/fhem?cmd.dummy=set $name mute $mutecmd&XHR=1\">".FW_makeImage($mutepic)."</a>";
if ($isMaster and $mystate eq 'PLAYING') {$line2 = $Input =~ /LineIn|TV/ ? $Input : "$title"}
    elsif ($inGroup and !$isMaster or $inCouple) {$line2 .= $inCouple ? "Stereopaar":"Steuerung: $master"}
my $style = 'display:inline-block;margin-right:5px;border:1px solid lightgray;height:4.00em;width:4.00em;background-size:contain;background-image:';
my $style2 ='background-repeat: no-repeat; background-size: contain; background-position: center center';
return "<div><table>
     <tr>
       <td><div style='$style url($cover);$style2'></div></td>
       <td>$linePic<br><div>$line2</div></td>
     </tr>
  </table></div>"
}
1;
