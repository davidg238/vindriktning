// Copyright 2026 Ekorau LLC

// The Vindriktning's PM1006-like sensor on ztoit (Zephyr): the sensor's TX,
// tapped through a divider, arrives on uart2's RX (the board overlay picks the
// pin). Prints each PM2.5 reading (ztoit#52, step 1).

import zephyr
import .vin_frames

main:
  uart := zephyr.Uart "uart2" --baud=9600
  parser := FrameParser
  print "vin: listening on uart2"
  while true:
    parser.add uart.read
    while pm25 := parser.next:
      print "vin: pm25 $pm25"
