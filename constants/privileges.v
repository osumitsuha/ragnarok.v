module constants

pub enum Privileges {
	banned		= 1
	
	user 		= 2
	verified	= 4
	
	supporter	= 8

	bat 		= 16
	moderator	= 32
	admin		= 64
	dev 		= 128

	pending		= 256
}