<?php 

  $postdata = file_get_contents('php://input');
  file_put_contents('/home/lora/latest.json', $postdata); 
  exec('perl /home/lora/LORA2MySQL.pl >> /home/lora/lora.log 2>&1 &');

?>
