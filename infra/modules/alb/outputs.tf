output "alb_dns_name" {
  value = aws_alb.main.dns_name
}

output "alb_sg_id" {
  value = aws_security_group.alb.id
}