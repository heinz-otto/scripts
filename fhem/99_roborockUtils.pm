##############################################
# $Id: 99_roborockUtils.pm 23879 2021-03-02 11:52:16Z Otto123 $
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

sub valetudoRE {
my $EVENT = shift;
my $ret = 'error';
my @zid = ();
my ($cmd,$load) = split(' ', $EVENT,2);
my $topic = 'valetudo/rockrobo/custom_command';
if (@_) {Log 1,"sub valetudoRE - Befehl:$cmd Load:$load";return ''}
if ($cmd eq 'zoned_cleanup') {@zid = split ',',$load}

my %consum=();
for (qw(main_brush_work_time side_brush_work_time filter_work_time sensor_dirty_time))
    {$consum{(split '_',$_)[0]}=$_};
	
 my %Hcmd = (goto =>
  {
    command => 'go_to',
    spot_id => $load
  },zone =>
  {
    command => 'zoned_cleanup',
    zone_ids => \@zid
  },reset_consumable =>
  {
    command => 'reset_consumable',
    consumable => $consum{$load}
  },store_map => 
  {
    command => 'store_map',
    name => $load
  }, load_map => 
  {
    command => 'load_map',
    name => $load
  },get_dest =>
  { command => 'get_destinations'},
 );
 if ($cmd eq 'x_raw_payload') {$ret=$load}
 else {$ret = toJSON $Hcmd{$cmd}}
return $topic.' '.$ret
}

1;
