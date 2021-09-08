module events

import vttp
import log
import managers
import taillook.vbcrypt
import osustream { make_packet }

fn handle_bancho(mut req vttp.Request) []byte {
	// If the `User-Agent` key is in the headers or doesn't 
	// has `osu!` as it's value, it's an invalid request.
	if req.headers["User-Agent"] != "osu!" || "User-Agent" !in req.headers {
		return req.send(200, "nice try.".bytes())
	}

	// If we can't find any header that has `osu-token` key,
	// it's a login.
	if req.headers["osu-token"].len == 0 {
	    return req.send(200, handle_login(mut req))
	}

	return req.send(200, "".bytes())
}

pub fn handle_login(mut req vttp.Request) []byte {
	req.headers["cho-token"] = "no"

	mut data := req.body.bytestr().split("\n")

	if data.len <= 1 {
		return "".bytes()
	}

	mut ret := make_packet(75, 19)

	username := data[0]
	usafe := username.replace(" ", "_").to_lower()

	if usafe !in players {
		login := data[2].split("|")
		ip := req.headers["X-Real-IP"]

		mut p := managers.get_user(usafe) or {
			log.error(err)
			ret << make_packet(5, -1)
			return ret
		}

		p.ip = ip

		p.initialize_stats_from_sql() or {
			log.error(err)
			ret << make_packet(5, -1)
			return ret
		}

		vbcrypt.compare_hash_and_password(data[1].bytes(), p.passhash) or {
			ret << make_packet(5, -1)
			return ret
		}

		players[usafe] = p

		ret << make_packet(5, -1)
		return ret
	}

	ret << make_packet(5, -1)
	return ret
}
