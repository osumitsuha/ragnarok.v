module blowfish

fn get_next_word(b []byte, pos int) u32 {
	mut w := u32(0)
	mut j := 0
	unsafe {
		j = pos
	}
	for i := 0; i < 4; i++ {
		w = w<<8 | u32(b[pos])
		j++
		if j >= b.len {
			j = 0
		}
	}
	return w
}

pub fn expand_key(key []byte, mut c Cipher) {
	mut j := 0
	for i := 0; i < 18; i++ {
		mut d := u32(0)
		for k := 0; k < 4; k++ {
			if j >= key.len {
				j = 0
			}
			d = (d << 8) | key[j]
			j++
		}
		c.p[i] ^= d
	}

	mut l := u32(0)
	mut r := u32(0)
	for i := 0; i < 18; i += 2 {
		l, r = encrypt_block(l, r, c)
		c.p[i], c.p[i+1] = l, r
	}
	for i := 0; i < 256; i += 2 {
		l, r = encrypt_block(l, r, c)
		c.s0[i], c.s0[i+1] = l, r 
	}
	for i := 0; i < 256; i += 2 {
		l, r = encrypt_block(l, r, c)
		c.s1[i], c.s1[i+1] = l, r 
	}
	for i := 0; i < 256; i += 2 {
		l, r = encrypt_block(l, r, c)
		c.s2[i], c.s2[i+1] = l, r 
	}
	for i := 0; i < 256; i += 2 {
		l, r = encrypt_block(l, r, c)
		c.s3[i], c.s3[i+1] = l, r 
	}
	return
}

pub fn expand_key_with_salt(key []byte, salt []byte, mut c Cipher) {
	mut pos := 0
	for i := 0; i < 18; i++ {
		c.p[i] ^= get_next_word(key, pos)
	}

	pos = 0
	mut l := u32(0)
	mut r := u32(0)
	for i := 0; i < 18; i += 2 {
		l ^= get_next_word(salt, pos)
		r ^= get_next_word(salt, pos)
		l, r = encrypt_block(l, r, c)
		c.p[i], c.p[i+1] = l, r
	}

	for i := 0; i < 256; i += 2 {
		l ^= get_next_word(salt, pos)
		r ^= get_next_word(salt, pos)
		l, r = encrypt_block(l, r, c)
		c.s0[i], c.s0[i+1] = l, r
	}

	for i := 0; i < 256; i += 2 {
		l ^= get_next_word(salt, pos)
		r ^= get_next_word(salt, pos)
		l, r = encrypt_block(l, r, c)
		c.s1[i], c.s1[i+1] = l, r
	}

	for i := 0; i < 256; i += 2 {
		l ^= get_next_word(salt, pos)
		r ^= get_next_word(salt, pos)
		l, r = encrypt_block(l, r, c)
		c.s2[i], c.s2[i+1] = l, r
	}

	for i := 0; i < 256; i += 2 {
		l ^= get_next_word(salt, pos)
		r ^= get_next_word(salt, pos)
		l, r = encrypt_block(l, r, c)
		c.s3[i], c.s3[i+1] = l, r
	}
}

fn encrypt_block(l u32, r u32, c &Cipher) (u32, u32) {
	mut xl := l
	mut xr := r
	xl ^= c.p[0]
	xr ^= ((c.s0[byte(xl>>24)] + c.s1[byte(xl>>16)]) ^ c.s2[byte(xl>>8)]) + c.s3[byte(xl)] ^ c.p[1]
	xl ^= ((c.s0[byte(xr>>24)] + c.s1[byte(xr>>16)]) ^ c.s2[byte(xr>>8)]) + c.s3[byte(xr)] ^ c.p[2]
	xr ^= ((c.s0[byte(xl>>24)] + c.s1[byte(xl>>16)]) ^ c.s2[byte(xl>>8)]) + c.s3[byte(xl)] ^ c.p[3]
	xl ^= ((c.s0[byte(xr>>24)] + c.s1[byte(xr>>16)]) ^ c.s2[byte(xr>>8)]) + c.s3[byte(xr)] ^ c.p[4]
	xr ^= ((c.s0[byte(xl>>24)] + c.s1[byte(xl>>16)]) ^ c.s2[byte(xl>>8)]) + c.s3[byte(xl)] ^ c.p[5]
	xl ^= ((c.s0[byte(xr>>24)] + c.s1[byte(xr>>16)]) ^ c.s2[byte(xr>>8)]) + c.s3[byte(xr)] ^ c.p[6]
	xr ^= ((c.s0[byte(xl>>24)] + c.s1[byte(xl>>16)]) ^ c.s2[byte(xl>>8)]) + c.s3[byte(xl)] ^ c.p[7]
	xl ^= ((c.s0[byte(xr>>24)] + c.s1[byte(xr>>16)]) ^ c.s2[byte(xr>>8)]) + c.s3[byte(xr)] ^ c.p[8]
	xr ^= ((c.s0[byte(xl>>24)] + c.s1[byte(xl>>16)]) ^ c.s2[byte(xl>>8)]) + c.s3[byte(xl)] ^ c.p[9]
	xl ^= ((c.s0[byte(xr>>24)] + c.s1[byte(xr>>16)]) ^ c.s2[byte(xr>>8)]) + c.s3[byte(xr)] ^ c.p[10]
	xr ^= ((c.s0[byte(xl>>24)] + c.s1[byte(xl>>16)]) ^ c.s2[byte(xl>>8)]) + c.s3[byte(xl)] ^ c.p[11]
	xl ^= ((c.s0[byte(xr>>24)] + c.s1[byte(xr>>16)]) ^ c.s2[byte(xr>>8)]) + c.s3[byte(xr)] ^ c.p[12]
	xr ^= ((c.s0[byte(xl>>24)] + c.s1[byte(xl>>16)]) ^ c.s2[byte(xl>>8)]) + c.s3[byte(xl)] ^ c.p[13]
	xl ^= ((c.s0[byte(xr>>24)] + c.s1[byte(xr>>16)]) ^ c.s2[byte(xr>>8)]) + c.s3[byte(xr)] ^ c.p[14]
	xr ^= ((c.s0[byte(xl>>24)] + c.s1[byte(xl>>16)]) ^ c.s2[byte(xl>>8)]) + c.s3[byte(xl)] ^ c.p[15]
	xl ^= ((c.s0[byte(xr>>24)] + c.s1[byte(xr>>16)]) ^ c.s2[byte(xr>>8)]) + c.s3[byte(xr)] ^ c.p[16]
	xr ^= c.p[17]
	return xr, xl
}

