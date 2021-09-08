module managers

import managers { Channel, Match }

pub struct Player {
pub:
	id			int 	[required]
	
	username	string 	[required]

pub mut:
	passhash	[]byte	[required]
	
	ip			string
	
	privileges	int		[required]

	country		string
	country_c	int

	status		string
	status_t	int
	map_md5		string
	cur_mods	u32
	mode		u8
	map_id		int

	channels 	[]Channel
	friends		[]Player
	game_match	Match

	r_score		i64
	acc			f32
	p_count		int
	t_score		i64
	level		i8
	rank		int
	pp			i16

	relax		int

	queue		[]byte

	login_time	i64
	last_update	i64

	bot			bool
}

fn (p &Player) get_current_mode() ?string {
	if p.mode > 3 {
		return error("Unexpected error; this should never happen. (MODE: $p.mode)")
	}
	
	m := match p.mode {
		0 { "std" }
		1 { "taiko" }
		2 { "catch" }
		3 { "mania" }
		else { "no" }
	}

	return m
}

pub fn (mut p Player) initialize_stats_from_sql() ? {
	table := match p.relax {
		0 { "stats" }
		else { "stats_relax" }
	}

	m := p.get_current_mode() ?

	r := db.query("SELECT ranked_score_$m AS r_score, pp_$m AS pp, " +
				  "total_score_$m AS t_score, accuracy_$m AS acc, " +
				  "playcount_$m AS p_count, level_$m AS level " +
				  "FROM $table WHERE id = $p.id LIMIT 1") or { return err }
	result := r.maps()[0]
	unsafe { r.free() }

	p.r_score = result["r_score"].i64()
	p.t_score = result["t_score"].i64()
	p.acc = result["acc"].f32()
	p.p_count = result["p_score"].int()
	p.level = result["level"].i8()
	p.pp = result["pp"].i16()
}