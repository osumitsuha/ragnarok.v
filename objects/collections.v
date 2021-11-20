module objects

pub fn enqueue_players(b []byte) {
	for _, mut p in players {
		p.enqueue(b)
	}
}

pub fn get_user(usafe string) ?Player {
	if usafe !in players {
		r := db.query("SELECT username, usafe, id, privileges, password FROM users WHERE usafe = '$usafe'") or {
			return err
		}

		mapped := r.maps()

		if mapped.len <= 0 {
			return error("User not found")
		}

		ret := Player{
			id: mapped[0]["id"].int()
			username: mapped[0]["username"]
			usafe: mapped[0]["usafe"]
			passhash: mapped[0]["password"].bytes()
			privileges: mapped[0]["privileges"].int()
		}
		unsafe { r.free() }

		return ret
	}

	return players[usafe]
}

pub fn get_user_by_token(token string) ?Player {
	for _, user in players {
		if user.token == token {
			return user
		}
	}

	return error("Player with the token `$token`, not found.")
}
