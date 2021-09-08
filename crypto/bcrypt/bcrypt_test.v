module bcrypt

import crypto.md5

fn test_mismatched_password() ? {
	pass := "password".bytes()
	hash := generate_from_password(pass, 10) or {
		return err
	}

	// dont work
	assert compare_hash_and_password(hash, pass) == true
}