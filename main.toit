// Copyright 2023 Ekorau LLC

import .vindriktning

main:

  vin := Vindriktning 21
  
  ar :=  vin.next
  while ar:
    // print vin.last_frame
    print "pm2.5: $vin.air_quality"
    ar =  vin.next
