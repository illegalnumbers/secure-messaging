require 'socket'
require 'openssl'
require 'json'

port = 9090

s = TCPServer.open(port)

#make new private / public rsa key-pair
key = OpenSSL::PKey::RSA.new 2048

#write key-pair to disk
open 'bob_private_key.pem', 'w' do |io| io.write key.to_pem end
open 'bob_public_key.pem', 'w' do |io| io.write key.public_key.to_pem end

#hash the key using sha1
sha1 = OpenSSL::Digest::SHA1.new
digest = sha1.digest(key.public_key.to_pem)

pubkey = JSON.generate({
	key: key.public_key.to_pem
	digest: digest
	})

loop {
	client = s.accept
	incoming = client.gets()
	alice = JSON.parse(incoming)

	alice_key = OpenSSL::PKey::RSA.new alice['key']

	puts pubkey
	client.puts pubkey	

	client.close
}
