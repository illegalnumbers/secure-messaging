require 'socket'
require 'openssl'

hostname = 'lab1-16.eng.utah.edu'
port = 9090

s = TCPServer.open(port)

#make new private / public rsa key-pair
key = OpenSSL::PKey::RSA.new 2048
#write key-pair to disk
open 'private_key.pem', 'w' do |io| io.write key.to_pem end
open 'public_key.pem', 'w' do |io| io.write key.public_key.to_pem end

#create signed certificate using rsa and sha1 signature
name = OpenSSL::X509::Name.parse 'CN=nobody/DC=example'

cert = OpenSSL::X509::Certificate.new
cert.version = 2
cert.serial = 0
cert.not_before = Time.now
cert.not_after = Time.now + 3600

cert.public_key = key.public_key
cert.subject = name
cert.issuer = name
cert.sign key, OpenSSL::Digest::SHA1.new

#write the certificate to file
open 'certificate.pem', 'w' do |io| io.write cert.to_pem end

loop {
	client = s.accept
	client.puts(Time.now.ctime)
	client.puts "Now you die, connection."
	client.close
}

#assuming you now have the symmetric key from alice in cipher
#and the encodedCipherText
cipher.decrypt
plaintext = cipher.update(encodedCipherText)
plaintext << cipher.final
