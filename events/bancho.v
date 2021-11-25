module events

import ueda
import time
import math
import log
import objects
import constants { Packets, Privileges }
import packet
import packet.io

#flag -I @VMODROOT/lib
#flag @VMODROOT/lib/libbcrypt/bcrypt.c
#flag @VMODROOT/lib/libbcrypt/crypt_blowfish/crypt_blowfish.c
#flag @VMODROOT/lib/libbcrypt/crypt_blowfish/crypt_gensalt.c
#flag @VMODROOT/lib/libbcrypt/crypt_blowfish/wrapper.c

#include "libbcrypt/bcrypt.h"

fn C.bcrypt_checkpw(&char, &char) int

fn handle_bancho(mut req ueda.Request) ([]byte, int) {
	// If the `User-Agent` key is in the headers or doesn't 
	// has `osu!` as it's value, it's an invalid request.
	if req.headers["User-Agent"] != "osu!" || "User-Agent" !in req.headers {
		return "nice try.".bytes(), 401
	}

	// If we can't find any header that has `osu-token` key,
	// it's a login.
	if "osu-token" !in req.headers {
	    return handle_login(mut req)
	}

	mut p := objects.get_user_by_token(req.headers["osu-token"]) or {
		mut tmp := packet.announce("Server restarted")
		tmp << packet.server_restart(0)
		return req.resp_raw(tmp), 200
	}
	
	mut r := io.new_reader(req.body)

	for mut packet in r {
		packet.handle(mut p, mut r)
	}

	ret := p.flush()

	return req.resp_raw(ret), 200
}

pub fn handle_login(mut req ueda.Request) ([]byte, int) {
	req.headers["cho-token"] = "no"

	mut sw := time.new_stopwatch()
	sw.start()

	mut data := req.body.bytestr().split("\n")

	// If there is no data, it's an invalid request.
	if data.len <= 1 {
		return req.resp_raw("".bytes()), 403
	}

	mut ret := packet.protocol()

	username := data[0]
	usafe := username.replace(" ", "_").to_lower()
	pwd := data[1]

	mut p := objects.get_user(usafe) or {
		ret << packet.userid(-1)
		return req.resp_raw(ret), 200
	}

	p.ip = req.headers["X-Real-IP"]

	mut is_cached := false

	if p.passhash.bytestr() !in crypt_cache {
		if C.bcrypt_checkpw(&char(pwd.str), &char(p.passhash.bytestr().str)) != 0 {
			ret << packet.userid(-1)
			ret << packet.announce("Login failed, not cached")
			return req.resp_raw(ret), 200
		}
		crypt_cache[p.passhash.bytestr()] = pwd
	} else {
		if crypt_cache[p.passhash.bytestr()] != pwd {
			ret << packet.userid(-1) 
			ret << packet.announce("Login failed, cached")
			return req.resp_raw(ret), 200
		}
		is_cached = true
	}

	login := data[2].split("|")

	if login[3].split(":").len < 4 {
		ret << packet.userid(-2)
		return req.resp_raw(ret), 200
	}

	p.osu_ver = login[0]

	// This works, I just don't need it, since debug.
	// if !p.osu_ver.starts_with("b2021") {
	// 	ret << packet.userid(-2)
	// 	return req.resp_raw(ret), 200
	// }

	p.initialize_stats_from_sql() or {
		ret << packet.userid(-1)
		return req.resp_raw(ret), 200
	}

	p.get_friends()

	t := f64(sw.elapsed().nanoseconds()) / f64(1_000_000)
	t_rounded := int(t*math.pow(10, 5) + .5) / math.pow(10, 5)
	sw.stop()

	ret << packet.userid(p.id)
	ret << packet.user_stats(p)
	ret << packet.friends_list(p.friends)
	ret << packet.chan_info_end()
	
	ret << packet.announce("Login successful (${t_rounded}ms | CACHED: $is_cached)")
	log.debug("$p.username logged in. (authorization took ${t_rounded}ms)")
	
	p.login_time = time.now().unix_time()
	players[usafe] = p
	req.headers["cho-token"] = p.token
	return req.resp_raw(ret), 200
}

// id: 0x00
pub fn change_action(mut p objects.Player, mut r io.Reader) {
	p.status_t = r.read_byte()
	p.status = r.read_string()
	p.map_md5 = r.read_string()
	p.cur_mods = r.read_u32()
	p.mode = r.read_byte()
	p.map_id = r.read_i32()

	if !((p.privileges & int(Privileges.verified)) > 0) && 
	   !((p.privileges & int(Privileges.pending)) > 0) {
		objects.enqueue_players(packet.user_stats(p))
	}
}

// id 0x02
pub fn logout(mut p objects.Player, mut r io.Reader) {
	_ := r.read_i32()

	if time.now().unix_time() - p.login_time < 1 {
		return
	}

	log.info("$p.username logged out.")
}

pub fn request_status_update(mut p objects.Player, mut r io.Reader) {
	p.enqueue(packet.user_stats(p))
}

// id 0x04
pub fn pong(mut p objects.Player, mut r io.Reader) {}
