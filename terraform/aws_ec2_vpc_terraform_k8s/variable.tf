# aws region
variable "region" {
  default = "eu-central-1"
}

# aws image name ubuntu 20.04 x86 eu-central-1
variable "ami" {
  default = "ami-05f7491af5eef733a"
}

#instance type
variable "instance_type" {
  default = "t2.micro"
}
