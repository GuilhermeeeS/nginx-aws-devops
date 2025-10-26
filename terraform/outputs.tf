output "instance_id" {
  description = "ID da instância EC2"
  value       = aws_instance.nginx_server.id
}

output "instance_public_ip" {
  description = "IP público da instância EC2"
  value       = aws_eip.nginx_eip.public_ip
}

output "instance_public_dns" {
  description = "DNS público da instância EC2"
  value       = aws_instance.nginx_server.public_dns
}

output "security_group_id" {
  description = "ID do Security Group"
  value       = aws_security_group.nginx_sg.id
}

output "access_url" {
  description = "URL para acessar a aplicação"
  value       = "http://${aws_eip.nginx_eip.public_ip}"
}