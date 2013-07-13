# encoding: utf-8
require 'socket'
require 'openssl'
require 'json'

port = 9090

s = TCPServer.open(port)

#make new private / public rsa key-pair
rsakey = OpenSSL::PKey::RSA.new 2048

#hash the key using sha1
sha1 = OpenSSL::Digest::SHA1.new
digest = sha1.hexdigest(rsakey.public_key.to_pem)

pubkey = JSON.generate({
	key: rsakey.public_key.to_pem,
	digest: digest
	})

loop {
	client = s.accept
	#get public key from alice
	incoming = client.gets()
	alice = JSON.parse(incoming)
	alice_key = OpenSSL::PKey::RSA.new alice['key']

	#send public key to alice
	puts pubkey
	client.puts pubkey	

	#get encrypted package from alice
	json_full_package = client.gets()
	full_package = JSON.parse(json_full_package)

	#decrypt and print package	
	cipher = OpenSSL::Cipher.new("DES3")
	cipher.decrypt
	key = rsakey.private_decrypt(full_package['key'])
	iv = rsakey.private_decrypt(full_package['iv'])
	json_package = cipher.update(full_package['package'])

	package = JSON.parse(json_package)
	decrypted_digest = alice_key.public_decrypt(package['signed_digest'])
	sha1 = OpenSSL::Digest::SHA1.new
	digest = sha1.hexdigest(package['data'])
	throw 'failed digest' unless digest == decrypted_digest

	puts package['data']
	client.close
}
