module io

import constants { Packets }
import math

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

// io.make_packet<PacketStruct>(.packet, PacketStructData)
pub fn make_packet<T>(packet Packets, data &T) []byte {
	mut s := Stream{}

	s.write_u16(u16(packet))
	s.write_u8(0)
	s.write_i32(0)

	$for field in T.fields {
		$if field.typ is u8 {
			s.write_u8(data.$(field.name))
		} $else $if field.typ is i8 {
			s.write_i8(data.$(field.name))
		} $else $if field.typ is u16 {
			s.write_u16(data.$(field.name))
		} $else $if field.typ is i16 {
			s.write_i16(data.$(field.name))
		} $else $if field.typ is u32 {
			s.write_u32(data.$(field.name))
		} $else $if field.typ is int {
			s.write_i32(data.$(field.name))
		} $else $if field.typ is u64 {
			s.write_u64(data.$(field.name))
		} $else $if field.typ is i64 {
			s.write_i64(data.$(field.name))
		} $else $if field.typ is f32 {
			s.write_u32(math.f32_bits(data.$(field.name)))
		} $else $if field.typ is f64 {
			s.write_u64(math.f64_bits(data.$(field.name)))
		} $else $if field.typ is string {
			s.write_str(data.$(field.name))
		} $else $if field.typ is []int {
			s.write_i32_l(data.$(field.name))
		} $else {
			panic('${field.typ} not implemented')
		}
	}

	s.write_packet_length(s.content.len - 7)

	return s.content
}
