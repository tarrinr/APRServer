#!/usr/bin/perl

use strict;
use warnings;

use JSON;
use LWP::Simple;
use Ham::APRS::FAP;
use IO::Socket;

my $spot_key = "SPOT KEY";
my $pass = "password";
my $aprs_server = "noam.aprs2.net";
my $aprs_port = "14580";
my $callsign = "CALLSIGN-12";
my $software = "SPOT";
my $symbol = "/{";
my $last_packet = "";

while (1) {

  my $encoded_json = get("https://api.findmespot.com/spot-main-web/consumer/rest-api/2.0/public/feed/$spot_key/latest.json") or die "Failed to connect";
  
  if ($encoded_json ne $last_packet) {
    
    $last_packet = $encoded_json;
    my $decoded = decode_json($encoded_json);

    if (!$decoded->{response}->{errors}) {
    
      my $longitude = $decoded->{response}->{feedMessageResponse}->{messages}->{message}->{longitude};
      my $latitude = $decoded->{response}->{feedMessageResponse}->{messages}->{message}->{latitude};
      my $messagetype = $decoded->{response}->{feedMessageResponse}->{messages}->{message}->{messageType};
      my $batterystate = $decoded->{response}->{feedMessageResponse}->{messages}->{message}->{batteryState};

      my $position = Ham::APRS::FAP::make_position($latitude,$longitude,0,0,0,$symbol,0,0);

      my $packet = "$callsign>$software,TCPIP*:=$position $messagetype/BATTERY-$batterystate";
      print "$packet\n";

      my $sock = new IO::Socket::INET (PeerAddr => "$aprs_server", PeerPort => "$aprs_port", Proto => "tcp") or die "Can't bind : $@\n";;
      print $sock "user $callsign pass $pass\n";
      print $sock "$packet\n";
      close($sock);

    }
  }

  sleep(150);
}