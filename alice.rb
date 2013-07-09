require 'socket'

hostname = 'lab1-15.eng.utah.edu'
port = 9090

s = TCPSocket.open(host, port)

while line = s.gets
	puts line.chop
end
s.close
