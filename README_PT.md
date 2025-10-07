# Email Ingestor - Sistema de Processamento de Emails

[![CI](https://github.com/WallanDavid/desafio-ruby-2025/actions/workflows/ci.yml/badge.svg)](https://github.com/WallanDavid/desafio-ruby-2025/actions/workflows/ci.yml)

Sistema completo de processamento de emails .eml com extração automática de dados de clientes usando Ruby on Rails 7.1, Sidekiq e PostgreSQL.

## 📋 Índice

- [Funcionalidades](#funcionalidades)
- [Arquitetura](#arquitetura)
- [Stack Tecnológica](#stack-tecnológica)
- [Instalação](#instalação)
- [Uso](#uso)
- [Testes](#testes)
- [Docker](#docker)
- [Documentação](#documentação)

## 🚀 Funcionalidades

- ✅ Upload de emails .eml via interface web moderna
- ✅ Parsers inteligentes com detecção automática de remetente
- ✅ Extração de dados (nome, email, telefone, código do produto, assunto)
- ✅ Processamento em background com Sidekiq + Redis
- ✅ Interface web responsiva com Bootstrap 5
- ✅ Logs detalhados de processamento e erros
- ✅ Limpeza automática de logs antigos (configurável)
- ✅ Docker para desenvolvimento e produção
- ✅ 100% testado com RSpec
- ✅ CI/CD com GitHub Actions
- ✅ Paginação com Kaminari
- ✅ Validações robustas de dados

## 🏗️ Arquitetura

### Modelos

- **Customer**: Armazena dados extraídos dos emails
- **IngestedEmail**: Gerencia emails processados com status e arquivo anexado
- **ProcessingLog**: Registra logs detalhados de cada processamento

### Services

- **EmailProcessor**: Orquestra o processamento completo do email
- **Parsers::BaseParser**: Interface base para implementação de parsers
- **Parsers::SupplierAParser**: Parser para emails de @fornecedora.com
- **Parsers::PartnerBParser**: Parser para emails de @parceirob.com
- **Logs::CleanupService**: Service de limpeza automática de logs antigos

### Jobs

- **ProcessEmailJob**: Processa emails em background via Sidekiq
- **CleanupLogsJob**: Executa limpeza diária de logs (agendado via Sidekiq Cron)

## 🛠️ Stack Tecnológica

- **Ruby** 3.2.9
- **Rails** 7.1.x
- **PostgreSQL** 14+
- **Redis** (para Sidekiq)
- **Sidekiq** 7.x (processamento em background)
- **Bootstrap 5** (interface web)
- **Docker & Docker Compose**
- **RSpec** (testes)
- **Rubocop** (linting)
- **Kaminari** (paginação)
- **Lograge** (logs estruturados)

## 📋 Pré-requisitos

- Docker
- Docker Compose
- Git

## 🚀 Instalação

### 1. Clone o repositório

```bash
git clone https://github.com/WallanDavid/desafio-ruby-2025.git
cd desafio-ruby-2025
```

### 2. Configure e inicie os serviços

```bash
# Build e prepara o banco de dados
make setup

# Inicia todos os serviços
make up
```

### 3. Acesse a aplicação

- **Aplicação Web**: http://localhost:3000
- **Sidekiq Dashboard**: http://localhost:3000/sidekiq

## 📧 Uso

### Upload de Emails

1. Acesse http://localhost:3000
2. Clique em "Choose File" e selecione um arquivo .eml
3. Clique em "Upload and Process"
4. O sistema processará automaticamente em background

### Visualizar Dados

- **Customers**: Lista de clientes extraídos com filtros por email e telefone
- **Logs**: Logs detalhados de processamento com filtros por status e parser
- **Sidekiq**: Monitor de jobs em background

### Formatos de Email Suportados

#### Fornecedor A (@fornecedora.com)

```
Nome: João Silva
Email: joao@example.com
Telefone: (11) 99999-9999
Código do Produto: PROD-123
```

#### Parceiro B (@parceirob.com)

```
Nome do Cliente: Carlos Mendes
Email: carlos@business.com
Telefone: (21) 99999-9999
Código do Produto: PARTNER-456
```

## 🧪 Testes

```bash
# Executar todos os testes
make test

# Executar linter
make lint

# Console Rails
make console
```

### Estrutura de Testes

- **Models**: Validações e scopes
- **Services**: Lógica de negócio e parsers
- **Jobs**: Background jobs
- **Requests**: Controllers e rotas

## 🔧 Comandos Úteis

```bash
# Ver logs
make logs

# Parar serviços
make down

# Limpar containers e volumes
make clean

# Reset completo do banco
make reset

# Shell no container web
make shell
```

## 📁 Estrutura do Projeto

```
desafio-ruby-2025/
├── app/
│   ├── controllers/          # Controllers Rails
│   ├── jobs/                # Background jobs (Sidekiq)
│   ├── models/              # Models ActiveRecord
│   ├── services/            # Services de negócio
│   │   ├── parsers/         # Parsers de email
│   │   └── logs/            # Services de limpeza
│   └── views/               # Views com Bootstrap
├── spec/
│   ├── fixtures/emails/     # Fixtures de emails .eml
│   ├── factories/           # FactoryBot factories
│   ├── models/              # Testes de models
│   ├── services/            # Testes de services
│   ├── jobs/                # Testes de jobs
│   └── requests/            # Testes de requests
└── config/
    ├── sidekiq.yml          # Configuração Sidekiq
    ├── routes.rb            # Rotas da aplicação
    └── environments/        # Configurações por ambiente
```

## 🔄 Fluxo de Processamento

1. **Upload**: Usuário faz upload do arquivo .eml
2. **Criação**: Sistema cria `IngestedEmail` com status `queued`
3. **Enfileiramento**: `ProcessEmailJob` é enfileirado no Sidekiq
4. **Detecção**: Sistema detecta remetente e escolhe parser apropriado
5. **Extração**: Parser extrai dados do email
6. **Validação**: Verifica se há dados de contato (email OU telefone)
7. **Persistência**: Cria `Customer` se dados válidos
8. **Registro**: Cria `ProcessingLog` com resultado
9. **Finalização**: Atualiza status do `IngestedEmail`

## 🧹 Limpeza Automática

- **Agendamento**: Diário às 02:00 via Sidekiq Cron
- **Retenção**: 30 dias (configurável via variável `LOG_RETENTION_DAYS`)
- **Limpeza**: Remove logs antigos e emails sem logs associados

## 🔌 Adicionando Novo Parser

### 1. Crie a classe do parser

```ruby
# app/services/parsers/new_parser.rb
class Parsers::NewParser < Parsers::BaseParser
  def self.matches?(mail, sender_domain)
    sender_domain&.include?('newsender.com')
  end

  private

  def extract_name
    body = clean_html(email_body)
    name_match = body.match(/Nome:\s+(.+)/)
    name_match&.[](1)&.strip
  end

  def extract_email
    body = clean_html(email_body)
    email_match = body.match(/Email:\s+([^\s]+)/)
    email_match&.[](1)
  end

  def extract_phone
    body = clean_html(email_body)
    phone_match = body.match(/Telefone:\s+(.+)/)
    normalize_phone(phone_match&.[](1))
  end

  def extract_product_code
    body = clean_html(email_body)
    code_match = body.match(/Código:\s+(.+)/)
    code_match&.[](1)&.upcase
  end
end
```

### 2. Adicione ao EmailProcessor

```ruby
# app/services/email_processor.rb
PARSERS = [
  Parsers::SupplierAParser,
  Parsers::PartnerBParser,
  Parsers::NewParser  # Adicione aqui
].freeze
```

### 3. Crie os testes

```ruby
# spec/services/parsers/new_parser_spec.rb
require 'rails_helper'

RSpec.describe Parsers::NewParser do
  # Seus testes aqui
end
```

## 🐳 Docker

### Serviços

- **web**: Aplicação Rails (porta 3000)
- **sidekiq**: Worker de background jobs
- **db**: PostgreSQL 14
- **redis**: Redis para Sidekiq

### Variáveis de Ambiente

```bash
DATABASE_URL=postgresql://postgres:postgres@db:5432/email_ingestor_development
REDIS_URL=redis://redis:6379/0
RAILS_ENV=development
LOG_RETENTION_DAYS=30
```

## 🚨 Tratamento de Erros

- **Parser não encontrado**: Log de falha, email marcado como failed
- **Dados de contato ausentes**: Log de falha, email marcado como failed
- **Erro de processamento**: Log detalhado com stack trace, email marcado como failed
- **Arquivo corrompido**: Log de erro, email marcado como failed

## 📊 Monitoramento

- **Sidekiq Dashboard**: http://localhost:3000/sidekiq
- **Logs da aplicação**: `docker compose logs -f web`
- **Logs do Sidekiq**: `docker compose logs -f sidekiq`
- **Health checks**: Configurados para todos os serviços

## 🤝 Contribuição

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

### Diretrizes

- Mantenha a cobertura de testes em 100%
- Siga as convenções do Rubocop
- Documente novas funcionalidades
- Escreva testes primeiro (TDD)

## 📝 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

## 👨‍💻 Autor

**Wallan David**
- GitHub: [@WallanDavid](https://github.com/WallanDavid)
- Email: wallan.david@example.com

## 🙏 Agradecimentos

- Rails team pela excelente framework
- Sidekiq pela solução robusta de background jobs
- Bootstrap pela interface moderna
- Comunidade Ruby pela inspiração e suporte

---

**Desenvolvido com ❤️ usando Ruby on Rails**
