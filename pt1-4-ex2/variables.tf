variable "aws_region" {
  description = "Regió d'AWS on es desplega la infraestructura"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Prefix utilitzat a les etiquetes de tots els recursos"
  type        = string
  default     = "Pt1.4-Ex2"
}

variable "vpc_cidr" {
  description = "Rang CIDR de la VPC principal"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnets" {
  description = "Subxarxes públiques de la VPC, totes a la mateixa zona de disponibilitat"
  type = map(object({
    name              = string
    cidr_block        = string
    availability_zone = string
  }))

  default = {
    subnet-a = {
      name              = "SubnetA"
      cidr_block        = "10.0.32.0/25"
      availability_zone = "us-east-1a"
    }
    subnet-b = {
      name              = "SubnetB"
      cidr_block        = "10.0.30.0/23"
      availability_zone = "us-east-1a"
    }
    subnet-c = {
      name              = "SubnetC"
      cidr_block        = "10.0.33.0/28"
      availability_zone = "us-east-1a"
    }
  }
}

variable "instance_type" {
  description = "Tipus d'instància EC2"
  type        = string
  default     = "t3.micro"
}

variable "instances_per_subnet" {
  description = "Nombre d'instàncies EC2 a cada subxarxa"
  type        = number
  default     = 2

  validation {
    condition     = var.instances_per_subnet > 0
    error_message = "Cal desplegar com a mínim una instància per subxarxa."
  }
}

variable "ssh_cidr" {
  description = "Rang CIDR autoritzat a connectar-se per SSH (22/tcp)"
  type        = string
  default     = "0.0.0.0/0"
}
