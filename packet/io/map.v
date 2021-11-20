module io

import constants { Packets }
import objects { Player }

pub struct Packet {
pub:
	packet 		Packets
	handle 		fn (mut Player, mut Reader)
	restricted	bool
}

pub fn register_packet(p Packet) {
	glob_packets[i16(p.packet)] = &Packet{...p}
}