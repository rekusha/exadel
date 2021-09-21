resource "aws_vpc" "vpc_for_training" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "trening_vpc"
  }
}
