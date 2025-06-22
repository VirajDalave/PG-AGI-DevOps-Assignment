output "alb_dns_name" {
  value = module.alb.alb_dns_name
}

output "ecs_cluster_name" {
  value       = module.ecs.cluster_name
}

output "backend_service_name" {
  value       = module.ecs.backend_service_name
}

output "frontend_service_name" {
  value       = module.ecs.frontend_service_name
}

output "vpc_id" {
  value       = module.vpc.vpc_id
}


