module packet

import objects
import packet.io

pub struct Empty {}

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

pub struct UserStats {
	id			int
	status 		u8
	status_text	string
	map_md5		string
	cur_mods	u32
	play_mode	i8
	map_id		int
	r_score		i64
	accuracy 	f32
	playcount 	int
	t_score 	i64
	rank 		int
	pp 			i16
}

pub fn user_stats(p objects.Player) []byte {
	return io.make_packet<UserStats>(.cho_user_stats, UserStats{
		id: p.id
		status: p.status_t
		status_text: p.status
		map_md5: p.map_md5
		cur_mods: p.cur_mods
		play_mode: p.mode
		map_id: p.map_id
		r_score: p.r_score
		accuracy: p.acc
		playcount: p.p_count
		t_score: p.t_score
		rank: p.rank
		pp: p.pp
	})
}

pub fn chan_info_end() []byte {
	return io.make_packet<Empty>(.cho_channel_info_end, Empty{})
}

struct Friends {
	ids			[]int
}

pub fn friends_list(friends []int) []byte {
	return io.make_packet<Friends>(.cho_friends_list, Friends{ids: friends})
}

struct ServerRestart {
	ms 			int
}

pub fn server_restart(ms int) []byte {
	return io.make_packet<ServerRestart>(.cho_restart, ServerRestart{ms: ms})
}