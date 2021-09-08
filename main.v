module main

import vttp
import events
import managers
import log
import mysql

// It's been fun developing osu! related stuff.
// But it's time to move on, and work on other stuff aswell.

fn main() {
	mut server := vttp.new_vttp(log_warn: false, path: "/tmp/ragnarok.sock", name: "ragnarok.v")
	
	db = mysql.Connection{
		username: 'username'
		password: 'password'
		dbname: 'ragnarok'
	}

	db.connect() or {
		log.error(error("Couldn't connect to the database - err: $err"))
		return
	}

	server.add_endpoint(method: .post, path: "/", func: events.handle_bancho)

	server.run()
}