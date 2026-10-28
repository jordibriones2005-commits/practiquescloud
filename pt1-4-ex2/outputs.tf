output "vpc_id" {
  description = "ID de la VPC creada"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "Rang CIDR de la VPC"
  value       = aws_vpc.main.cidr_block
}

output "subnet_ids" {
  description = "IDs de les 3 subxarxes"
  value       = { for key, subnet in aws_subnet.public : key => subnet.id }
}

output "subnet_cidrs" {
  description = "Rangs CIDR de les 3 subxarxes"
  value       = { for key, subnet in aws_subnet.public : key => subnet.cidr_block }
}

output "route_table_id" {
  description = "ID de la taula de rutes pública"
  value       = aws_route_table.public.id
}

output "internet_gateway_id" {
  description = "ID de l'Internet Gateway"
  value       = aws_internet_gateway.main.id
}

output "security_group_id" {
  description = "ID del Security Group de les instàncies"
  value       = aws_security_group.instances.id
}

output "instance_ids" {
  description = "IDs de les 6 instàncies EC2"
  value       = { for key, instance in aws_instance.ec2 : key => instance.id }
}

output "instance_names" {
  description = "Etiquetes Name de les 6 instàncies EC2"
  value       = { for key, instance in aws_instance.ec2 : key => instance.tags["Name"] }
}

output "instance_public_ips" {
  description = "IPs públiques de les 6 instàncies EC2"
  value       = { for key, instance in aws_instance.ec2 : key => instance.public_ip }
}

output "instance_private_ips" {
  description = "IPs privades de les 6 instàncies EC2"
  value       = { for key, instance in aws_instance.ec2 : key => instance.private_ip }
}

output "instance_subnets" {
  description = "Subxarxa on s'ha desplegat cada instància"
  value       = { for key, instance in aws_instance.ec2 : key => instance.tags["Subnet"] }
}

output "ami_id" {
  description = "ID de l'AMI Amazon Linux 2023 utilitzada"
  value       = data.aws_ami.amazon_linux_2023.id
}
