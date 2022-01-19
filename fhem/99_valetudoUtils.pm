##############################################
# $Id:  $
# from myUtilsTemplate.pm 21509 2020-03-25 11:20:51Z rudolfkoenig
# utils for valetudo v2 API MQTT Implementation
# They are then available in every Perl expression.

package main;

use strict;
use warnings;
use JSON;Dumper;

sub
valetudoUtils_Initialize {
  my $hash = shift;
  return;
}
# Enter you functions below _this_ line.

#######
# return a string for dynamic selection setList (widgets)
sub valetudo_w {
my $NAME = shift;
my $setter = shift;
# this part reads segments, it's only filled if Provide map data is enabled in connectivity
if ($setter eq 'segments') {
  my $json = ReadingsVal($NAME,'.segments','{}');
  if ($json eq '{}') {$json = '{"1":"no_Segment_or_not_supported"}'};
  my $decoded = decode_json($json);
  return join ',', sort values %$decoded
  }
# this part read presets which contains a full json for preset zones or locations
if ($setter eq 'zones' or $setter eq 'locations') {
  my $json = valetudo_r('presets',ReadingsVal($NAME,'.'.$setter.'Presets',''));
  my $decoded = decode_json($json);
  return join ',', sort keys %$decoded
  }
# this part is for study purpose to read the full json segments with the REST API like
# setreading alias=DreameL10pro json_segments {(qx(wget -qO - http://192.168.90.21/api/v2/robot/capabilities/MapSegmentationCapability))}
if ($setter eq 'json_segments') {
  my $json = ReadingsVal($NAME,'json_segments','select');
  my $decoded = decode_json($json);
  my @array=@{$decoded};
  my %t;
  for (@array) { $t{$_->{'name'}} = $_->{'id'} }
  return join ',', sort keys %t 
  }
}
####### 
# is now used to pre read the json in valetudo_c
# return simpel json pairs from presets format of valetudo 
sub valetudo_r {
my $setter = shift;
my $payload = shift;
my $ret = 'error';
my %t;
if ($setter eq 'presets') {
  my $decoded = decode_json($payload);
  for (keys %$decoded) { $t{$decoded->{$_}->{'name'}} = $_ } # build a new hash only with names and ids pairs
  $ret = toJSON(\%t); # result is sorted
  }
  return $ret
}
#######
# valetudo_c return a complete string for setList right part
sub valetudo_c {
my $NAME = shift;
my $EVENT = shift;
my $ret = 'error';
my ($cmd,$load) = split(q{ }, $EVENT,2);
my $devicetopic = InternalVal($NAME,'DEVICETOPIC',"valetudo/$NAME");

# x_raw_payload like
# /MapSegmentationCapability/clean/set {"segment_ids":["6"],"iterations":1,"customOrder":true}
if ($cmd eq 'x_raw_payload') {$ret=$devicetopic.$load}

# this part return an array of segment id's according to selected Names from segments (simple json)
if ($cmd eq 'clean_segment') {
  my @rooms = split',', $load;
  my $json = ReadingsVal($NAME,'.segments','');
  my $decoded = decode_json($json);
  my @ids;
  for ( @rooms ) { push @ids,{reverse %$decoded}->{$_} }
  my %Hcmd = ( clean_segment => {segment_ids => \@ids,iterations => 1,customOrder => 'true' } );
  $ret = $devicetopic.'/MapSegmentationCapability/clean/set '.toJSON $Hcmd{$cmd}
  }

# this part return the zone/location id according to the selected Name from presets (zones/locations) (more complex json)
if ($cmd eq 'clean_zone') {
  my $json = valetudo_r('presets',ReadingsVal($NAME,'.zonesPresets',''));
  my $decoded = decode_json($json);
  $ret = $devicetopic.'/ZoneCleaningCapability/start/set '.$decoded->{$load}
  }
if ($cmd eq 'goto') {
  my $json = valetudo_r('presets',ReadingsVal($NAME,'.locationsPresets',''));
  my $decoded = decode_json($json);
  $ret = $devicetopic.'/GoToLocationCapability/go/set '.$decoded->{$load}
  }

# this part is for study purpose to read the full json segments with the REST API
# this part return an array of segment id's according to selected Names from json_segments (complex json)
if ($cmd eq 'clean_segment_j') {
  $cmd = 'clean_segment';             # only during Test
  my @rooms = split',', $load;
  my $json = ReadingsVal($NAME,'json_segments','');
  my $decoded = decode_json($json);
  my @array=@{$decoded};
  my %t;
  for (@array) { $t{$_->{'name'}} = $_->{'id'} }
  my @ids;
  for ( @rooms ) {push @ids, $t{$_}}
  my %Hcmd = ( clean_segment => {segment_ids => \@ids,iterations => 1,customOrder => 'true' } );
  $ret = $devicetopic.'/MapSegmentationCapability/clean/set '.toJSON $Hcmd{$cmd}
  }

return $ret
}


