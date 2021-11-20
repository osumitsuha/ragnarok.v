module main

import events
import packet.io

pub fn register_all_packets() {
	io.register_packet(packet: .osu_change_action, handle: events.change_action, restricted: true)
	io.register_packet(packet: .osu_logout, handle: events.logout, restricted: true)
	io.register_packet(packet: .osu_request_status_update, handle: events.request_status_update, restricted: true)
	io.register_packet(packet: .osu_ping, handle: events.pong, restricted: true)
}