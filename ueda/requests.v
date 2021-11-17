module ueda

pub struct Request {
mut:
	raw		 	[]string

pub mut:
	body		[]byte

	method	 	Method
	path	 	string
	http_ver 	string

	get_args 	map[string]string
	form_data	map[string]string
	headers	 	map[string]string
}

fn match_method_enum(method string) ?Method {
	match method {
		"GET" { return .get }
		"POST" { return .post }
		else { return error("not a valid method") }
	}
}

fn parse_request(buf string) ?Request {
	mut req := buf.split_nth("\r\n", 0)
	req_data := req[0].split_nth(" ", 0)

	method := match_method_enum(req_data[0]) or {
		return err
	}
	
	mut request := Request{
		raw: req

		method: method
		path: req_data[1]
		http_ver: req_data[2]

		body: req.last().bytes()
	}

	return request
}

fn (mut r Request) parse_headers() {
	for h in r.raw[1..] {
		if h.len == 0 {
			break
		}

		header := h.split_nth(": ", 0)


		r.headers[header[0]] = header[1]
	}
}

fn (mut r Request) parse_get_args() {
	if r.path.contains("?") {
		path_and_get_args := r.path.split_nth("?", 0)
		r.path = path_and_get_args[0]

		for argument in path_and_get_args[1].split("&") {
			arg_info := argument.split_nth("=", 0)
			r.get_args[arg_info[0]] = arg_info[1]
		}
	}
}

fn (mut r Request) parse_form_data() {}
fn (mut r Request) parse_www_form() {}

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

pub fn (mut r Request) resp_json(s string) []byte {
	r.headers["Content-Type"] = "application/json"
	return s.bytes()
}

pub fn (mut r Request) resp_raw(s []byte) []byte {
	r.headers["Content-Type"] = "text/plain"
	return s
}

pub fn (mut r Request) resp_html(s string) []byte {
	r.headers["Content-Type"] = "text/html; charset=UTF-8"
	return s.bytes()
}

fn (mut r Request) send(code int, cnt []byte) []byte {
	mut buf := []byte{}

	buf << "$r.http_ver $code ${status_msg(code)}\r\n".bytes()

	r.headers["Content-Length"] = "$cnt.len"

	for key, value in r.headers {
		buf << "$key: $value\r\n".bytes()
	}

	buf << "\r\n".bytes()
	buf << cnt

	return buf
}