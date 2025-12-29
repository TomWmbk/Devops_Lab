#!/usr/bin/env bash
set -e
# [1]
curl -fsSL https://rpm.nodesource.com/setup_21.x | bash -
yum install -y nodejs
# [2]
tee app.js > /dev/null << "EOF"
const http = require('http');
const server = http.createServer((req, res) => {
res.writeHead(200, { 'Content-Type': 'text/plain' });
res.end('Hello, World!\n');
});
# [3]
const port = process.env.PORT || 80;
server.listen(port,() => {
console.log(`Listening on port ${port}`);
});
EOF
# [4]
nohup node app.js &
