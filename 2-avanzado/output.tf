output "default_vpc_id" {
  description = "The ID of the default VPC"
  value       = data.aws_vpc.default.id
}

output "subnet_ids" {
  description = "The IDs of all subnets in the default VPC"
  value       = data.aws_subnets.example.ids
}

output "selected_subnet_ids" {
  description = "The IDs of the two subnets selected for the ALB"
  value       = slice(data.aws_subnets.example.ids, 0, 2)
}

output "alb_dns_name" {
  description = "The DNS name of the ALB"
  value       = aws_lb.my_alb.dns_name
}

output "ec2_instance_id" {
  description = "The ID of the EC2 instance"
  value       = module.ec2_instance.id
}

output "ec2_private_ip" {
  description = "The private IP address of the EC2 instance"
  value       = module.ec2_instance.private_ip
}

output "ec2_public_ip" {
  description = "The public IP address of the EC2 instance"
  value       = module.ec2_instance.public_ip
}

output "ec2_tags" {
  value       = module.ec2_instance.tags_all
}



