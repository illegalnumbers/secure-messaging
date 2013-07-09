require 'socket'

hostname = 'lab1-16.eng.utah.edu'
port = 9090

s = TCPServer.open(port)

loop {
	client = server.accept
	client.puts(Time.now.ctime)
	clients.puts "Now you die, connection."
	client.close
}
