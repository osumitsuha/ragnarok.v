module objects

import log

pub fn join_bot() ? {
	bot := get_user("louise") or {
		log.error(error("Bot not found, please made one, or change the name."))
		return
	}

	players[bot.usafe] = bot
}