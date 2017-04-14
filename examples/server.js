// fast direct connection - curl localhost:4000 -v
// simulate slow internet connection - curl localhost:5000 -v
// simulate client side firewall REJECT mode for naughty word - curl localhost:5000?naughty -v

var conditioner = require('../lib/index.js');
var net = require('net');
var http = require('http')
var Conditioner = conditioner.Conditioner

http.createServer(function (req, res) {
  res.writeHead(200, {'Content-Type': 'text/plain'});
  res.end("some sort of response");
}).listen(4000);

var network = new net.Server();

network.on('connection', function(client){
	connection = new net.Socket()

	var server = connection.connect({host:"localhost", port:4000}, function(){
		uplink = new Conditioner({bps: 100, latency: 100, firewall: {mode: conditioner.REJECT, sequence: "naughty", conn: client}})
		client.pipe(uplink).pipe(server)

		downlink = new Conditioner({bps: 100, latency: 100})
		server.pipe(downlink).pipe(client)
	});		
});

network.listen(5000);

// 