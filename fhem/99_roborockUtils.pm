##############################################
# $Id:  $
# from myUtilsTemplate.pm 21509 2020-03-25 11:20:51Z rudolfkoenig
# utils for Xiaomi Vaccum MQTT Implementation
# They are then available in every Perl expression.

package main;

use strict;
use warnings;

sub
roborockUtils_Initialize 
{
  my $hash = shift;
  return;
}
# Enter you functions below _this_ line.

sub valetudoREdest {
my $EVENT = shift;
my ($text,%h);
$text=decode_json($EVENT);
for ('spots','zones') {
    my @a;
    for my $i (0..$#{$text->{$_}}) {
      push @a, $text->{$_}->[$i]->{name}
    }
    $h{$_} = join q{,}, @a
  }
 return \%h
}

sub valetudoRE {
my $EVENT = shift;
my $ret = 'error';
my ($cmd,$load) = split(q{ }, $EVENT,2);
my $topic = 'valetudo/rockrobo';
my (@zid,@l,%consum);
if (@_) {Log 1,"sub valetudoRE - Befehl:$cmd Load:$load";return q{}}

if ($cmd eq 'zoned_cleanup') {@zid = split q{,},$load}
if ($cmd eq 'map') {@l = split q{ },$load}
for (qw(main_brush_work_time side_brush_work_time filter_work_time sensor_dirty_time))
    {$consum{(split q{_})[0]}=$_};
	 
 my %Hcmd = (
    goto =>     { command => 'go_to',spot_id => $load },
    get_dest => { command => 'get_destinations' },
    map =>      { command => $l[0].'_map',name => $l[1] },
	reset_consumable => { command => 'reset_consumable',consumable => $consum{$load} },
    zone =>     { command => 'zoned_cleanup',zone_ids => \@zid },
    store_map => 
  {
    command => 'store_map',
    name => $load
  },load_map => 
  {
    command => 'load_map',
    name => $load
  },
  );
 if ($cmd eq 'x_raw_payload') {$ret=$load}
 else {$ret = toJSON $Hcmd{$cmd}}
return '/custom_command '.$ret
}

1;
