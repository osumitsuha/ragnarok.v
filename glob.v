module main

import mysql
import packet.io
import objects
import constants

__global (
	db       		mysql.Connection
	players  		map[string]objects.Player
	matches  		map[string]objects.Match
	channels 		map[string]objects.Channel

	glob_packets	map[int]io.Packet
	crypt_cache 	map[string]string
)