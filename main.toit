// Copyright 2023 Ekorau LLC
import gpio
import mqtt
import net
import monitor show Mutex
import .vindriktning
import .credentials show ADAFRUIT-IO-USERNAME  ADAFRUIT-IO-KEY ADAFRUIT-IO-FEEDNAME CLIENT-ID

data := Deque
mutex := Mutex

RED-LED ::= 13
rled := gpio.Pin RED-LED --output

main:
  task:: data-collect
  task:: data-print
  task:: data-send
  
data-collect:  
  vin := Vindriktning 21
  while vin.next:
    mutex.do:
      dot-red
      if data.size >4: data.remove-first
      data.add vin.air-quality

data-print:
  sum := 0
  msg := ""
  val := 0

  while true:
    an-exception := catch:
      (Duration --m=1).periodic:
        mutex.do:
          sum = data.reduce --initial=0 : | a b | 
                  a + b
          val = data.size > 0? (sum / data.size): 0 // For .periodic at t=0.
        msg = "$val"
        print "$Time.now ppm: $val"
    if an-exception:
      print "At $Time.now got $an-exception"

data-send:
  HOST ::= "io.adafruit.com"
  TOPIC ::= "$ADAFRUIT-IO-USERNAME/feeds/$ADAFRUIT-IO-FEEDNAME"
  sum := 0
  val := -1
  msg := ""

  network := net.open
  transport := mqtt.TcpTransport network --host=HOST
  client := mqtt.Client --transport=transport
  options := mqtt.SessionOptions
    --client-id = CLIENT-ID
    --username = ADAFRUIT-IO-USERNAME
    --password = ADAFRUIT-IO-KEY
  client.start --options=options

  mq-exception := catch:
    (Duration --m=1).periodic:
      mutex.do:
        sum = data.reduce --initial=0: | a b | 
                a + b
        val = data.size > 0? (sum / data.size): 0 // For .periodic at t=0.
      msg = "$val"
      print "ppm: $val"
      client.publish TOPIC msg.to-byte-array
      dash-red
  if mq-exception:
    fail 250 750

red-on -> none:
  rled.set 0

red-off -> none:
  rled.set 1

fail on off:
  while true:
    red-on
    sleep --ms=on
    red-off
    sleep --ms=off

dash-red --on=950 --off=50 -> none:
  red-on
  sleep --ms=on
  red-off
  sleep --ms=off  

dot-red --on=50 --off=950 -> none:
  red-on
  sleep --ms=on
  red-off
  sleep --ms=off  