// Host test of vin_frames.toit: `toit run test_vin_zephyr.toit`.
import expect show *
import .vin_frames

// A valid frame with PM2.5 value $pm.
frame pm/int -> ByteArray:
  f := ByteArray FRAME-SIZE
  f.replace 0 HEADER
  f[5] = pm >> 8
  f[6] = pm & 0xff
  f[FRAME-SIZE - 1] = (0x100 - (checksum f[..FRAME-SIZE - 1])) & 0xff
  return f

drain parser/FrameParser -> List:
  result := []
  while v := parser.next: result.add v
  return result

main:
  expect-equals 0 (checksum (frame 13))
  p := FrameParser
  p.add (frame 13)
  expect-equals [13] (drain p)
  // Split across reads.
  f := frame 800
  p.add f[..7]
  expect-equals [] (drain p)
  p.add f[7..]
  expect-equals [800] (drain p)
  // Joined, with garbage before and a corrupt frame between.
  bad := frame 99
  bad[10] = 1
  p.add #[1, 2, 0x16, 3] + (frame 40) + bad + (frame 41)
  expect-equals [40, 41] (drain p)
  // A header split at the very end is kept.
  g := frame 7
  p.add #[9, 9, 9] + g[..2]
  expect-equals [] (drain p)
  p.add g[2..]
  expect-equals [7] (drain p)
  print "ok"
