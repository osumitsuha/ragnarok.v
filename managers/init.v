module managers

import mysql

__global (
	db       mysql.Connection
	players  map[string]Player
	matches  map[string]Match
	channels map[string]Channel
)

pub fn get_user(usafe string) ?Player {
	if usafe !in players {
		r := db.query("SELECT username, id, privileges, passhash FROM users WHERE safe_username = '$usafe'") or {
			return err
		}

		res := r.maps()[0]

		ret := Player{
			id: res["id"].int()
			username: res["username"]
			passhash: res["passhash"].bytes()
			privileges: res["privileges"].int()
		}
		unsafe { r.free() }

		return ret
	}

	return players[usafe]
}