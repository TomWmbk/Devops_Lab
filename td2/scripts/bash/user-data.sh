#!/usr/bin/env bash
set -e
yum update -y
yum install -y python3
echo "<h1>It works 🎯</h1><p>eu-north-1 / SG ok / port 80 ok</p>" > /home/ec2-user/index.html
cd /home/ec2-user
nohup python3 -m http.server 80 > /home/ec2-user/http.log 2>&1 &
