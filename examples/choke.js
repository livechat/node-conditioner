// echo "text to write" | node stdin.js

var conditioner = require('../lib/index.js');
var link = new conditioner.Conditioner({bps: 2, latency: 1});

process.stdin.pipe(link).pipe(process.stdout);

setTimeout(function(){
	link.choke(true)
	setTimeout(function(){
		link.choke(false)
	}, 5000)
}, 5000)