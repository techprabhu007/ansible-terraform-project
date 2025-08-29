terraform {
  backend "s3" {
    bucket         = "trraform-ansible"
    key            = "Docker-Swarm-Project/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}