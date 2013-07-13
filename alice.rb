# encoding: utf-8
require 'socket'
require 'openssl'
require 'json'
require 'base64'

host = 'lab1-15.eng.utah.edu'
port = 9090

s = TCPSocket.open(host, port)
puts "tcp socket opened..."

#generate alice's key pair
rsakey = OpenSSL::PKey::RSA.new 2048
puts "key generated...."

puts "public key = #{rsakey.public_key}"
puts "private key = #{rsakey}"

to_bob_public = JSON.generate({
	key: rsakey.public_key.to_pem
	})

puts "sending the following to bob: "
puts to_bob_public

s.puts to_bob_public
puts "sent..."

#get public key certificate from bob
line = s.gets
puts "got #{line} from bob"
bob = JSON.parse(line)

bob_key = OpenSSL::PKey::RSA.new bob['key']
bob_digest = bob['digest']

puts "bob's public key is #{bob_key}"
puts "bob's digest is #{bob_digest}"

#verify public key
sha1 = OpenSSL::Digest::SHA1.new
t_digest = sha1.hexdigest(bob['key'])
throw "not verified" unless t_digest == bob_digest
puts "generated digest: #{t_digest}"
puts "digest verified!"

data = File.read('document') #data is original message

#hash the document using sha1
sha1 = OpenSSL::Digest::SHA1.new
digest = sha1.hexdigest(data)
puts "generated digest is #{digest}"

#sign with private key
signed_digest = Base64.encode64(rsakey.private_encrypt(digest))
puts "signed digest is #{signed_digest}"

#package this in json
package = JSON.generate({
		signed_digest: signed_digest,
		data: data		
	})
puts "package to bob is #{package}"

#make cipher for encryption
cipher = OpenSSL::Cipher.new("DES3")
cipher.encrypt
key = cipher.random_key
puts "key is #{key}"
iv = cipher.random_iv
puts "iv is #{iv}"

#encrypt data
encrypted = cipher.update(data) + cipher.final

#encrypt key and iv using bob's public key

#bob_key.public_encrypt should be on next 2
encrypted_cipher_key = Base64.encode64(key)
encrypted_cipher_iv = Base64.encode64(iv)
puts "encrypted cipher key is #{encrypted_cipher_key}"
puts "encrypted cipher iv is #{encrypted_cipher_iv}"

#full_package = JSON.generate({
#		key: encrypted_cipher_key,
#		iv: encrypted_cipher_iv,
#		package: encrypted		
#	})

#puts "full final package sent to bob is #{full_package}"

#send full_package to bob
s.puts key
s.puts iv
s.puts encrypted 

s.close
