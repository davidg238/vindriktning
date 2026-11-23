// Copyright 2026 Ekorau LLC

// PM1006-like frames, as the Vindriktning's sensor sends them (ztoit#52).

FRAME-SIZE ::= 20
HEADER ::= #[0x16, 0x11, 0x0b]

/**
Frames in the buffer, from its start: returns the PM2.5 value of the first valid
  frame and drops what it consumed, or null if no whole frame is there yet.
Bytes before a header, or a frame with a bad checksum, are skipped, so a
  read that splits or joins frames resynchronises.
*/
class FrameParser:
  buffer_ := #[]

  add bytes/ByteArray -> none:
    buffer_ += bytes

  next -> int?:
    while true:
      start := find-header_
      if start < 0:
        // Keep a tail that may be the start of a header.
        if buffer_.size > 2: buffer_ = buffer_[buffer_.size - 2..]
        return null
      buffer_ = buffer_[start..]
      if buffer_.size < FRAME-SIZE: return null
      frame := buffer_[..FRAME-SIZE]
      if (checksum frame) == 0:
        buffer_ = buffer_[FRAME-SIZE..]
        return frame[5] << 8 | frame[6]
      buffer_ = buffer_[1..]  // Not a frame: look past this header byte.

  find-header_ -> int:
    for i := 0; i + 2 < buffer_.size; i++:
      if buffer_[i] == HEADER[0] and buffer_[i + 1] == HEADER[1] and buffer_[i + 2] == HEADER[2]:
        return i
    return -1

checksum bytes/ByteArray -> int:
  sum := 0
  bytes.do: sum += it
  return sum & 0xff
