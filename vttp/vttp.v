module vttp

import net.unix
import time
import os
import log

const (
	form_methods = ['GET', 'POST']
)

pub enum Methods {
	get
	post
}

pub struct Endpoint {
pub mut:
	method	Methods
	path	string
	func	fn (mut Request) []byte
}

pub struct VTTP {
	name 		string
	path 		string
	log_warn	bool

pub mut:
	endpoints	map[string]Endpoint
}

pub fn new_vttp(v VTTP) &VTTP {
	return &VTTP{...v}
}

pub fn (mut v VTTP) add_endpoint(r Endpoint) {
	v.endpoints[r.path] = r
}

pub fn (v &VTTP) find_endpoint(r Request) ?Endpoint {
	if r.path in v.endpoints {
		if r.method != form_methods[v.endpoints[r.path].method] {
			return error("Method not allowed.")
		}

 		return v.endpoints[r.path]
	}

	return error("Not found.")
}

pub fn (v VTTP) run() {
	if os.exists(v.path) {
		os.rm(v.path) or {}
	}

	mut listener := unix.listen_stream(v.path) or {
		panic(err)
	}

	os.chmod(v.path, 0o777) or {
		panic(err)
	}

	println(log.magneta + "~~~~~~ Running $v.name ~~~~~~" + log.endc)

	for {
		mut conn := listener.accept() or {
			listener.close() or {}
			panic("Connection acception failure: $err")
		}

		mut timer := time.new_stopwatch()
		timer.start()

		// Read the body of the request.
		mut buf := []byte{len: 4096}
		read := conn.read(mut buf) or { panic(err) }

		if read == 0 {
			conn.close() or {}
			continue
		}

		data := buf.bytestr()

		// GET / HTTP/1.0
		// method path http_ver
		mut http := data.split_nth("\r\n", 0)

		req_data := http[0].split_nth(" ", 0)

		mut req := Request{
			method: req_data[0]
			path: req_data[1]
			http_ver: req_data[2]
		}

		// Find the endpoint, and if not write a 404 response whilst closing connection.
		endpoint := v.find_endpoint(req) or {
			conn.write("HTTP/1.0 404 Not Found\r\nContent-Type: text/plain\r\n\r\n$err".bytes()) or {}
			log.warn("$req.path ($req.method) | ${timer.elapsed().microseconds()}μs")
			conn.close() or {}
			continue
		}

		// This if statements checks if the path includes `?`
		// if it does it'll initialize GET arguments.
		if req.path.contains("?") {
			path_and_get_args := req.path.split_nth("?", 0)
			req.path = path_and_get_args[0]

			for argument in path_and_get_args[1].split("&") {
				arg_info := argument.split_nth("=", 0)
				req.get_args[arg_info[0]] = arg_info[1]
			}
		}
		
		for h in http[1..http.len-2] {
			header := h.split_nth(": ", 0)
			req.headers[header[0]] = header[1]
		}

		req.body = http.last().bytes()
		resp := endpoint.func(mut req)

		// Write response and close connection.
		conn.write(resp) or {}
		conn.close() or {}

		log.info("$req.path ($req.method) | ${timer.elapsed().microseconds()}μs")

		// Stop the timer, since we're gonna start a new one at the start of the loop.
		timer.stop()
	}

	listener.close() or {}
} 

pub struct Request {
pub mut:
	method string = "GET"
	path string = "/"
	http_ver string = "HTTP/1.1"
	body []byte

	post_args map[string]string
	get_args map[string]string

	headers map[string]string
}

fn status_msg(code int) string {
	msg := match code {
		100 { 'Continue' }
		101 { 'Switching Protocols' }
		200 { 'OK' }
		201 { 'Created' }
		202 { 'Accepted' }
		203 { 'Non-Authoritive Information' }
		204 { 'No Content' }
		205 { 'Reset Content' }
		206 { 'Partial Content' }
		300 { 'Multiple Choices' }
		301 { 'Moved Permanently' }
		400 { 'Bad Request' }
		401 { 'Unauthorized' }
		403 { 'Forbidden' }
		404 { 'Not Found' }
		405 { 'Method Not Allowed' }
		408 { 'Request Timeout' }
		500 { 'Internal Server Error' }
		501 { 'Not Implemented' }
		502 { 'Bad Gateway' }
		else { '-' }
	}
	return msg
}

pub fn (mut r Request) send(code int, content []byte) []byte {
	mut resp := []byte{}
	resp << "$r.http_ver $code ${status_msg(code)}\r\n".bytes()

	r.headers["Content-Type"] = "text/html; charset=UTF-8"
	r.headers["Content-Length"] = "$content.len"

	for key, value in r.headers {
		resp << "$key: $value\r\n".bytes()
	}

	resp << "\r\n".bytes()

	resp << content

	return resp
}
