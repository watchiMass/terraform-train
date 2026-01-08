provider "aws" {
  region  = "us-east-1"
  shared_credentials_files = ["${path.module}/.secrets/credentials"]
  profile = "default"
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["137112412989"] # Amazon

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}



resource "aws_instance" "dynamic-ec2" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instanceType
  vpc_security_group_ids = [aws_security_group.allow_http_https_ssh.id]
  key_name      = "my-ec2-key"
  root_block_device {
    delete_on_termination = true
  }
  tags = {
    Name = "ec2-${var.tagPrenom}"
  }
}


resource "aws_security_group" "allow_http_https_ssh" {
  name        = "PublicSecurityGroup-${var.tagPrenom}"
  description = "Allow HTTP, HTTPS, and SSH"

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
 ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Public IP
  }
  egress{ 
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"] 
  }
}



resource "aws_eip" "load_balancer" {
  instance = aws_instance.dynamic-ec2.id
  domain = "vpc"
}