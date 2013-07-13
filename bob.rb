# encoding: utf-8
require 'socket'
require 'openssl'
require 'json'
require 'base64'

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
	puts "received alice's key"
	alice = JSON.parse(incoming)
	alice_key = OpenSSL::PKey::RSA.new alice['key']
	puts "alice's key is #{alice_key}"

	#send public key to alice
	puts "sending "+pubkey
	client.puts pubkey	

	#get encrypted package from alice
	json_full_package = client.gets()
	puts "received package from alice"
	puts "package contents #{json_full_package}"
	full_package = JSON.parse(json_full_package)

	#decrypt and print package	
	cipher = OpenSSL::Cipher.new("DES3")
	cipher.decrypt
	key = rsakey.private_decrypt(Base64.decode64(full_package['key']))
	puts "decrypted key is #{key}"
	iv = rsakey.private_decrypt(Base64.decode64(full_package['iv']))
	puts "decrypted iv is #{iv}"
	json_package = cipher.update(Base64.decode64(full_package['package'])) << cipher.final
	puts "decrypted package is #{json_package}"	

	package = JSON.parse(json_package)
	decrypted_digest = alice_key.public_decrypt(Base64.decode64(package['signed_digest']))
	sha1 = OpenSSL::Digest::SHA1.new
	digest = sha1.hexdigest(package['data'])
	throw 'failed digest' unless digest == decrypted_digest
	puts "digest verified!"
	puts "digest is #{digest}"	
	
	puts "final data verified and decrypted."	
	puts "data is "+package['data']
	client.close
}
