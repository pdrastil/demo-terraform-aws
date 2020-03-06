output "dns_name" {
  value       = aws_elb.elb.dns_name
  description = "DNS name for accessing instances"
}
