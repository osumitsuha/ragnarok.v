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

		res := r.maps()[0]

		ret := Player{
			id: res["id"].int()
			username: res["username"]
			passhash: res["password"].bytes()
			privileges: res["privileges"].int()
		}
		unsafe { r.free() }

		return ret
	}

	return players[usafe]
}