# Azure Boards Apontamento de Horas (Backend Functions)

Este projeto implementa funções serverless em Node.js para gerenciamento de apontamentos de horas de trabalho integradas ao Azure DevOps. O banco de dados utilizado é PostgreSQL 15, compatível com OpenShift.

---

## 📦 Tecnologias

- Azure Functions (Node.js)
- PostgreSQL 15
- Jest + Supertest (testes automatizados)
- Express (wrapper de teste)
- dotenv
- Azure DevOps REST API

---

## 🚀 Funcionalidades

- `GetAtividadesFunction`: lista atividades cadastradas e ativas
- `InsertApontamentoFunction`: registra apontamentos
- `GetApontamentosFunction`: consulta apontamentos por work item
- `GetContextFunction`: consulta metadados do work item no Azure DevOps

---

## ⚙️ Pré-requisitos

- Node.js (>= 16)
- PostgreSQL 15 (local ou em container)
- Azure Functions Core Tools
- Conta no Azure DevOps com Personal Access Token (PAT)
- pgAdmin (opcional)

---

## 🔐 Variáveis de ambiente

No arquivo `.env`:

```env
DB_USER=apontamentos_user
DB_PASSWORD=sua_senha
DB_SERVER=localhost
DB_NAME=apontamentos_db
DB_PORT=5432
AZURE_DEVOPS_PAT=seu_pat
```

## 🗄️ Estrutura do Banco de Dados

- Schema: `public`
- Tabelas:
  - `Atividades`
  - `Apontamentos`
  - `AprovacoesApontamentos`
  - `LogApontamentos`
- Views:
  - `vw_AtividadesAtivas`
  - `vw_Apontamentos_Detalhes`
  - `vw_Apontamentos_HHMM`

```sql
Para criar o banco, execute:
CREATE DATABASE apontamentos_db
WITH OWNER = postgres
ENCODING = 'UTF8'
LC_COLLATE = 'pt_BR.UTF-8'
LC_CTYPE = 'pt_BR.UTF-8'
TEMPLATE = template0;
```

## 🚀 Como Executar Localmente

1️⃣ instalar dependências

```bash
npm install
```

## 2️⃣ executar as Azure Functions

```bash
func start
```

## 🧪 Testes Automatizados

Rodar Jest + Supertest:

```bash
func test
```

Testes disponíveis:

- GetAtividadesFunction (GET)
- InsertApontamentoFunction (POST)
- GetApontamentosFunction (GET)
  O arquivo **server.js** cria rotas Express para facilitar a integração do Supertest.

## 🔄 Fluxo do Sistema

```mermaid
sequenceDiagram
  participant User as Usuário
  participant React as Frontend React
  participant Functions as Azure Functions
  participant DevOps as Azure DevOps
  participant DB as PostgreSQL

  User->>React: Acessa tela Apontamentos
  React->>Functions: GET GetContextFunction
  Functions->>DevOps: Consulta dados do Work Item (REST API)
  DevOps-->>Functions: Retorna detalhes
  Functions-->>React: Retorna contexto

  React->>Functions: GET GetAtividadesFunction
  Functions->>DB: Consulta vw_AtividadesAtivas
  DB-->>Functions: Retorna atividades
  Functions-->>React: Exibe atividades

  React->>Functions: GET GetApontamentosFunction
  Functions->>DB: Consulta vw_Apontamentos_Detalhes
  DB-->>Functions: Retorna apontamentos
  Functions-->>React: Exibe apontamentos

  React->>Functions: POST InsertApontamentoFunction
  Functions->>DB: Insere apontamento
  DB-->>Functions: Confirma inserção
  Functions-->>React: Confirma sucesso
```

## 📌 Roadmap

- Cobertura de testes para erros e exceções
- Pipeline CI/CD no GitHub Actions
- Autenticação de aprovadores
- Documentação completa do frontend
- Cache Redis (opcional)
- Deploy no OpenShift

## 🤝 Como Contribuir

- Faça um fork
- Crie sua branch (git checkout -b feature/minha-feature)
- Commit
- Abra um Pull Request

## 📝 Licença

Este projeto está sob licença MIT.
Sinta-se livre para adaptá-lo, usar e compartilhar.
#   b e - a p o n t a m e n t o - f u n c  
 