####### Aus dem Forum funktioniert aber nicht
# Zeigt aber wie man Readings zurück gibt 
sub
valetudo2svg($$$)
{
  my ($reading, $d, $filename) = @_;
  my %ret;

  if(!open FD,">$filename") {
    $ret{$reading} = "ERROR: $filename: $!";
    return \%ret;
  }
  print FD $d;
  close(FD);
  $ret{$reading} = "Wrote $filename";
  return \%ret;

  if($d !~ m/height":(\d+),"width":(\d+).*?floor":\[(.*\])\]/) {
    $ret{$reading} = "ERROR: Unknown format";
    return \%ret;
  }
  my ($w,$h,$nums) = ($1, $2, $3);

  my $svg=<<"EOD";
<?xml version="1.0" standalone="no"?>
<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 20010904//EN" "http://www.w3.org/TR/2001/REC-SVG-20010904/DTD/svg10.dtd">
<svg version="1.0" xmlns="http://www.w3.org/2000/svg" width="$w" height="$h" viewBox="0 0 $w $h">
<g fill="#000000" stroke="none">
  <rect x="0" y="0" width="$w" height="$h" stroke="black" stroke-width="1" fill="none"/>
EOD

  $nums =~ s/\[(\d+),(\d+)\]/
    $svg .= "<rect x=\"$1\" y=\"$2\" width=\"1\" height=\"1\"\/>\n";
    ""
  /xge;
  $svg .= "</g></svg>";

  if(!open FD,">$filename") {
    $ret{$reading} = "ERROR: $filename: $!";
    return \%ret;
  }
  print FD $svg;
  close(FD);
  $ret{$reading} = "Wrote $filename";
  return \%ret;
}

1;
=pod
=item summary    generic MQTT2 vacuum valetudo Device
=item summary_DE generische MQTT2 Staubsauger gerootet mit valetudo
=begin html

Subroutines for generic MQTT2 vacuum cleaner Devices rooted with valetudo.
<a id="MQTT2 valetudo"></a>
<h3>MQTT2 valetudoUtils</h3>
<ul>
  subroutines<br>
  <b>valetudo_w</b> return a string for dynamic selection setList<br>
  <b>valetudo_c</b> return a complete string for setList right part of setList<br>
  <br>
  <a id="MQTT2_DEVICE-setList"></a>
  <b>attr setList</b>
  <ul>
    <code>clean_segment:{"multiple-strict,".valetudo_w($name,"segments")} { valetudo_c($NAME,$EVENT) }</code>
    <br><br>
    To use dynamic setList. The $EVENT is parsed inside utils.<br>
  </ul>
  <br>
</ul>

=end html
=begin html_DE

Subroutines for generic MQTT2 vacuum cleaner Devices rooted with valetudo.
<a id="MQTT2 valetudo"></a>
<h3>MQTT2 valetudoUtils</h3>
<ul>
  subroutines<br>
  <b>valetudo_w</b> return a string for dynamic selection setList<br>
  <b>valetudo_c</b> return a complete string for setList right part of setList<br>
  <br>
  <a id="MQTT2_DEVICE-setList"></a>
  <b>attr setList</b>
  <ul>
    <code>clean_segment:{"multiple-strict,".valetudo_w($name,"segments")} { valetudo_c($NAME,$EVENT) }</code>
    <br><br>
    To use dynamic setList. The $EVENT is parsed inside utils.<br>
  </ul>
  <br>
</ul>


=end html_DE
=cut
