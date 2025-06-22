variable "public_subnets" {
  type = list(string)
}

variable "backend_target_group_arn" {
  type = string
}

variable "frontend_target_group_arn" {
  type = string
}

variable "vpc_id" {
  type = string
}