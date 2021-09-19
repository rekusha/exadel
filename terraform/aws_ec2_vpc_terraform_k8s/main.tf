provider "aws" {
  region = var.region
}

resource "aws_instance" "k8s-master" {
  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = "aws_key"
  vpc_security_group_ids = [aws_security_group.terraform_main.id]
}

#data "aws_instance" "master_ip" {
#
#  depends_on = [aws_instance.k8s-master]
#}

resource "aws_security_group" "terraform_main" {
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = "aws_key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDOHzsp3CIxP4SAnmJY4ja/jqhpQUdTPQXrRhI1MMp2/uE8Ry9PaMCNoqxy5tuhMnuWzma23SxWNjRHaj/JY3DQvmp/8IeGK+EYVmMGp4JaPTF8U5Dc5udi90NFNzx7/220DgiRJKzn3dg/skF9DWLXWPFbobz5NzkQ7xvLgvCJS0Wzm1308Se6tP63YWppFwC0T7AJLH7NAnYIaULairvURjz1rCO5ZGREV1IsjcoLgdSs1jZaToE/G0lrgds4gqrxNbhTxxZ2bdMOh6q2oNe0TvXn5AgunpGvr6VdbuY+O7hOJR4630mFyIPMCk75ob64IFMg0Z9XWXf/5k4w1eGL orekun@KIEVL-R0041"
}

data "aws_instance" "master" {
  tags = {
    Name = "master"
  }
}

resource "null_resource" "ansible_run" {
  provisioner "local-exec" {
    command = "ansible all -i data.aws_instance.master.public_ip, -m ping -u ubuntu --private-key /home/orekun/.ssh/aws/terraform_key"
  }
}
