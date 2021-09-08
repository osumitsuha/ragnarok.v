module osustream

import encoding.binary
import math

pub struct Reader {
pub:
	buffer_ []byte [required]
pub mut:
	pos int
}

pub fn new_reader(data []byte) &Reader {
	return &Reader{
		buffer_: data
	}
}

pub fn (r &Reader) buffer() []byte {
	return r.buffer_[r.pos..]
}

pub fn (mut r Reader) read_byte() u8 {
	ret := r.buffer()[0]
	r.pos += 1
	return ret
}

pub fn (mut r Reader) read_i16() i16 {
	ret := i16(binary.little_endian_u16(r.buffer()[..2]))
	r.pos += 2
	return ret
}

pub fn (mut r Reader) read_u16() u16 {
	ret := binary.little_endian_u16(r.buffer()[..2])
	r.pos += 2
	return ret
}

pub fn (mut r Reader) read_i32() int {
	ret := int(binary.little_endian_u32(r.buffer()[..4]))
	r.pos += 4
	return ret
}

pub fn (mut r Reader) read_u32() u32 {
	ret := binary.little_endian_u32(r.buffer()[..4])
	r.pos += 4
	return ret
}

pub fn (mut r Reader) read_i64() i64 {
	ret := i64(binary.little_endian_u64(r.buffer()[..8]))
	r.pos += 8
	return ret
}

pub fn (mut r Reader) read_u64() u64 {
	ret := binary.little_endian_u64(r.buffer()[..8])
	r.pos += 8
	return ret
}

pub fn (mut r Reader) read_string() string {
	r.pos += 1

	mut shift := 0
	mut result := 0

	for {
		b := r.buffer()[0]
		r.pos += 1

		result |= (b & 0x7F) << shift

		if (b & 0x80) == 0 {
			break
		}

		shift += 7
	}

	ret := r.buffer()[..result].bytestr()
	r.pos += result

	return ret
}

pub fn (mut r Reader) read_f32() f32 {
	ret := math.f32_from_bits(binary.little_endian_u32(r.buffer()[..4]))
	r.pos += 4
	return ret
}

pub fn (mut r Reader) read_f64() f64 {
	ret := math.f64_from_bits(binary.little_endian_u64(r.buffer()[..8]))
	r.pos += 8
	return ret
}

pub fn (mut r Reader) read_i32_l() []int {
	len := r.read_u16()

	mut i32_l := []int{}

	for _ in 1 .. len {
		i32_l << r.read_i32()
	}

	return i32_l
}
