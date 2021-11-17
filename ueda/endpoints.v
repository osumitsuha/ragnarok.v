module ueda

pub enum Method {
	get
	post
}

pub struct Endpoint {
pub mut:
	methods	[]Method
	path	string
	func	fn (mut Request) ([]byte, int)
}