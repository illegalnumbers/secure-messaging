#used for connecting to hosts
require 'socket'
#crypto library
require 'openssl'
#used for generating random numbers
require 'securerandom'

host = 'lab1-15.eng.utah.edu'
port = 9090

s = TCPSocket.open(host, port)

#get public key certificate from bob
while line = s.gets
	puts line.chop
end

#verify the certificate with the given public key
raise 'certificate can not be verified' unless cert2.verify key


# For testing purposes only!
 message = 'MyTestString'
 #i think key should be alice's private key
 key = 'PasswordPasswordPassword'
 iv = '12345678'

# # Encrypt plaintext using Triple DES
 cipher = OpenSSL::Cipher::Cipher.new("des3")
 cipher.encrypt # Call this before setting key or iv
 cipher.key = key
 cipher.iv = iv
 ciphertext = cipher.update(message)
 ciphertext << cipher.final

s.close
