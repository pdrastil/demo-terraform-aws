output "vpc" {
  value       = aws_vpc.vpc
  description = "The created VPC"
}

output "public_subnets" {
  value = [
    aws_subnet.public1_subnet,
    aws_subnet.public2_subnet
  ]
  description = "The list of of created public subnets"
}

output "private_subnets" {
  value = [
    aws_subnet.private1_subnet,
    aws_subnet.private2_subnet
  ]
  description = "The list of of created private subnets"
}
