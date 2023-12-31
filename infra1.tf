terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "ap-south-1"
}

resource "aws_instance" "myec2" {
  ami           = "ami-0d951b011aa0b2c19"
  instance_type = "t2.micro" 

  tags = {
    Name = "HelloWorld"
  }
}
