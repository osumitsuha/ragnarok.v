module bcrypt

import crypto.internal.subtle
import rand
import encoding.base64
import blowfish
import strconv

const err_mismatched_pwd = error("crypto.bcrypt: hashed_pwd is not the hash of the given password")

const (
	min_cost 				= 4
	max_cost				= 31
	default_cost			= 10

	major_version			= '2'.bytes()[0]
	minor_version			= 'a'.bytes()[0]
	max_salt_size			= 16
	max_crypted_hash_size 	= 23
	encoded_salt_size		= 22
	encoded_hash_size		= 31
	min_hash_size			= 59
)

const magic_cipher_data = [
	byte(0x4f), 0x72, 0x70, 0x68,
	0x65, 0x61, 0x6e, 0x42,
	0x65, 0x68, 0x6f, 0x6c,
	0x64, 0x65, 0x72, 0x53,
	0x63, 0x72, 0x79, 0x44,
	0x6f, 0x75, 0x62, 0x74,
]

struct Hashed {
mut:
	hash	[]byte
	salt	[]byte
	cost	int
	major 	byte
	minor 	byte
}

pub fn generate_from_password(pwd []byte, cost int) ?[]byte {
	p := new_from_password(pwd, cost) or {
		return err
	}

	return p.hash()
}

pub fn compare_hash_and_password(hash []byte, pwd []byte) bool {
	p := new_from_hash(hash) or {
		println(err)
		return false
	}

	other_hash := bcrypt(pwd, p.cost, p.salt) or {
		println("something wrong with bcrypt")
		return false
	}

	op := Hashed{other_hash, p.salt, p.cost, p.major, p.minor}
	if subtle.constant_time_compare(p.hash(), op.hash()) == 1 {
		return true
	}

	println("just mismatched")
	return false
}

fn cost(hash []byte) ?int {
	p := new_from_hash(hash) or {
		return err
	} 

	return p.cost
}

fn new_from_password(pwd []byte, cost int) ?&Hashed {
	mut cost_ := cost
	if cost_ < min_cost {
		cost_ = default_cost
	}

	mut p := Hashed{}
	p.major = major_version
	p.minor = minor_version

	if cost_ < min_cost || cost_ > max_cost {
		return error("crypto.bcrypt: cost $cost_ is outside allowed range ($min_cost,$max_cost)")
	}

	p.cost = cost_

	zsalt_source := 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQLSTUVWXYZ0123456789'
	p.salt = base64.encode(rand.string_from_set(salt_source, max_salt_size).bytes()).bytes()

	p.hash = bcrypt(pwd, p.cost, p.salt) or {
		return err
	}

	return &p
}

fn new_from_hash(hash []byte) ?&Hashed {
	mut hash_ := hash.clone()

	if hash_.len < min_hash_size {
		return error("crypto.bcrypt: hash too short to be a bcrypted password")
	}

	mut p := Hashed{}
	if hash_[0].ascii_str() != "$" {
		return error("crypto.bcrypt: invalid bcrypt version")
	}

	if hash_[1] > major_version {
		return error("crypto.bcrypt: hash version too new")
	}

	p.major = hash_[1]
	mut m := 3
	if hash_[2].ascii_str() != "$" {
		p.minor = hash_[2]
		m++
	} 

	hash_ = hash_[m..]

	cost := strconv.atoi(hash_[0..2].bytestr()) or {
		return err
	}

	if cost < min_cost || cost > max_cost {
		return error("crypto.bcrypt: cost $cost is outside allowed range ($min_cost,$max_cost)")
	}
	
	p.cost = cost
	hash_ = hash_[3..]

	p.salt = []byte{len: encoded_salt_size, cap: encoded_salt_size+2}
	copy(p.salt, hash_[..encoded_salt_size])

	hash_ = hash_[encoded_salt_size..]
	p.hash = []byte{len: hash_.len}
	copy(p.hash, hash_)

	return &p
}

fn bcrypt(pwd []byte, cost int, salt []byte) ?[]byte {
	mut cipher_data := []byte{len: magic_cipher_data.len}
	copy(cipher_data, magic_cipher_data)

	c := expensive_blowfish_setup(pwd, u32(cost), salt) or {
		return err
	}

	for i := 0; i < 24; i += 8 {
		for j := 0; j < 64; j++ {
			c.encrypt(mut cipher_data[i..i+8], cipher_data[i..i+8])
		}
	}

	hash := base64.encode(cipher_data[..max_crypted_hash_size])
	return hash.bytes()
}

fn expensive_blowfish_setup(key []byte, cost u32, salt []byte) ?blowfish.Cipher {
	csalt := base64.decode(salt.bytestr())

	mut ckey := []byte{len: key.len, init: 0}
	copy(ckey, key)

	mut c := blowfish.new_salted_cipher(ckey, salt) or {
		return err
	}	

	mut i, mut rounds := u64(0), 0
	rounds = 1 << cost
	for i = 0; i < rounds; i++ {
		blowfish.expand_key(ckey, mut c)
		blowfish.expand_key(csalt, mut c)
	}

	return c
}

pub fn (p Hashed) hash() []byte {
	mut arr := []byte{len: 60}
	arr[0] = "$".bytes()[0]
	arr[1] = p.major
	mut n := 2
	if p.major != 0 {
		arr[2] = p.minor
		n = 3
	} 
	arr[n] = "$".bytes()[0]
	n++
	copy(arr[n..], "${int(p.cost):02}".bytes())
	n += 2
	arr[n] = "$".bytes()[0]
	n++
	copy(arr[n..], p.salt)
	n += encoded_salt_size
	copy(arr[n..], p.hash)
	n += encoded_hash_size
	return arr[..n]
}


