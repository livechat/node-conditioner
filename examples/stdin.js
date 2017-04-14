// echo "text to write" | node stdin.js

var conditioner = require('../lib/index.js');
var link = new conditioner.Conditioner({bps: 20, latency: 1000});

process.stdin.pipe(link).pipe(process.stdout);