# encoding: utf-8
require 'socket'
require 'openssl'
require 'json'

host = 'lab1-15.eng.utah.edu'
port = 9090

s = TCPSocket.open(host, port)

pubkey_q = false

keyF = File.new("public_key.pem", 'w')

#generate alice's key pair
key = OpenSSL::PKey::RSA.new 2048

to_bob_public = JSON.generate({
	key: key.public_key.to_pem
	})
s.send(to_bob_public)

#get public key certificate from bob
while line = s.gets
	puts line.chop
	bob = JSON.parse(line)
end
bob_key = OpenSSL::PKey::RSA.new bob['key']
bob_digest = bob['digest']

#verify public key
sha1 = OpenSSL::Digest::SHA1.new
t_digest = sha1.hexdigest(bob['key'])
throw "not verified" unless t_digest == bob_digest

data = File.read('document') #data is original message

#hash the document using sha1
sha1 = OpenSSL::Digest::SHA1.new
digest = sha1.hexdigest(data)

#sign with private key
signed_digest = key.private_encrypt(digest)

#package this in json
package = JSON.generate({
		signed_digest: signed_digest,
		data: data		
	})

#make cipher for encryption
cipher = OpenSSL::Cipher.new("DES3")
cipher.encrypt
key = cipher.random_key
iv = cipher.random_iv
#encrypt data
encrypted = cipher.update(package) 

#encrypt key and iv using bob's public key
encrypted_cipher_key = bob_key.public_encrypt(key)
encrypted_cipher_iv = bob_key.public_encrypt(iv)

full_package = JSON.generate({
		key: encrypted_cipher_key,
		iv: encrypted_cipher_iv,
		package: encrypted		
	})

#send full_package to bob
s.send(full_package)

s.close