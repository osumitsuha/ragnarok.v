module main

import ueda
import events
import managers
import log
import mysql

// It's been fun developing osu! related stuff.
// But it's time to move on, and work on other stuff aswell.
// im bored.

fn main() {
	mut server := ueda.new_ueda(log_warn: false, addr: "127.0.0.1:5000", name: "ragnarok.v")
	
	db = mysql.Connection{
		username: sql_username
		password: sql_pass
		dbname: sql_table
	}

	db.connect() or {
		log.error(error("Couldn't connect to the database - err: $err"))
		return
	}

	server.add_endpoint(methods: [.post], path: "/", func: events.handle_bancho)

	server.run()
}
