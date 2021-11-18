module packet

import packet.io

pub struct UserID {
	resp		int
}

pub fn userid(id int) []byte {
	return io.make_packet<UserID>(.cho_user_id, UserID{resp: id})
}

pub struct Protocol {
	version 	int
}

pub fn protocol() []byte {
	return io.make_packet<Protocol>(.cho_protocol_version, Protocol{version: 19})
}

pub struct Announce {
	msg 		string
}

pub fn announce(msg string) []byte {
	return io.make_packet<Announce>(.cho_notification, Announce{msg: msg})
}