// Copyright 2023 Ekorau LLC
import gpio
import mqtt
import net
import monitor show Mutex
import .vindriktning
import .credentials show ADAFRUIT_IO_USERNAME  ADAFRUIT_IO_KEY ADAFRUIT_IO_FEEDNAME CLIENT_ID

data := Deque
mutex := Mutex

RED_LED ::= 13
rled := gpio.Pin RED_LED --output

main:
  task:: data_collect
  task:: data_send
  
data_collect:  
  vin := Vindriktning 21
  while vin.next:
    mutex.do:
      dot_red
      if data.size >4: data.remove_first
      data.add vin.air_quality

data_send:
  HOST ::= "io.adafruit.com"
  TOPIC ::= "$ADAFRUIT_IO_USERNAME/feeds/$ADAFRUIT_IO_FEEDNAME"
  sum := 0
  val := -1
  msg := ""

  network := net.open
  transport := mqtt.TcpTransport network --host=HOST
  client := mqtt.Client --transport=transport
  options := mqtt.SessionOptions
    --client_id = CLIENT_ID
    --username = ADAFRUIT_IO_USERNAME
    --password = ADAFRUIT_IO_KEY
  client.start --options=options

  (Duration --m=1).periodic:
    mutex.do:
      sum = data.reduce --initial=0: | a b | 
              a + b
      val = data.size > 0? (sum / data.size): 0 // For .periodic at t=0.
    msg = "$val"
    print "ppm: $val"
    client.publish TOPIC msg.to_byte_array
    dash_red

red_on -> none:
  rled.set 0

red_off -> none:
  rled.set 1

dash_red --on=950 --off=50 -> none:
  red_on
  sleep --ms=on
  red_off
  sleep --ms=off  

dot_red --on=50 --off=950 -> none:
  red_on
  sleep --ms=on
  red_off
  sleep --ms=off  