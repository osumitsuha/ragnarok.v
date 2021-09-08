module blowfish

const block_size = 8

pub struct Cipher {
mut:
	p 		[18]u32
	s0		[256]u32
	s1		[256]u32
	s2		[256]u32
	s3		[256]u32
}

const key_size_error = error("crypto.blowfish -> invalid key size.")

pub fn new_cipher(key []byte) ?Cipher {
	if key.len < 1 || key.len > 56 {
		return key_size_error
	}

	mut result := Cipher{p, s0, s1, s2, s3}
	expand_key(key, mut result)
	return result 
}

pub fn new_salted_cipher(key []byte, salt []byte) ?Cipher {
	if salt.len == 0 {
		return new_cipher(key)
	}

	mut result := Cipher{p, s0, s1, s2, s3}
	if key.len < 1 {
		return key_size_error
	}
	expand_key_with_salt(key, salt, mut result)
	return result
}

pub fn (c &Cipher) encrypt(mut dst []byte, src []byte) {
	mut l := u32(src[0])<<24 | u32(src[1])<<16 | u32(src[2])<<8 | u32(src[3])
	mut r := u32(src[4])<<24 | u32(src[5])<<16 | u32(src[6])<<8 | u32(src[7])
	l, r = encrypt_block(l, r, c)
	dst[0], dst[1], dst[2], dst[3] = byte(l>>24), byte(l>>16), byte(l>>8), byte(l)
	dst[4], dst[5], dst[6], dst[7] = byte(r>>24), byte(r>>16), byte(r>>8), byte(r)
}

pub fn (c &Cipher) decrypt(mut dst []byte, src []byte) {
	mut l := u32(src[0])<<24 | u32(src[1])<<16 | u32(src[2])<<8 | u32(src[3])
	mut r := u32(src[4])<<24 | u32(src[5])<<16 | u32(src[6])<<8 | u32(src[7])
	l, r = decrypt_block(l, r, c)
	dst[0], dst[1], dst[2], dst[3] = byte(l>>24), byte(l>>16), byte(l>>8), byte(l)
	dst[4], dst[5], dst[6], dst[7] = byte(r>>24), byte(r>>16), byte(r>>8), byte(r)
}