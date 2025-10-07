# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-01-15

### Added
- Sistema completo de processamento de emails .eml
- Upload de arquivos via interface web moderna
- Parsers inteligentes para @fornecedora.com e @parceirob.com
- Extração automática de dados (nome, email, telefone, código do produto, assunto)
- Processamento em background com Sidekiq
- Interface web responsiva com Bootstrap 5
- Logs detalhados de processamento
- Limpeza automática de logs antigos (configurável)
- Paginação com Kaminari
- Validações robustas de dados
- Testes completos com RSpec
- CI/CD com GitHub Actions
- Docker e Docker Compose para desenvolvimento
- Documentação completa em português e inglês

### Features
- Customer model com validações de email e telefone
- IngestedEmail model com status tracking
- ProcessingLog model para auditoria
- EmailProcessor service para orquestração
- Base parser pattern para extensibilidade
- SupplierAParser para emails do fornecedor A
- PartnerBParser para emails do parceiro B
- CleanupService para limpeza automática
- ProcessEmailJob para processamento assíncrono
- CleanupLogsJob para limpeza agendada
- Sidekiq dashboard integrado
- Filtros avançados na interface web

### Configuration
- PostgreSQL 14 como banco de dados
- Redis para Sidekiq
- Ruby 3.2.9
- Rails 7.1.x
- Lograge para logs estruturados
- Rubocop para linting
- GitHub Actions para CI/CD

### Documentation
- README.md em inglês
- README_PT.md em português
- CHANGELOG.md para versionamento
- Documentação inline nos parsers
- Exemplos de emails .eml

## [Unreleased]

### Planned
- Suporte para mais formatos de email
- API REST para integração externa
- Dashboard analytics
- Notificações por webhook
- Export de dados para CSV/Excel
- Busca avançada com Elasticsearch
- Cache com Redis
- Rate limiting
- Autenticação e autorização
- Multi-tenancy
