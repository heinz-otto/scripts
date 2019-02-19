#!/usr/bin/env perl
# Heinz-Otto Klas 2019
# send commands to FHEM over HTTP
# if no Argument, show usage

use strict;
use warnings;
use URI::Escape;
use LWP::UserAgent;

my $token;
my $hosturl;
my $fhemcmd;

 if ( not @ARGV ) {
     print 'fhemcl Usage',"\n";
     print 'fhemcl [http://<hostName>:]<portNummer> "FHEM command1" "FHEM command2"',"\n";
     print 'fhemcl [http://<hostName>:]<portNummer> filename',"\n";
     print 'echo -e "set Aktor01 toggle" | [http://<hostName>:]<portNumber>',"\n";
     exit;
 }

if ($ARGV[0] !~ m/:/) {
   if ($ARGV[0] eq ($ARGV[0]+0)) { # isnumber?
       $hosturl = "http://localhost:$ARGV[0]";
   }
   else {
       print "$ARGV[0] is not a Portnumber";
       exit(1);
   }
}
else {
    $hosturl = $ARGV[0];
}

# get token 
my $ua = new LWP::UserAgent;
my $url = "$hosturl/fhem?XHR=1/";
my $resp = $ua->get($url);
   $token = $resp->header('X-FHEM-CsrfToken');

my @cmdarray ;

# test the pipe and read 
if (-p STDIN) {
   while(<STDIN>) {
       chomp($_);
       push(@cmdarray,$_);
   }
}
# second Argument is file or command?
if ($ARGV[1] and -e $ARGV[1]) {
    open(DATA, '<', $ARGV[1]);
    while(<DATA>) {
       chomp($_);
       push(@cmdarray,$_);
    }
    close(DATA);
}
else {
    for(my $i=1; $i < int(@ARGV); $i++) {
    push(@cmdarray, $ARGV[$i]);
    }
}
#execute commands and print response from FHEMWEB 
for(@cmdarray) {
    $fhemcmd = uri_escape($_);
    $url = "$hosturl/fhem?cmd=$fhemcmd&fwcsrf=$token";
    $resp = $ua->get($url)->content;
	# only between the lines <pre></pre> and remove any HTML Tag
	my @resparray = split("\n", $resp);
	foreach my $zeile(@resparray){
		if ($zeile !~ /<[^>]*>/ or $zeile =~ /pre>/ or $zeile =~ /NAME/) {
		   $zeile =~ s/<[^>]*>//g;
		   print "$zeile\n" ;
		}
    }
}
