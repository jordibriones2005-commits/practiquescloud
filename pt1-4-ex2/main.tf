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
  region = var.aws_region

  default_tags {
    tags = {
      Project   = var.project_name
      ManagedBy = "Terraform"
    }
  }
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

# VPC principal de l'exercici: 10.0.0.0/16.
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

# Internet Gateway que dona sortida a Internet a les subxarxes públiques.
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

# Les 3 subxarxes, totes a la mateixa zona de disponibilitat (us-east-1a).
resource "aws_subnet" "public" {
  for_each = var.subnets

  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-${each.value.name}"
    Type = "public"
  }
}

# Taula de rutes pública: 0.0.0.0/0 cap a l'Internet Gateway.
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.project_name}-rtb-public"
  }
}

# Associació de la taula de rutes amb cadascuna de les 3 subxarxes.
resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# Security Group comú: SSH des del rang autoritzat i HTTP obert.
resource "aws_security_group" "instances" {
  name        = "${var.project_name}-sg"
  description = "Acces SSH i HTTP a les instancies de ${var.project_name}"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH des del rang autoritzat"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_cidr]
  }

  ingress {
    description = "HTTP public"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Sortida sense restriccions"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-sg"
  }
}

# 2 instàncies EC2 a cadascuna de les 3 subxarxes (6 en total).
locals {
  instances = merge([
    for subnet_key, subnet in var.subnets : {
      for index in range(1, var.instances_per_subnet + 1) :
      "${subnet_key}-${index}" => {
        subnet_key = subnet_key
        subnet     = subnet.name
        subnet_az  = subnet.availability_zone
        index      = index
      }
    }
  ]...)
}

resource "aws_instance" "ec2" {
  for_each = local.instances

  ami                         = data.aws_ami.amazon_linux_2023.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public[each.value.subnet_key].id
  vpc_security_group_ids      = [aws_security_group.instances.id]
  associate_public_ip_address = true

  tags = {
    Name   = "EC2-${each.value.subnet}-${each.value.index}"
    Subnet = each.value.subnet
    AZ     = each.value.subnet_az
  }
}
