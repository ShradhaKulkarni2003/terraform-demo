provider "aws" {
  region = "us-west-2"
}

resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key" {
  content  = tls_private_key.ssh_key.private_key_pem
  filename = "/var/lib/jenkins/.ssh/id_rsa"
}

resource "local_file" "public_key" {
  content  = tls_private_key.ssh_key.public_key_openssh
  filename = "/var/lib/jenkins/.ssh/id_rsa.pub"
}

resource "aws_key_pair" "generated_key" {
  key_name   = "jenkins-generated-key"
  public_key = tls_private_key.ssh_key.public_key_openssh
}

resource "aws_security_group" "web_sg" {
  name        = "web-sg"
  description = "Allow SSH and Tomcat"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_vpc" "default" {
  default = true
}

resource "aws_instance" "web_server" {
  ami           = "ami-002d71ded4acfac8c"   # Ubuntu 22.04 us-west-2
  instance_type = var.instance_type

  key_name = aws_key_pair.generated_key.key_name
  security_groups = [aws_security_group.web_sg.name]

  tags = {
    Name = "ansible-demo-instance"
  }
}