fn decrypt_block(l u32, r u32, c &Cipher) (u32, u32) {
	mut xl := l
	mut xr := r
	xl ^= c.p[17]
	xr ^= ((c.s0[byte(xl>>24)] + c.s1[byte(xl>>16)]) ^ c.s2[byte(xl>>8)]) + c.s3[byte(xl)] ^ c.p[16]
	xl ^= ((c.s0[byte(xr>>24)] + c.s1[byte(xr>>16)]) ^ c.s2[byte(xr>>8)]) + c.s3[byte(xr)] ^ c.p[15]
	xr ^= ((c.s0[byte(xl>>24)] + c.s1[byte(xl>>16)]) ^ c.s2[byte(xl>>8)]) + c.s3[byte(xl)] ^ c.p[14]
	xl ^= ((c.s0[byte(xr>>24)] + c.s1[byte(xr>>16)]) ^ c.s2[byte(xr>>8)]) + c.s3[byte(xr)] ^ c.p[13]
	xr ^= ((c.s0[byte(xl>>24)] + c.s1[byte(xl>>16)]) ^ c.s2[byte(xl>>8)]) + c.s3[byte(xl)] ^ c.p[12]
	xl ^= ((c.s0[byte(xr>>24)] + c.s1[byte(xr>>16)]) ^ c.s2[byte(xr>>8)]) + c.s3[byte(xr)] ^ c.p[11]
	xr ^= ((c.s0[byte(xl>>24)] + c.s1[byte(xl>>16)]) ^ c.s2[byte(xl>>8)]) + c.s3[byte(xl)] ^ c.p[10]
	xl ^= ((c.s0[byte(xr>>24)] + c.s1[byte(xr>>16)]) ^ c.s2[byte(xr>>8)]) + c.s3[byte(xr)] ^ c.p[9]
	xr ^= ((c.s0[byte(xl>>24)] + c.s1[byte(xl>>16)]) ^ c.s2[byte(xl>>8)]) + c.s3[byte(xl)] ^ c.p[8]
	xl ^= ((c.s0[byte(xr>>24)] + c.s1[byte(xr>>16)]) ^ c.s2[byte(xr>>8)]) + c.s3[byte(xr)] ^ c.p[7]
	xr ^= ((c.s0[byte(xl>>24)] + c.s1[byte(xl>>16)]) ^ c.s2[byte(xl>>8)]) + c.s3[byte(xl)] ^ c.p[6]
	xl ^= ((c.s0[byte(xr>>24)] + c.s1[byte(xr>>16)]) ^ c.s2[byte(xr>>8)]) + c.s3[byte(xr)] ^ c.p[5]
	xr ^= ((c.s0[byte(xl>>24)] + c.s1[byte(xl>>16)]) ^ c.s2[byte(xl>>8)]) + c.s3[byte(xl)] ^ c.p[4]
	xl ^= ((c.s0[byte(xr>>24)] + c.s1[byte(xr>>16)]) ^ c.s2[byte(xr>>8)]) + c.s3[byte(xr)] ^ c.p[3]
	xr ^= ((c.s0[byte(xl>>24)] + c.s1[byte(xl>>16)]) ^ c.s2[byte(xl>>8)]) + c.s3[byte(xl)] ^ c.p[2]
	xl ^= ((c.s0[byte(xr>>24)] + c.s1[byte(xr>>16)]) ^ c.s2[byte(xr>>8)]) + c.s3[byte(xr)] ^ c.p[1]
	xr ^= c.p[0]
	return xr, xl
}

