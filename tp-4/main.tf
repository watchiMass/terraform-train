provider "aws" {
  region  = "us-east-1"
  shared_credentials_files = ["../.secrets/credentials"]
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

resource "aws_key_pair" "public_key" {
  key_name   = "user_dev_ssh_key"
  public_key = file("../.secrets/user_dev_ssh_key.pub")

}

resource "aws_instance" "dynamic-ec2" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instanceType
  vpc_security_group_ids = [aws_security_group.allow_http_https_ssh.id]
  key_name      = aws_key_pair.public_key.key_name
  depends_on = [ aws_key_pair.public_key ]
  root_block_device {
    delete_on_termination = true
  }

  provisioner "remote-exec" {
    inline = [
      "sudo amazon-linux-extras install nginx1 -y",
      "sudo systemctl start nginx",
      "sudo systemctl enable nginx"
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("../.secrets/user_dev_ssh_key.pem")
      host        = self.public_ip
    }

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

   provisioner "local-exec" {
    command = "echo PUBLIC IP: ${self.public_ip} ID: ${aws_instance.dynamic-ec2.id} AZ: ${aws_instance.dynamic-ec2.availability_zone} > infos_ec2.txt"
  
  }

  domain = "vpc"
}

resource "null_resource" "backend_test" {
  provisioner "local-exec" {
    command = "echo 'Backend S3 utilisé!'"
  }
}