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

resource "aws_vpc" "my-vpc" {
  cidr_block = "10.0.0.16"
  instance_tenancy = "default"
  tags = {
    Name = "myvpc"
  }
}

resource "aws_subnet" "mypubsubnet" {
  vpc_id     = aws_vpc.my-vpc.id
  availability_zone = "ap-south-1a"
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "my-pub"
  }
}


resource "aws_subnet" "mypvtsubnet" {
  vpc_id     = aws_vpc.my-vpc.id
  availability_zone = "ap-south-1b"
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "my-pvt"
  }
}

resource "aws_internet_gateway" "myigw" {
  vpc_id = aws_vpc.my-vpc.id

  tags = {
    Name = "myigw"
  }
}

resource "aws_route_table" "mypubrt" {
  vpc_id = aws_vpc.my-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myigw.id
  }

    tags = {
    Name = "my-pubrt"
  }
}

resource "aws_route_table_association" "pubsubassc" {
  subnet_id      = aws_subnet.mypubsubnet.id
  route_table_id = aws_route_table.mypubrt.id
}

resource "aws_route_table" "mypvtrt" {
  vpc_id = aws_vpc.my-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    #gateway_id = aws_internet_gateway.myigw.id
  }

    tags = {
    Name = "my-pvtrt"
  }
}

resource "aws_route_table_association" "pvtsubassc" {
  subnet_id      = aws_subnet.mypvtsubnet.id
  route_table_id = aws_route_table.mypvtrt.id
}


resource "aws_security_group" "mypubsgp" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.myvpc.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 0-65536 
    to_port          = 0-65536
    protocol         = "tcp"
    cidr_blocks      = [0.0.0.0/0]
    
      }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    #ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "mypubsgp"
  }
}

resource "aws_security_group" "mypvtsgp" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.myvpc.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 0-65536 
    to_port          = 0-65536
    protocol         = "tcp"
    cidr_blocks      = [mypubsgp]
    
      }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    #ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "mypvtsgp"
  }
}
 

resource "aws_nat_gateway" "mynatgw" {
  allocation_id = aws_eip.myeip.id
  subnet_id     = aws_subnet.mypubsubnet.id

  tags = {
    Name = "myNATgw"
  }

  resource "aws_eip" "myeip" {
  #instance = aws_instance.web.id
  domain   = "vpc"
}


