variable "instance_type" {
  default = "t2.micro"
}

variable "public_key_path" {
  default = "/var/lib/jenkins/.ssh/id_rsa.pub"
}
