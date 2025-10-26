terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Pegar a VPC padrão
data "aws_vpc" "default" {
  default = true
}

# Pegar a subnet padrão
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Security Group para a EC2
resource "aws_security_group" "nginx_sg" {
  name        = "nginx-devops-sg"
  description = "Security group para NGINX web server"
  vpc_id      = data.aws_vpc.default.id

  # Liberar HTTP
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Liberar SSH
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # ATENÇÃO: Em produção, restringir ao seu IP
  }

  # Permitir todo tráfego de saída
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "nginx-devops-sg"
  }
}

# Criar key pair (você precisa ter a chave pública)
resource "aws_key_pair" "deployer" {
  key_name   = var.key_name
  public_key = file(var.public_key_path)
}

# Pegar a AMI mais recente do Amazon Linux 2
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# EC2 Instance
resource "aws_instance" "nginx_server" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = var.instance_type
  key_name      = aws_key_pair.deployer.key_name

  vpc_security_group_ids = [aws_security_group.nginx_sg.id]
  subnet_id              = data.aws_subnets.default.ids[0]

  # User data para instalar Docker e rodar o container
  user_data = <<-EOF
              #!/bin/bash
              # Atualizar sistema
              yum update -y
              
              # Instalar Docker
              amazon-linux-extras install docker -y
              systemctl start docker
              systemctl enable docker
              
              # Adicionar ec2-user ao grupo docker
              usermod -a -G docker ec2-user
              
              # Fazer pull e rodar o container NGINX
              docker pull ${var.docker_image}
              docker run -d -p 80:80 --name nginx-app --restart unless-stopped ${var.docker_image}
              EOF

  tags = {
    Name = "nginx-devops-server"
  }
}

# Elastic IP (opcional, mas recomendado para manter o IP fixo)
resource "aws_eip" "nginx_eip" {
  instance = aws_instance.nginx_server.id
  domain   = "vpc"

  tags = {
    Name = "nginx-devops-eip"
  }
}