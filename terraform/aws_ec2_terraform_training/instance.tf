resource "aws_instance" "ubuntu" {
  ami           = "ami-05f7491af5eef733a" # amazon media image (ami) - take from list for each region, yet.
  instance_type = "t2.micro"              # instance_type it's instance type )
  # above it's a minimal configuration to create aws instance by terraform

  tags = {
    Name  = "Ubuntu server",
    owner = "orekun@gmail.com"
  }

  vpc_security_group_ids = [aws_security_group.ubuntu_group.id] # attach security group to instance

  # user data it is data what's doing after instance create
  user_data = file("ubuntu_webserver.sh")


  lifecycle {
    prevent_destroy       = false            # prevent desroy - defense for server from destroy
    ignore_changes        = [ami, user_data] # prevent change data of data in brackets
    create_before_destroy = true             # create new instance with new data befor kill old instance 
  }
}

# --------------------------------------------------------------------------

resource "aws_instance" "centos" {
  count         = 1
  ami           = "ami-08b6d44b4f6f7b279"
  instance_type = "t2.micro"

  tags = {
    Name  = "CentOS server",
    owner = "orekun@gmail.com"
  }
}
