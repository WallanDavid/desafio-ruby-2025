# Email Ingestor

[![CI](https://github.com/WallanDavid/desafio-ruby-2025/actions/workflows/ci.yml/badge.svg)](https://github.com/WallanDavid/desafio-ruby-2025/actions/workflows/ci.yml)

Um sistema Rails completo para processamento de emails .eml com extração automática de dados de clientes, processamento em background com Sidekiq e interface web moderna.

## 🚀 Funcionalidades

- **Upload de emails .eml** via interface web
- **Parsers inteligentes** que detectam automaticamente o remetente
- **Extração de dados** (nome, email, telefone, código do produto, assunto)
- **Processamento em background** com Sidekiq + Redis
- **Interface web moderna** com Bootstrap
- **Logs detalhados** de processamento e erros
- **Limpeza automática** de logs antigos
- **Docker** para desenvolvimento e produção
- **100% testado** com RSpec
- **CI/CD** com GitHub Actions

## 🏗️ Arquitetura

### Modelos

- **Customer**: Dados extraídos dos emails (nome, email, telefone, código do produto, assunto)
- **IngestedEmail**: Emails processados com status e arquivo anexado
- **ProcessingLog**: Logs detalhados de cada processamento

### Services

- **EmailProcessor**: Orquestra o processamento completo
- **Parsers::BaseParser**: Interface base para parsers
- **Parsers::SupplierAParser**: Parser para emails de @fornecedora.com
- **Parsers::PartnerBParser**: Parser para emails de @parceirob.com
- **Logs::CleanupService**: Limpeza automática de logs antigos

### Jobs

- **ProcessEmailJob**: Processa emails em background
- **CleanupLogsJob**: Executa limpeza diária de logs

## 🛠️ Stack Tecnológica

- **Ruby 3.2.x**
- **Rails 7.1.x**
- **PostgreSQL 14+**
- **Redis** (Sidekiq)
- **Sidekiq** (background jobs)
- **Bootstrap 5** (UI)
- **Docker & Docker Compose**
- **RSpec** (testes)
- **Rubocop** (linting)

## 📋 Pré-requisitos

- Docker
- Docker Compose
- Git

## 🚀 Instalação e Execução

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

- **Aplicação**: http://localhost:3000
- **Sidekiq UI**: http://localhost:3000/sidekiq

## 📧 Como Usar

### Upload de Emails

1. Acesse http://localhost:3000
2. Selecione um arquivo .eml
3. Clique em "Upload and Process"
4. O sistema processará automaticamente em background

### Visualizar Dados

- **Customers**: Lista de clientes extraídos com filtros
- **Logs**: Logs detalhados de processamento
- **Sidekiq**: Monitor de jobs em background

### Emails Suportados

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
```

## 📁 Estrutura do Projeto

```
app/
├── controllers/          # Controllers Rails
├── jobs/                # Background jobs
├── models/              # Models ActiveRecord
├── services/            # Services de negócio
│   ├── parsers/         # Parsers de email
│   └── logs/            # Services de limpeza
└── views/               # Views com Bootstrap

spec/
├── fixtures/emails/     # Fixtures de emails .eml
├── factories/           # FactoryBot factories
├── models/              # Testes de models
├── services/            # Testes de services
├── jobs/                # Testes de jobs
└── requests/            # Testes de requests

config/
├── sidekiq.yml          # Configuração Sidekiq
├── routes.rb            # Rotas da aplicação
└── environments/        # Configurações por ambiente
```

## 🔄 Fluxo de Processamento

1. **Upload**: Usuário faz upload do .eml
2. **Criação**: Sistema cria `IngestedEmail` com status `queued`
3. **Job**: `ProcessEmailJob` é enfileirado
4. **Parser**: Sistema detecta remetente e escolhe parser
5. **Extração**: Parser extrai dados do email
6. **Validação**: Verifica se há dados de contato (email ou telefone)
7. **Customer**: Cria `Customer` se dados válidos
8. **Log**: Cria `ProcessingLog` com resultado
9. **Status**: Atualiza status do `IngestedEmail`

## 🧹 Limpeza Automática

- **Agendamento**: Diário às 02:00 via Sidekiq Cron
- **Retenção**: 30 dias (configurável via `LOG_RETENTION_DAYS`)
- **Limpeza**: Remove logs antigos e emails sem logs

## 🔌 Adicionando Novo Parser

1. Crie nova classe em `app/services/parsers/`:

```ruby
class Parsers::NewParser < Parsers::BaseParser
  def self.matches?(mail, sender_domain)
    sender_domain&.include?('newsender.com')
  end

  private

  def extract_name
    # Sua lógica de extração
  end

  def extract_email
    # Sua lógica de extração
  end

  def extract_phone
    # Sua lógica de extração
  end

  def extract_product_code
    # Sua lógica de extração
  end
end
```

2. Adicione ao array `PARSERS` em `EmailProcessor`:

```ruby
PARSERS = [
  Parsers::SupplierAParser,
  Parsers::PartnerBParser,
  Parsers::NewParser  # Adicione aqui
].freeze
```

3. Crie testes em `spec/services/parsers/new_parser_spec.rb`

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

- **Parser não encontrado**: Log de falha, sem criação de customer
- **Dados de contato ausentes**: Log de falha, sem criação de customer
- **Erro de processamento**: Log detalhado com stack trace
- **Arquivo corrompido**: Log de erro, email marcado como failed

## 📊 Monitoramento

- **Sidekiq UI**: http://localhost:3000/sidekiq
- **Logs**: `docker compose logs -f`
- **Health checks**: Configurados para todos os serviços

## 🤝 Contribuição

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

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
- Comunidade Ruby pela inspiração

---

**Desenvolvido com ❤️ usando Ruby on Rails**
