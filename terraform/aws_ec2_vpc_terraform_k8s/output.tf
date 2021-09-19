output "public_ip" {
  value = aws_instance.k8s-master.public_ip
}
