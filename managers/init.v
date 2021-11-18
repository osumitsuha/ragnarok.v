module managers

import mysql

__global (
	db       	mysql.Connection
	players  	map[string]Player
	matches  	map[string]Match
	channels 	map[string]Channel
	crypt_cache map[string]string
)

pub fn get_user(usafe string) ?Player {
	if usafe !in players {
		r := db.query("SELECT username, id, privileges, password FROM users WHERE usafe = '$usafe'") or {
			return err
		}

		mapped := r.maps()

		if mapped.len <= 0 {
			return error("User not found")
		}

		ret := Player{
			id: mapped[0]["id"].int()
			username: mapped[0]["username"]
			passhash: mapped[0]["password"].bytes()
			privileges: mapped[0]["privileges"].int()
		}
		unsafe { r.free() }

		return ret
	}

	return players[usafe]
}