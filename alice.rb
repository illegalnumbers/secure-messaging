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

s.close