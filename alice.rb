#used for connecting to hosts
require 'socket'
#crypto library
require 'openssl'
#used for generating random numbers
require 'securerandom'
host = 'lab1-15.eng.utah.edu'
port = 9090

s = TCPSocket.open(host, port)

pubkey_q = false
cert_q = false

keyF = File.new("public_key.pem", 'w')
certF = File.new("certificate.pem", 'w')

#get public key certificate from bob
while line = s.gets
	puts line.chop

	if(/BEGIN PUBLIC KEY/.match(line))
		pubkey_q = true
	end	
	if(/END PUBLIC KEY/.match(line))
		pubkey_q = false
	end
	if(/BEGIN CERTIFICATE/.match(line))
		cert_q = true
	end
	if(/END CERTIFICATE/.match(line))
		cert_q = false
	end

	if(pubkey_q)
		keyF.write(line)
	elsif cert_q
		certF.write(line)
	end
end

key = OpenSSL::PKey::RSA.new File.read 'public_key.pem'
raw = File.new('certificate.pem', 'r')
certificate = OpenSSL::X509::Certificate.new raw
raise 'certificate can not be verified' unless cert2.verify key
puts 'YAY the certificate was valid'

s.close