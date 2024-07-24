str := ""
start := 0
stop := 0
bgc := 0
egc := 0

main:

  frame := #[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20]
  duration := Duration.of:
    bgc = gc-count
    100.repeat:
      str = "$(%02x frame[0]) $(%02x frame[1]) $(%02x frame[2]) $(%02x frame[3]) $(%02x frame[4]) $(%02x frame[5]) $(%02x frame[6]) $(%02x frame[7]) $(%02x frame[8]) $(%02x frame[9]) $(%02x frame[10]) $(%02x frame[11]) $(%02x frame[12]) $(%02x frame[13]) $(%02x frame[14]) $(%02x frame[15]) $(%02x frame[16]) $(%02x frame[17]) $(%02x frame[18]) $(%02x frame[19])"
    egc = gc-count
  print "time_interpolation: $duration.in-ms ms, gcs: $(egc - bgc)"

  duration = Duration.of:
    bgc = gc-count
    100.repeat:
      str = (List 20: "$(%02x frame[it])").join " " 
    egc = gc-count
  print "time_interpolation: $duration.in-ms ms, gcs: $(egc - bgc)"
