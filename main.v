module main

import ueda
import events
import log
import mysql

fn main() {
	// Initialize the server.
	mut server := ueda.new_ueda(log_warn: false, addr: "127.0.0.1:5000", name: "ragnarok.v")
	
	// Initialize the database.
	db = mysql.Connection{
		username: sql_username
		password: sql_pass
		dbname: sql_table
	}

	db.connect() or {
		log.error(error("Couldn't connect to the database - err: $err"))
		return
	}

	// Initialize the events.
	register_all_packets()

	// Register all endpoints.
	server.add_endpoint(methods: [.post], path: "/", func: events.handle_bancho)

	// Run server.
	server.run()
}
