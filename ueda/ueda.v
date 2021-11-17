module ueda

import net
import log

const (
	form_methods = ['GET', 'POST']
)

pub struct Ueda {
pub:
	name		string
	addr 		string
	log_warn	bool

mut:
	endpoints	map[string]Endpoint
}

pub fn new_ueda(u Ueda) &Ueda {
	return &Ueda{...u}
}

pub fn (mut u Ueda) add_endpoint(e Endpoint) {
	u.endpoints[e.path] = e
}

fn (u &Ueda) find_endpoint(r &Request) ?Endpoint {
	path := r.path.all_before("?")

	if path in u.endpoints {
		if r.method !in u.endpoints[path].methods {
			return error("Method not allowed.")
		}

 		return u.endpoints[path]
	}

	return error("Not found.")
}

pub fn four_o_four() []byte {
	return "HTTP/1.0 404 Not Found\r\nContent-Type: text/plain\r\n\r\n404 Not found".bytes()
}

pub fn (u &Ueda) run() {
	mut l := net.listen_tcp(.ip, u.addr) or {
		log.error(err)
		return
	}

	println(log.magneta + "~~~~~~ Running $u.name ~~~~~~" + log.endc)

	for {
		mut conn := l.accept() or {
			l.close() or {}
			log.error(error("Connection acception failure: $err"))
			return
		}

		mut buf := []byte{len: 1024}
		_ := conn.read(mut buf) or {
			log.error(error("Unable to read the requests body."))
			continue
		}

		data := buf.bytestr()

		mut req := parse_request(data) or {
			log.warn("Parsing request error: $err")
			conn.close() or {}
			continue
		}

		endpoint := u.find_endpoint(req) or {
			conn.write(four_o_four()) or {}
			log.warn("`$req.path not found.`")
			conn.close() or {}
			continue
		}

		req.parse_headers()

		match req.method {
			.get {
				req.parse_get_args()
			}
			.post {
				c_type := req.headers["Content-Type"]

				if c_type == "multipart/form-data" {
					req.parse_form_data()
				} else if c_type == "application/x-www-form-urlencoded" {
					req.parse_www_form()
				}
			}
		}

		cnt, code := endpoint.func(mut req)

		conn.write(req.send(code, cnt)) or {}
		conn.close() or {}
	}

	l.close() or {}
}

