// Copyright 2026 Ekorau LLC

// The Vindriktning's PM1006-like sensor on ztoit (Zephyr): the sensor's TX,
// tapped through a divider, arrives on uart2's RX (the board overlay picks the
// pin). Prints each PM2.5 reading and posts it as obs/vin/pm25, which the
// firmware's agent pushes at its next check-in (ztoit#52, step 2).

import net
import ztoit
import .vin_frames

// How often the network is opened, so the agent checks in and pushes the last reading.
REPORT-MS ::= 60_000

main:
  uart := ztoit.Uart "uart2" --baud=9600
  task:: report
  parser := FrameParser
  print "vin: listening on uart2"
  while true:
    parser.add uart.read
    while pm25 := parser.next:
      print "vin: pm25 $pm25"
      ztoit.observe "vin/pm25" pm25

// Opens the network and closes it again: the agent checks in while the link is
// up, and the close waits for that check-in. A task of its own, so the UART is
// read while the network opens. A failed open is retried next time: this app
// is what opens the link for the agent's check-ins (ztoit#35).
report:
  while true:
    sleep --ms=REPORT-MS
    start := Time.monotonic-us
    network/net.Client? := null
    open-error := catch: network = net.open
    if not network:
      print "vin: open failed after $((Time.monotonic-us - start) / 1_000) ms: $open-error"
      continue
    print "vin: open $((Time.monotonic-us - start) / 1_000) ms"
    network.close
