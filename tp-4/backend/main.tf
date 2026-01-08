provider "aws" {
  region  = "us-east-1"
  shared_credentials_files = ["/home/jeriel/Téléchargements/devops_projects/terraform-train/.secrets/credentials"]
  profile = "default"
}



#####################################################
### This creates a s3 bucket and a dynamoDB table ###
#####################################################

resource "aws_s3_bucket" "terraform_state" {
  bucket = "terraform-state-wongo"
  force_destroy = true

  tags = {
    Name = "Terraform State Bucket"
  }
}


resource "aws_s3_bucket_versioning" "terraform_state_versioning" {
  bucket = aws_s3_bucket.terraform_state.id
  
  versioning_configuration {
    status = "Enabled"
  }
}


resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state_encryption" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Bloquer l'accès public
# resource "aws_s3_bucket_public_access_block" "terraform_state_block" {
#   bucket = aws_s3_bucket.terraform_state.id

#   block_public_acls       = true
#   block_public_policy     = true
#   ignore_public_acls      = true
#   restrict_public_buckets = true
# }



resource "aws_dynamodb_table" "terraform_lock_state" {
  name         = "terraform-locks-wongo"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

