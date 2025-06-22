output "frontend_target_group_arn" {
  value = aws_lb_target_group.frontend.arn
}

output "backend_target_group_arn" {
  value = aws_lb_target_group.backend.arn
}

output "cluster_name" {
  value = aws_ecs_cluster.main.name
}

output "backend_service_name" {
  value       = aws_ecs_service.backend.name
}

output "frontend_service_name" {
  value       = aws_ecs_service.frontend.name
}
