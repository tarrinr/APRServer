#!/usr/bin/perl

use strict;
use warnings;

use Ham::APRS::IS;
use Ham::APRS::FAP qw(parseaprs);
use DBI;
use DBD::mysql;
use DateTime;

my $IShost = "noam.aprs2.net:14580";
my $ISmycall = "N0CALL";
my $ISfilter = "b/CALLSIGN*";
my $database = "APRS";
my $host = "localhost";
my $user = "APRS_user";
my $pw = "password";
my $port = "3306";

my $connect = DBI->connect("DBI:mysql:database=$database;host=$host;port=$port",$user,$pw, {mysql_auto_reconnect => 1}) or die "Failed to connect: $DBI::errstr";
my $query_aprsposits = $connect->prepare("INSERT INTO APRSPosits VALUES (NULL,?,?,?,?,?,?,?,?,?,?)");

my $is = new Ham::APRS::IS($IShost, $ISmycall, 'filter' => $ISfilter);
$is->connect('retryuntil' => 3) or die "Failed to connect: $is->{error}";

while (1){
  
  my $l = $is->getline_noncomment();

  if ($l) {
  
    my %packetdata;
    parseaprs($l, \%packetdata);

    if ($packetdata{type} eq 'location') {
      
      my $dt = DateTime->now(time_zone=>'America/Denver');
      print "$dt, $packetdata{origpacket}\n";
      $query_aprsposits->execute($dt, $packetdata{srccallsign}, $packetdata{latitude}, $packetdata{longitude}, $packetdata{altitude}, $packetdata{speed}, $packetdata{course}, $packetdata{symboltable}.$packetdata{symbolcode}, $packetdata{comment}, $packetdata{origpacket});
      system("php -f /home/APRS/markers.php > /var/www/html/markers.xml &");

    }
  }
}

