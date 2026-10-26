terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# AMI més recent d'Amazon Linux 2023 (x86_64) publicada per Amazon.
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Dues instàncies EC2 t3.micro amb Amazon Linux 2023.
resource "aws_instance" "ec2" {
  count = 2

  ami           = data.aws_ami.amazon_linux_2023.id
  instance_type = "t3.micro"

  tags = {
    Name = "EC2-AmazonLinux2023-${count.index + 1}"
  }
}

output "instance_ids" {
  description = "IDs de les instàncies EC2 creades"
  value       = aws_instance.ec2[*].id
}

output "instance_names" {
  description = "Etiquetes Name de les instàncies EC2"
  value       = aws_instance.ec2[*].tags["Name"]
}

output "instance_public_ips" {
  description = "IPs públiques de les instàncies EC2"
  value       = aws_instance.ec2[*].public_ip
}

output "instance_private_ips" {
  description = "IPs privades de les instàncies EC2"
  value       = aws_instance.ec2[*].private_ip
}

output "ami_id" {
  description = "ID de l'AMI Amazon Linux 2023 utilitzada"
  value       = data.aws_ami.amazon_linux_2023.id
}
