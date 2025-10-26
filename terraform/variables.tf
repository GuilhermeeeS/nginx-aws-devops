variable "aws_region" {
  description = "Região da AWS"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "Tipo da instância EC2 (Free Tier)"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "Nome da chave SSH"
  type        = string
  default     = "nginx-devops-key"
}

variable "public_key_path" {
  description = "Caminho para a chave pública SSH"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "docker_image" {
  description = "Imagem Docker a ser utilizada"
  type        = string
  default     = "seu-usuario/nginx-devops:latest"
}