module osustream

struct Stream {
mut:
	content []byte
}

fn (mut s Stream) write_u8(i u8) {
	s.content << i
}

fn (mut s Stream) write_i8(i i8) {
	s.content << byte(i)
}

fn (mut s Stream) write_u16(i u16) {
	s.content << byte(i)
	s.content << byte(i >> u16(8))
}

fn (mut s Stream) write_i16(i i16) {
	s.write_u16(u16(i))
}

fn (mut s Stream) write_u32(i u32) {
	s.content << byte(i)
	s.content << byte(i >> u32(8))
	s.content << byte(i >> u32(16))
	s.content << byte(i >> u32(24))
}

fn (mut s Stream) write_i32(i int) {
	s.write_u32(u32(i))
}

fn (mut s Stream) write_packet_length(len int) {
	mut b := 0

	b += byte(len)
	b += byte(len >> u32(8))
	b += byte(len >> u32(16))
	b += byte(len >> u32(24))

	s.content[3] = byte(b)
}

fn (mut s Stream) write_u64(i u64) {
	s.content << byte(i)
	s.content << byte(i >> u64(8))
	s.content << byte(i >> u64(16))
	s.content << byte(i >> u64(24))
	s.content << byte(i >> u64(32))
	s.content << byte(i >> u64(40))
	s.content << byte(i >> u64(48))
	s.content << byte(i >> u64(56))
}

fn (mut s Stream) write_i64(i i64) {
	s.write_u64(u64(i))
}

fn (mut s Stream) write_str(str string) {
	mut length := str.len

	if length == 0 {
		s.write_u8(0)
		return
	}

	s.write_u8(11)

	for length >= 127 {
		s.write_u8(128)
		length -= 127
	}

	s.write_u8(byte(length))

	for letter in str {
		s.write_u8(byte(letter))
	}
}

fn (mut s Stream) write_i32_l(vals []int) {
	s.write_i16(i16(vals.len))

	for val in vals {
		s.write_i32(val)
	}
}

type PacketVal = byte | i16 | i64 | i8 | int | string | u16 | u32 | u64

// writer.make_packet(4, "string", 0, u32(1))
pub fn make_packet(packet int, values ...PacketVal) []byte {
	mut s := Stream{}

	s.write_u16(u16(packet))
	s.write_u8(0)
	s.write_i32(0)

	for v in values {
		match v.type_name() {
			'u8' {
				s.write_u8(v as byte)
			}
			'i8' {
				s.write_i8(v as i8)
			}
			'u16' {
				s.write_u16(v as u16)
			}
			'i16' {
				s.write_i16(v as i16)
			}
			'u32' {
				s.write_u32(v as u32)
			}
			'int' {
				s.write_i32(v as int)
			}
			'u64' {
				s.write_u64(v as u64)
			}
			'i64' {
				s.write_i64(v as i64)
			}
			'string' {
				s.write_str(v as string)
			}
			else {
				panic('get real')
			}
		}
	}

	s.write_packet_length(s.content.len - 7)

	return s.content
}
