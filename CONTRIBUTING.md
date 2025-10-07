# Contribuindo para Email Ingestor

Obrigado pelo seu interesse em contribuir com o Email Ingestor! Este documento fornece diretrizes para contribuições.

## Código de Conduta

Este projeto adere a um código de conduta. Ao participar, você concorda em manter um ambiente respeitoso e colaborativo.

## Como Contribuir

### Reportando Bugs

1. Verifique se o bug já não foi reportado nas [Issues](https://github.com/WallanDavid/desafio-ruby-2025/issues)
2. Crie uma nova issue com:
   - Descrição clara do problema
   - Passos para reproduzir
   - Comportamento esperado vs comportamento atual
   - Screenshots (se aplicável)
   - Ambiente (OS, Ruby version, etc.)

### Sugerindo Melhorias

1. Verifique as issues existentes para evitar duplicatas
2. Crie uma issue descrevendo:
   - O problema que a feature resolve
   - Solução proposta
   - Alternativas consideradas
   - Impacto em features existentes

### Pull Requests

1. **Fork** o repositório
2. Crie uma **branch** a partir de `main`:
   ```bash
   git checkout -b feature/minha-feature
   ```
3. Faça suas alterações seguindo o [Guia de Estilo](#guia-de-estilo)
4. **Commit** suas mudanças:
   ```bash
   git commit -m "feat: adiciona nova funcionalidade"
   ```
5. **Push** para sua branch:
   ```bash
   git push origin feature/minha-feature
   ```
6. Abra um **Pull Request**

## Guia de Estilo

### Ruby/Rails

- Siga as convenções do [Rubocop](.rubocop.yml)
- Use nomes descritivos para variáveis e métodos
- Mantenha métodos pequenos e focados (máximo 20 linhas)
- Prefira composição sobre herança
- Escreva código autoexplicativo

### Commits

Usamos [Conventional Commits](https://www.conventionalcommits.org/):

- `feat:` Nova funcionalidade
- `fix:` Correção de bug
- `docs:` Documentação
- `style:` Formatação (não afeta o código)
- `refactor:` Refatoração
- `test:` Adição/correção de testes
- `chore:` Tarefas de build/CI

Exemplos:
```
feat: adiciona parser para novo fornecedor
fix: corrige validação de email
docs: atualiza README com novos exemplos
test: adiciona testes para EmailProcessor
```

### Testes

- **SEMPRE** escreva testes para novas features
- Mantenha cobertura de **100%**
- Use RSpec para testes
- Use FactoryBot para fixtures
- Siga o padrão AAA (Arrange, Act, Assert)

Exemplo:
```ruby
RSpec.describe EmailProcessor do
  describe '#call' do
    context 'when email is valid' do
      it 'processes successfully' do
        # Arrange
        email = create(:ingested_email, :with_file)
        processor = described_class.new(email.id)
        
        # Act
        processor.call
        
        # Assert
        expect(email.reload.status).to eq('success')
      end
    end
  end
end
```

### Documentação

- Documente métodos públicos complexos
- Atualize o README quando necessário
- Adicione comentários explicativos (não óbvios)
- Mantenha a documentação sincronizada com o código

## Desenvolvimento

### Configuração do Ambiente

```bash
# Clone o repositório
git clone https://github.com/WallanDavid/desafio-ruby-2025.git
cd desafio-ruby-2025

# Configure o ambiente
make setup

# Inicie os serviços
make up
```

### Executando Testes

```bash
# Todos os testes
make test

# Testes específicos
docker compose run --rm web bundle exec rspec spec/models/customer_spec.rb

# Linter
make lint

# Auto-correção do linter
docker compose run --rm web bundle exec rubocop -a
```

### Estrutura de Arquivos

```
app/
├── controllers/     # Controllers Rails
├── jobs/           # Background jobs
├── models/         # Models ActiveRecord
├── services/       # Services de negócio
│   ├── parsers/    # Parsers de email
│   └── logs/       # Services auxiliares
└── views/          # Views

spec/
├── factories/      # FactoryBot factories
├── fixtures/       # Fixtures de teste
├── models/         # Testes de models
├── services/       # Testes de services
├── jobs/           # Testes de jobs
└── requests/       # Testes de controllers
```

### Adicionando um Novo Parser

1. Crie a classe em `app/services/parsers/`:
```ruby
class Parsers::NewParser < Parsers::BaseParser
  def self.matches?(mail, sender_domain)
    sender_domain&.include?('domain.com')
  end

  private

  def extract_name
    # Implementação
  end

  # ... outros métodos
end
```

2. Registre em `EmailProcessor`:
```ruby
PARSERS = [
  Parsers::SupplierAParser,
  Parsers::PartnerBParser,
  Parsers::NewParser
].freeze
```

3. Crie os testes em `spec/services/parsers/new_parser_spec.rb`

4. Adicione fixture de email em `spec/fixtures/emails/`

## Checklist do Pull Request

- [ ] Código segue o estilo do projeto (Rubocop)
- [ ] Testes foram adicionados/atualizados
- [ ] Todos os testes passam
- [ ] Documentação foi atualizada
- [ ] Commits seguem o padrão Conventional Commits
- [ ] Branch está atualizada com `main`
- [ ] PR tem descrição clara

## Perguntas?

Se tiver dúvidas:
- Abra uma [Issue](https://github.com/WallanDavid/desafio-ruby-2025/issues)
- Entre em contato: wallan.david@example.com

## Licença

Ao contribuir, você concorda que suas contribuições serão licenciadas sob a mesma licença MIT do projeto.
