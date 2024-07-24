output "vpc_id" {
  value = aws_vpc.main.id
}

output "subnet_ids" {
  value = jsonencode([aws_subnet.subnet_1.id, aws_subnet.subnet_2.id])
}

output "security_group_id" {
  value = aws_security_group.nginx_sg.id
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.nginx_cluster.name
}

output "ecs_service_name" {
  value = aws_ecs_service.nginx_service.name
}

output "ecr_repository_url" {
  value = data.aws_ecr_repository.nginx.repository_url
}

output "aws_region" {
  value = data.aws_region.current.name
}