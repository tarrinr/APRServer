<?php

$username="APRS_user";
$password="password";
$database="APRS";

$dom = new DOMDocument("1.0");
$node = $dom->createElement("markers");
$parnode = $dom->appendChild($node);

$connection=mysql_connect ('localhost', $username, $password);
if (!$connection) {  die('Not connected : ' . mysql_error());}

$db_selected = mysql_select_db($database, $connection);
if (!$db_selected) {
  die ('Can\'t use db : ' . mysql_error());
}

$query = "SELECT * FROM APRSPosits WHERE ReportTime >= NOW() - INTERVAL 12 HOUR";
$result = mysql_query($query);
if (!$result) {
  die('Invalid query: ' . mysql_error());
}

header("Content-type: text/xml");

while ($row = @mysql_fetch_assoc($result)){

  $node = $dom->createElement("marker");
  $newnode = $parnode->appendChild($node);
  $newnode->setAttribute("ID",$row['ID']);
  $newnode->setAttribute("ReportTime",$row['ReportTime']);
  $newnode->setAttribute("CallsignSSID", $row['CallsignSSID']);
  $newnode->setAttribute("Latitude", $row['Latitude']);
  $newnode->setAttribute("Longitude", $row['Longitude']);
  $newnode->setAttribute("Altitude", $row['Altitude']);
  $newnode->setAttribute("Speed", $row['Speed']);
  $newnode->setAttribute("Course", $row['Course']);
  $newnode->setAttribute("Icon", $row['Icon']);
  $newnode->setAttribute("Comment", $row['Comment']);
}

echo $dom->saveXML();

?>
