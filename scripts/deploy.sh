#!/bin/bash
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' 

echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}  Deploy NGINX DevOps Project  ${NC}"
echo -e "${GREEN}================================${NC}"

if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}Docker não está rodando. Inicie o Docker e tente novamente.${NC}"
    exit 1
fi

if ! command -v terraform &> /dev/null; then
    echo -e "${RED}Terraform não está instalado. Instale o Terraform e tente novamente.${NC}"
    exit 1
fi

DOCKER_USERNAME="${DOCKER_USERNAME:-seu-usuario}"
IMAGE_NAME="nginx-devops"
IMAGE_TAG="latest"
FULL_IMAGE_NAME="$DOCKER_USERNAME/$IMAGE_NAME:$IMAGE_TAG"

echo -e "\n${YELLOW}Etapa 1: Build da imagem Docker${NC}"
cd app
docker build -t $FULL_IMAGE_NAME .
echo -e "${GREEN}Build concluído!${NC}"

echo -e "\n${YELLOW}🚀 Etapa 2: Push para Docker Hub${NC}"
echo -e "${YELLOW}Fazendo login no Docker Hub...${NC}"
docker login

echo -e "${YELLOW}Enviando imagem...${NC}"
docker push $FULL_IMAGE_NAME
echo -e "${GREEN}Push concluído!${NC}"

echo -e "\n${YELLOW}Etapa 3: Provisionando infraestrutura com Terraform${NC}"
cd ../terraform

if [ ! -d ".terraform" ]; then
    echo -e "${YELLOW}Inicializando Terraform...${NC}"
    terraform init
fi

echo -e "${YELLOW}Validando configuração...${NC}"
terraform validate

echo -e "${YELLOW}Planejando mudanças...${NC}"
terraform plan -out=tfplan

echo -e "${YELLOW}Aplicando mudanças...${NC}"
read -p "Deseja aplicar as mudanças? (yes/no): " APPLY
if [ "$APPLY" = "yes" ]; then
    terraform apply tfplan
    echo -e "${GREEN}Deploy concluído!${NC}"
    
    echo -e "\n${GREEN}================================${NC}"
    echo -e "${GREEN}  Informações do Deploy${NC}"
    echo -e "${GREEN}================================${NC}"
    terraform output
    
    echo -e "\n${GREEN}Deploy finalizado com sucesso${NC}"
    echo -e "${YELLOW}Aguarde alguns minutos para a instância inicializar completamente.${NC}"
else
    echo -e "${YELLOW}Deploy cancelado${NC}"
fi

cd ..