module log

pub const (
	red = "\033[1;31m"
	green = "\033[1;32m"
	orange = "\033[1;33m"
	blue = "\033[1;34m"
	magneta = "\033[1;35m"
	endc = "\033[0m"
)

pub fn info(msg string) {
	println("[${blue}info$endc]\t$msg")
}

pub fn warn(msg string) {
	println("[${orange}warn$endc]\t$msg")
}

pub fn debug(msg string) {
	println("[${green}debug$endc]\t$msg")
}

pub fn error(msg IError) {
	println("[${red}error$endc]\t$msg")
}

pub fn fail(msg string) {
	println("[${red}fail$endc]\t$msg")
}

pub fn ok(msg string) {
	println("[${green}ok$endc]\t$msg")
}