module events

import ueda
import log
import managers
import packet

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
	if req.headers["osu-token"].len == 0 {
	    return handle_login(mut req)
	}

	return req.resp_raw("".bytes()), 200
}

pub fn handle_login(mut req ueda.Request) ([]byte, int) {
	req.headers["cho-token"] = "no"

	mut data := req.body.bytestr().split("\n")

	// If there is no data, it's an invalid request.
	if data.len <= 1 {
		return req.resp_raw("".bytes()), 403
	}

	mut ret := packet.protocol()

	username := data[0]
	usafe := username.replace(" ", "_").to_lower()
	pwd := data[1]

	mut p := managers.get_user(usafe) or {
		log.error(err)
		ret << packet.userid(-1)
		ret << packet.announce(err.msg)
		return req.resp_raw(ret), 200
	}

	p.ip = req.headers["X-Real-IP"]

	if p.passhash.bytestr() !in crypt_cache {
		if C.bcrypt_checkpw(&char(pwd.str), &char(p.passhash.bytestr().str)) != 0 {
			ret << packet.userid(-1)
			ret << packet.announce("Login failed")
			return req.resp_raw(ret), 200
		}
		crypt_cache[p.passhash.bytestr()] = pwd
		log.info("Caching password")
	} else {
		if crypt_cache[p.passhash.bytestr()] != pwd {
			ret << packet.userid(-1) 
			ret << packet.announce("Login failed")
			return req.resp_raw(ret), 200
		}

		log.info("Using cached password")
	}

	// login := data[2].split("|")

	ret << packet.userid(p.id)
	ret << packet.announce("Login successful")
	return req.resp_raw(ret), 200
}
