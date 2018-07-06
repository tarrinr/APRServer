#!/usr/bin/perl

use strict;
use warnings;

use JSON;
use LWP::Simple;
use DBI;
use DBD::mysql;
use DateTime;

my $spot_key = "SPOT KEY";
my $database = "APRS";
my $host = "localhost";
my $user = "APRS_user";
my $pw = "password";
my $port = "3306";
my $last_packet = "";

my $connect = DBI->connect("DBI:mysql:database=$database;host=$host;port=$port",$user,$pw, {mysql_auto_reconnect => 1}) or die "Failed to connect: $DBI::errstr";
my $query_aprsposits = $connect->prepare("INSERT INTO APRSPosits VALUES (NULL,?,?,?,?,?,?,?,?,?,?)");

while (1) {

  my $encoded_json = get("https://api.findmespot.com/spot-main-web/consumer/rest-api/2.0/public/feed/$spot_key/latest.json") or die "Failed to connect";
  
  if ($encoded_json ne $last_packet) {
    
    $last_packet = $encoded_json;
    my $decoded = decode_json($encoded_json);

    if (!$decoded->{response}->{errors}) {
    
      my $epoch = $decoded->{response}->{feedMessageResponse}->{messages}->{message}->{unixTime};
      my $name = $decoded->{response}->{feedMessageResponse}->{messages}->{message}->{messengerName};
      my $longitude = $decoded->{response}->{feedMessageResponse}->{messages}->{message}->{longitude};
      my $latitude = $decoded->{response}->{feedMessageResponse}->{messages}->{message}->{latitude};
      my $messagetype = $decoded->{response}->{feedMessageResponse}->{messages}->{message}->{messageType};
      my $batterystate = $decoded->{response}->{feedMessageResponse}->{messages}->{message}->{batteryState};
      my $packet = $decoded->{response}->{feedMessageResponse}->{messages}->{message}->{messageContent};

      my $dt = DateTime->from_epoch(epoch => $epoch, time_zone=>'America/Denver');
      print "$messagetype\n";
      $query_aprsposits->execute($dt, $name, $latitude, $longitude, undef, undef, undef, "/{", "$messagetype/BATTERY-$batterystate<br/>$packet", undef) or die "Failed to execute: $DBI::errstr";
      system("php -f /home/APRS/markers.php > /var/www/html/markers.xml &");      
    }
  }

  sleep(150);
}
