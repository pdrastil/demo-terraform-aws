output "vpc_id" {
  value       = aws_vpc.vpc.id
  description = "The ID of created VPC"
}

#output "public_subnets" {
#  value = [
#    aws_subnet.public1_subnet.id,
#    aws_subnet.public2_subnet.id
#  ]
#  description = "The ids of created public subnets"
#}

#output "private_subnets" {
#  value = [
#    aws_subnet.private1_subnet.id,
#    aws_subnet.private2_subnet.id
#  ]
#  description = "The ids of created private subnets"
#}
