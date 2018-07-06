#!/usr/bin/perl

use strict;
use warnings;

use JSON;
use DBI;
use DBD::mysql;
use DateTime;

my $filename = "/home/lora/latest.json";
my $database = "APRS";
my $host = "localhost";
my $user = "APRS_user";
my $pw = "password";
my $port = "3306";

my $connect = DBI->connect("DBI:mysql:database=$database;host=$host;port=$port",$user,$pw, {mysql_auto_reconnect => 1}) or die "Failed to connect: $DBI::errstr";
my $query_aprsposits = $connect->prepare("INSERT INTO APRSPosits VALUES (NULL,?,?,?,?,?,?,?,?,?,?)");

open (my $fh, '<', $filename) or die "Failed to open file: $!";
my $encoded_json = do { local($/); <$fh> };
close($fh);

my $decoded = decode_json($encoded_json);

if ($decoded->{payload_fields}) {

  my $name = $decoded->{dev_id};
  my $payload = $decoded->{payload_raw};
  my $gat = @{$decoded->{metadata}->{gateways}};
  my $alt = $decoded->{payload_fields}->{ALT};
  my $ew = $decoded->{payload_fields}->{EW};
  my $hacc = $decoded->{payload_fields}->{HACC};
  my $hour = $decoded->{payload_fields}->{HOUR};
  my $hvel = $decoded->{payload_fields}->{HVEL};
  my $latdec = $decoded->{payload_fields}->{LATDEC};
  my $latdeg = $decoded->{payload_fields}->{LATDEG};
  my $latmin = $decoded->{payload_fields}->{LATMIN};
  my $longdec = $decoded->{payload_fields}->{LONGDEC};
  my $longdeg = $decoded->{payload_fields}->{LONGDEG};
  my $longmin = $decoded->{payload_fields}->{LONGMIN};
  my $minute = $decoded->{payload_fields}->{MINUTE};
  my $ns = $decoded->{payload_fields}->{NS};
  my $sat = $decoded->{payload_fields}->{SAT};
  my $second = $decoded->{payload_fields}->{SECOND};
  my $ud = $decoded->{payload_fields}->{UD};
  my $vacc = $decoded->{payload_fields}->{VACC};
  my $vvel = $decoded->{payload_fields}->{VVEL};
  
  my $latdegdec = $latdeg + ($latmin / 60) + ($latdec / 1000 / 60);
  my $longdegdec = $longdeg + ($longmin / 60) + ($longdec / 1000 / 60);
  
  if ($ns eq "S") { $latdegdec = $latdegdec * -1; }
  if ($ew eq "W") { $longdegdec = $longdegdec * -1; }
  if ($ud eq "U") { $vvel = $vvel * -1; }


  my $dt = DateTime->now(time_zone=>'America/Denver');
  print "$payload\n";
  
  $query_aprsposits->execute($dt, $name, $latdegdec, $longdegdec, $alt, $hvel, undef, "/#", "vVel: " . $vvel . " m/s<br/>Satellites: $sat, Gateways: $gat<br/>HACC: " . $hacc . "m, VACC: " . $vacc . "m", $payload) or die "Failed to execute: $DBI::errstr";
  
  system("php -f /home/APRS/markers.php > /var/www/html/markers.xml &");      
}

