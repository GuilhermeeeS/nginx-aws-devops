# Projeto DevOps: NGINX + Docker + Terraform + AWS

Projeto completo de DevOps demonstrando deploy automatizado de uma aplicação web com NGINX usando Docker, Terraform e AWS (Free Tier).

## Pré-requisitos

Antes de começar, certifique-se de ter instalado:

- [Docker](https://docs.docker.com/get-docker/)
- [Terraform](https://www.terraform.io/downloads.html)
- [AWS CLI](https://aws.amazon.com/cli/)
- Conta AWS (Free Tier)
- Conta Docker Hub

## Configuração Inicial

### 1. Configurar AWS CLI

```bash
aws configure
```

Forneça:
- AWS Access Key ID
- AWS Secret Access Key
- Região padrão (ex: us-east-1)
- Formato de saída (json)

### 2. Criar Par de Chaves SSH

Se você ainda não tem um par de chaves SSH:

```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa
```

### 3. Configurar Docker Hub

Edite o arquivo `terraform/terraform.tfvars` e substitua `seu-usuario` pelo seu usuário do Docker Hub:

```hcl
docker_image = "seu-usuario/nginx-devops:latest"
```

Também edite o script `scripts/deploy.sh` na linha:

```bash
DOCKER_USERNAME="${DOCKER_USERNAME:-seu-usuario}"
```

## Deploy Manual (Passo a Passo)

### Passo 1: Build da Imagem Docker

```bash
cd app
docker build -t seu-usuario/nginx-devops:latest .
```

### Passo 2: Testar Localmente (Opcional)

```bash
docker run -d -p 8080:80 seu-usuario/nginx-devops:latest
```

Acesse: http://localhost:8080

### Passo 3: Push para Docker Hub

```bash
docker login
docker push seu-usuario/nginx-devops:latest
```

### Passo 4: Provisionar Infraestrutura

```bash
cd ../terraform
terraform init
terraform plan
terraform apply
```

### Passo 5: Acessar a Aplicação

Após o Terraform finalizar, ele mostrará o IP público:

```
access_url = "http://XX.XX.XX.XX"
```

Aguarde 2-3 minutos para a instância inicializar completamente, depois acesse a URL.

## Deploy Automatizado

Para fazer deploy de forma automatizada:

```bash
chmod +x scripts/deploy.sh
export DOCKER_USERNAME=seu-usuario
./scripts/deploy.sh
```

O script irá:
1. Fazer build da imagem Docker
2. Push para o Docker Hub
3. Provisionar infraestrutura com Terraform
4. Mostrar a URL de acesso

## Comandos Úteis

### Verificar Status da Instância

```bash
aws ec2 describe-instances --filters "Name=tag:Name,Values=nginx-devops-server"
```

### Acessar a Instância via SSH

```bash
ssh -i ~/.ssh/id_rsa ec2-user@<IP_PUBLICO>
```

### Ver Logs do Container

```bash
ssh -i ~/.ssh/id_rsa ec2-user@<IP_PUBLICO>
docker logs nginx-app
```

### Verificar Outputs do Terraform

```bash
cd terraform
terraform output
```

## Destruir Infraestrutura

Para remover todos os recursos criados na AWS:

```bash
cd terraform
terraform destroy
```

Digite `yes` quando solicitado.

**IMPORTANTE:** Sempre destrua os recursos quando não estiver usando para evitar cobranças!

## Custos (Free Tier)

Este projeto foi projetado para rodar no Free Tier da AWS:

- **EC2 t2.micro:** 750 horas/mês grátis (primeiro ano)
- **EIP:** Grátis quando associado a uma instância em execução
- **Transferência de dados:** 100GB grátis/mês

## 🐛 Troubleshooting

### Erro: "No valid credential sources found"
Execute `aws configure` e configure suas credenciais.

### Erro: "Key pair already exists"
Altere o valor de `key_name` no `terraform.tfvars` ou delete a chave existente no console AWS.

### Aplicação não responde após deploy
Aguarde 2-3 minutos para a instância inicializar. Verifique os logs:
```bash
ssh -i ~/.ssh/id_rsa ec2-user@<IP> "docker logs nginx-app"
```

### Porta 22 bloqueada
Verifique o Security Group no console AWS e certifique-se que a porta 22 está aberta para seu IP.

## 📚 Referências

- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Docker NGINX](https://hub.docker.com/_/nginx)
- [AWS Free Tier](https://aws.amazon.com/free/)

## Licença

Este projeto é livre para uso educacional.

---