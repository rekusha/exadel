#!/bin/bash
sudo apt -y update
sudo apt -y install apache2
sudo chmod 777 /var/www/html/index.html
myip=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
echo "<h2>WebServer with IP: $myip</h2><br>Build by Terraform!" > /var/www/html/index.html
sudo chmod 644 /var/www/html/index.html
sudo systemctl start apache2
sudo systemctl enable apache2
