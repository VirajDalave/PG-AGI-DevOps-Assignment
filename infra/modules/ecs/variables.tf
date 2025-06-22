variable "cluster_name" {
  type = string
  default = "PGAGI-Cluster"
}

variable "instance_type" {
    type = string
    default = "t3.micro"
}

variable "private_subnets" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}

variable "alb_sg_id" {
  type = string
}

variable "backend_port" {
  type = number
  default = 8000
}

variable "frontend_port" {
  type = number
  default = 3000
}

variable "ecr_backend_repo" {
  type = string
  default = "985539779862.dkr.ecr.ap-south-1.amazonaws.com/pgagi-backend"
}

variable "ecr_frontend_repo" {
  type = string
  default = "985539779862.dkr.ecr.ap-south-1.amazonaws.com/pgagi-frontend"
}

variable "image_tag" {
  type = string
  # default = "bd5efd335190d1e8602fdb77d08cc0b258f0667d"
}

variable "frontend_api_url" {
  type = string
}