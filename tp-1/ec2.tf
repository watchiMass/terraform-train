terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.27.0"
    }
  } 
  required_version = "1.14.3"
}

provider "aws" {
  region  = "us-east-1"
  shared_credentials_files = ["../.secrets/credentials"]
  profile = "default"
}

resource "aws_instance" "ec2_instance" {
  ami           = "ami-0ecb62995f68bb549"
  instance_type = "t2.micro"

  
  tags = {
    Name = "ec2-wongo"

  }
}

#     Pour supprimer les volumes additionnels lors de la suppression de l'instance,
#      ajoutez l'attribut delete_on_termination à true dans la configuration du volume additionnel comme suit :
#   root_block_device {
#     volume_size           = 8
#     delete_on_termination = true
#   }
  
#   # Volume additionnel
#   ebs_block_device {
#     device_name           = "/dev/sdf"
#     volume_size           = 10
#     volume_type           = "gp3"
#     delete_on_termination = true  # ✅ Important pour les volumes supplémentaires
#   }