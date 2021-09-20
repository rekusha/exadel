resource "aws_instance" "ubuntu" {
  ami           = "ami-05f7491af5eef733a" # amazon media image (ami) - take from list for each region, yet.
  instance_type = "t2.micro"              # instance_type it's instance type )
  # above it's a minimal configuration to create aws instance by terraform
  tags = {
    Name  = "Ubuntu server",
    owner = "orekun@gmail.com"
  }
  vpc_security_group_ids = [aws_security_group.ubuntu_group.id] # attach security group to instance

  user_data = <<EOF
#!/bin/bash
sudo apt -y update
sudo apt -y install apache2
sudo chmod 777 /var/www/html/index.html
myip=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
echo "<h2>WebServer with IP: $myip</h2><br>Build by Terraform!" > /var/www/html/index.html
sudo chmod 644 /var/www/html/index.html
sudo systemctl start apache2
sudo systemctl enable apache2
EOF
}

resource "aws_instance" "centos" {
  count         = 1
  ami           = "ami-08b6d44b4f6f7b279"
  instance_type = "t2.micro"

  tags = {
    Name  = "CentOS server",
    owner = "orekun@gmail.com"
  }
}
