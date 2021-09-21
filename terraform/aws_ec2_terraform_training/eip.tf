resource "aws_eip" "ubuntu_webserver_eip" {
  instance = aws_instance.ubuntu.id
}
