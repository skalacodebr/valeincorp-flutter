# API de ValeIncorp - Testes com cURL

Este documento contém todos os endpoints da API com exemplos de requisições cURL e respostas esperadas.

## Autenticação

### Login
Realiza login e obtém token de autenticação.

```bash
curl -X POST http://localhost:8000/api/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "usuario@exemplo.com",
    "senha": "senha123"
  }'
```

**Resposta esperada:**
```json
{
  "access_token": "1|LaravelSanctumAuthToken...",
  "token_type": "Bearer",
  "usuario": {
    "id": 1,
    "nome": "Nome do Usuário",
    "email": "usuario@exemplo.com",
    "cargo": {
      "id": 1,
      "nome": "Administrador"
    },
    "permissoes": []
  }
}
```

### Logout
Realiza logout e invalida o token.

```bash
curl -X POST http://localhost:8000/api/logout \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json"
```

**Resposta esperada:**
```json
{
  "message": "Logout realizado com sucesso"
}
```

### Obter Usuário Autenticado
```bash
curl -X GET http://localhost:8000/api/me \
  -H "Authorization: Bearer {token}"
```

**Resposta esperada:**
```json
{
  "id": 1,
  "nome": "Nome do Usuário",
  "email": "usuario@exemplo.com",
  "telefone": "11999999999",
  "cargo": {
    "id": 1,
    "nome": "Administrador"
  },
  "permissoes": []
}
```

### Atualizar Perfil do Usuário
```bash
curl -X PUT http://localhost:8000/api/me/update \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{
    "nome": "Novo Nome",
    "email": "novoemail@exemplo.com",
    "telefone": "11888888888",
    "senha": "novaSenha123",
    "senha_confirmation": "novaSenha123"
  }'
```

**Resposta esperada:**
```json
{
  "message": "Perfil atualizado com sucesso",
  "usuario": {
    "id": 1,
    "nome": "Novo Nome",
    "email": "novoemail@exemplo.com",
    "telefone": "11888888888",
    "cargo": {...},
    "permissoes": []
  }
}
```

## Equipe de Usuários

### Listar Usuários da Equipe
```bash
curl -X GET "http://localhost:8000/api/equipe-usuarios?search=João&per_page=20" \
  -H "Authorization: Bearer {token}"
```

**Resposta esperada:**
```json
{
  "current_page": 1,
  "data": [
    {
      "id": 1,
      "nome": "João Silva",
      "email": "joao@exemplo.com",
      "telefone": "11999999999",
      "data_entrada": "2024-01-01",
      "status": true,
      "cargo": {
        "id": 1,
        "nome": "Vendedor"
      },
      "permissoes": []
    }
  ],
  "total": 1,
  "per_page": 20
}
```

### Criar Usuário da Equipe
```bash
curl -X POST http://localhost:8000/api/equipe-usuarios \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{
    "nome": "Maria Santos",
    "email": "maria@exemplo.com",
    "telefone": "11888888888",
    "senha": "senha123",
    "senha_confirmation": "senha123",
    "data_entrada": "2024-01-15",
    "cargos_id": 2,
    "status": true,
    "permissoes": [1, 2, 3]
  }'
```

**Resposta esperada:**
```json
{
  "id": 2,
  "nome": "Maria Santos",
  "email": "maria@exemplo.com",
  "telefone": "11888888888",
  "data_entrada": "2024-01-15",
  "status": true,
  "cargo": {
    "id": 2,
    "nome": "Corretor"
  },
  "permissoes": [
    {"id": 1, "nome": "Visualizar Vendas"},
    {"id": 2, "nome": "Criar Vendas"},
    {"id": 3, "nome": "Editar Vendas"}
  ]
}
```

### Atualizar Usuário da Equipe
```bash
curl -X PUT http://localhost:8000/api/equipe-usuarios/2 \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{
    "nome": "Maria Santos Silva",
    "email": "maria.silva@exemplo.com",
    "telefone": "11777777777",
    "cargos_id": 3,
    "status": true,
    "permissoes": [1, 2, 3, 4]
  }'
```

### Deletar Usuário da Equipe
```bash
curl -X DELETE http://localhost:8000/api/equipe-usuarios/2 \
  -H "Authorization: Bearer {token}"
```

**Resposta esperada:**
```json
{
  "message": "Usuário removido com sucesso."
}
```

## Corretores

### Listar Todos os Corretores (Internos e Externos)
```bash
curl -X GET http://localhost:8000/api/corretores-todos
```

**Resposta esperada:**
```json
[
  {
    "id": 1,
    "nome": "Carlos Corretor",
    "tipo": "corretor"
  },
  {
    "id": 1,
    "nome": "Ana Vendedora",
    "tipo": "corretor interno"
  }
]
```

### Listar Corretores
```bash
curl -X GET http://localhost:8000/api/corretores
```

**Resposta esperada:**
```json
{
  "current_page": 1,
  "data": [
    {
      "id": 1,
      "nome": "Carlos Corretor",
      "cpf": "123.456.789-00",
      "email": "carlos@imobiliaria.com",
      "telefone": "11999999999",
      "creci": "12345-F",
      "ativo": true,
      "imobiliaria": {
        "id": 1,
        "nome": "Imobiliária XYZ"
      }
    }
  ],
  "total": 1,
  "per_page": 10
}
```

### Criar Corretor
```bash
curl -X POST http://localhost:8000/api/corretores \
  -H "Content-Type: application/json" \
  -d '{
    "imobiliarias_id": 1,
    "nome": "Pedro Vendedor",
    "cpf": "987.654.321-00",
    "email": "pedro@imobiliaria.com",
    "telefone": "11888888888",
    "senha": "senha123",
    "creci": "54321-F",
    "ativo": true
  }'
```

### Atualizar Corretor
```bash
curl -X PUT http://localhost:8000/api/corretores/1 \
  -H "Content-Type: application/json" \
  -d '{
    "nome": "Carlos Corretor Silva",
    "email": "carlos.silva@imobiliaria.com",
    "telefone": "11777777777",
    "ativo": true
  }'
```

### Deletar Corretor
```bash
curl -X DELETE http://localhost:8000/api/corretores/1
```

## Imobiliárias

### Listar Imobiliárias
```bash
curl -X GET http://localhost:8000/api/imobiliarias
```

### Criar Imobiliária
```bash
curl -X POST http://localhost:8000/api/imobiliarias \
  -H "Content-Type: application/json" \
  -d '{
    "nome": "Imobiliária ABC",
    "cnpj": "12.345.678/0001-90",
    "email": "contato@imobiliariaabc.com",
    "telefone": "1133333333",
    "creci": "12345-J"
  }'
```

### Atualizar Imobiliária
```bash
curl -X PUT http://localhost:8000/api/imobiliarias/1 \
  -H "Content-Type: application/json" \
  -d '{
    "nome": "Imobiliária ABC Ltda",
    "email": "novo@imobiliariaabc.com"
  }'
```

### Deletar Imobiliária
```bash
curl -X DELETE http://localhost:8000/api/imobiliarias/1
```

## Clientes

### Listar Clientes
```bash
curl -X GET "http://localhost:8000/api/clientes?search=João&per_page=20" \
  -H "Authorization: Bearer {token}"
```

**Resposta esperada:**
```json
{
  "current_page": 1,
  "data": [
    {
      "id": 1,
      "observacoes": "Cliente preferencial",
      "status_clientes_id": 1,
      "equipe_usuarios_id": 1,
      "pessoa": {
        "nome": "João da Silva",
        "cpf_cnpj": "123.456.789-00",
        "email": "joao@email.com",
        "telefone": "11999999999"
      },
      "endereco": {
        "cep": "01310-100",
        "estado": "SP",
        "cidade": "São Paulo",
        "bairro": "Bela Vista",
        "rua": "Av. Paulista",
        "numero": "1000",
        "complemento": "Apto 101"
      },
      "status": {
        "id": 1,
        "nome": "Ativo"
      },
      "equipe": {
        "id": 1,
        "nome": "Vendedor João"
      }
    }
  ],
  "total": 1,
  "per_page": 20
}
```

### Criar Cliente
```bash
curl -X POST http://localhost:8000/api/clientes \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{
    "observacoes": "Novo cliente indicado",
    "status_clientes_id": 1,
    "equipe_usuarios_id": 2,
    "pessoa": {
      "nome": "Maria Oliveira",
      "cpf_cnpj": "987.654.321-00",
      "email": "maria@email.com",
      "telefone": "11888888888"
    },
    "endereco": {
      "cep": "04567-000",
      "estado": "SP",
      "cidade": "São Paulo",
      "bairro": "Vila Olímpia",
      "rua": "Rua Funchal",
      "numero": "500",
      "complemento": "Casa"
    }
  }'
```

### Atualizar Cliente
```bash
curl -X PUT http://localhost:8000/api/clientes/1 \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{
    "observacoes": "Cliente VIP - Atualizado",
    "status_clientes_id": 2,
    "pessoa": {
      "nome": "João da Silva Santos",
      "email": "joao.santos@email.com",
      "telefone": "11777777777"
    },
    "endereco": {
      "numero": "1500",
      "complemento": "Cobertura"
    }
  }'
```

### Deletar Cliente
```bash
curl -X DELETE http://localhost:8000/api/clientes/1 \
  -H "Authorization: Bearer {token}"
```

## Empreendimentos

### Listar Empreendimentos
```bash
curl -X GET "http://localhost:8000/api/empreendimentos?search=Residencial&per_page=10" \
  -H "Authorization: Bearer {token}"
```

**Resposta esperada:**
```json
{
  "current_page": 1,
  "data": [
    {
      "id": 1,
      "nome": "Residencial Parque Verde",
      "tipo_empreendimento_id": 1,
      "tipo_unidades_id": 1,
      "numero_total_unidade": 120,
      "tamanho_total_unidade_metros_quadrados": 15000,
      "area_lazer": true,
      "observacoes": "Empreendimento com vista para o parque",
      "empreendimentos_status_id": 1,
      "torres": [
        {
          "id": 1,
          "nome": "Torre A",
          "numero_andares": 20,
          "quantidade_unidades_andar": 6,
          "excessoes": []
        }
      ],
      "areasLazer": [
        {
          "id": 1,
          "tipo_area_lazer_id": 1
        }
      ],
      "endereco": {
        "cep": "05650-000",
        "estado": "SP",
        "cidade": "São Paulo",
        "bairro": "Morumbi",
        "rua": "Rua do Parque",
        "numero": "1000"
      }
    }
  ],
  "total": 1,
  "per_page": 10
}
```

### Criar Empreendimento
```bash
curl -X POST http://localhost:8000/api/empreendimentos \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: multipart/form-data" \
  -F "nome=Condomínio Solar" \
  -F "tipo_empreendimento_id=1" \
  -F "tipo_unidades_id=2" \
  -F "numero_total_unidade=80" \
  -F "tamanho_total_unidade_metros_quadrados=10000" \
  -F "area_lazer=true" \
  -F "observacoes=Próximo ao metrô" \
  -F "empreendimentos_status_id=1" \
  -F "memorial_descritivo=@/path/to/memorial.pdf" \
  -F "catalogo_pdf=@/path/to/catalogo.pdf"
```

### Atualizar Empreendimento
```bash
curl -X PUT http://localhost:8000/api/empreendimentos/1 \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: multipart/form-data" \
  -F "nome=Condomínio Solar Premium" \
  -F "numero_total_unidade=100" \
  -F "observacoes=Próximo ao metrô e shopping"
```

### Deletar Empreendimento
```bash
curl -X DELETE http://localhost:8000/api/empreendimentos/1 \
  -H "Authorization: Bearer {token}"
```

### Adicionar Torre ao Empreendimento
```bash
curl -X POST http://localhost:8000/api/empreendimentos/1/torres \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{
    "nome": "Torre B",
    "numero_andares": 25,
    "quantidade_unidades_andar": 4
  }'
```

### Adicionar Área de Lazer
```bash
curl -X POST http://localhost:8000/api/empreendimentos/1/areas-lazer \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{
    "tipo_area_lazer_id": 2
  }'
```

### Adicionar/Atualizar Endereço
```bash
curl -X POST http://localhost:8000/api/empreendimentos/1/endereco \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{
    "cep": "05650-000",
    "estado": "SP",
    "cidade": "São Paulo",
    "bairro": "Morumbi",
    "rua": "Rua Nova",
    "numero": "2000",
    "complemento": "Esquina"
  }'
```

## Unidades

### Listar Unidades de uma Torre
```bash
curl -X GET "http://localhost:8000/api/torres/1/unidades?per_page=20" \
  -H "Authorization: Bearer {token}"
```

**Resposta esperada:**
```json
{
  "current_page": 1,
  "data": [
    {
      "id": 1,
      "empreendimentos_tores_id": 1,
      "numero_andar_apartamento": 10,
      "numero_apartamento": 1001,
      "tamanho_unidade_metros_quadrados": 120.5,
      "valor": 850000.00,
      "numero_quartos": 3,
      "numero_suites": 1,
      "numero_banheiros": 2,
      "status_unidades_id": 1
    }
  ],
  "total": 1,
  "per_page": 20
}
```

### Criar Unidade
```bash
curl -X POST http://localhost:8000/api/torres/1/unidades \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{
    "numero_andar_apartamento": 15,
    "numero_apartamento": 1502,
    "tamanho_unidade_metros_quadrados": 95.5,
    "valor": 650000.00,
    "numero_quartos": 2,
    "numero_suites": 1,
    "numero_banheiros": 2,
    "status_unidades_id": 1
  }'
```

### Atualizar Unidade
```bash
curl -X PUT http://localhost:8000/api/unidades/1 \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{
    "valor": 900000.00,
    "status_unidades_id": 2
  }'
```

### Deletar Unidade
```bash
curl -X DELETE http://localhost:8000/api/unidades/1 \
  -H "Authorization: Bearer {token}"
```

### Listar Vagas de Garagem
```bash
curl -X GET http://localhost:8000/api/torres/1/vagas-garagem \
  -H "Authorization: Bearer {token}"
```

### Criar Vaga de Garagem
```bash
curl -X POST http://localhost:8000/api/torres/1/vagas-garagem \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{
    "numero_vaga": "G1-015",
    "cobertura": "Coberto",
    "tipo_vaga": "Simples",
    "area_total": 12.5,
    "pavimento": "G1",
    "observacoes": "Próximo ao elevador",
    "status": "Disponível"
  }'
```

## Negociações

### Listar Negociações
```bash
curl -X GET "http://localhost:8000/api/negociacoes?per_page=20"
```

**Resposta esperada:**
```json
{
  "current_page": 1,
  "data": [
    {
      "id": 1,
      "empreendimentos_id": 1,
      "empreendimentos_unidades_id": 1,
      "clientes_id": 1,
      "valor_contrato": 850000.00,
      "numero_contrato": "CTR-2024-001",
      "data": "2024-01-15",
      "modalidades_vendas_id": 1,
      "negociacoes_status_id": 1,
      "empreendimento": {
        "id": 1,
        "nome": "Residencial Parque Verde"
      },
      "unidade": {
        "id": 1,
        "numero_apartamento": 1001
      },
      "cliente": {
        "id": 1,
        "pessoa": {
          "nome": "João da Silva"
        }
      },
      "status": {
        "id": 1,
        "nome": "Em Andamento"
      }
    }
  ],
  "total": 1,
  "per_page": 20
}
```

### Criar Negociação
```bash
curl -X POST http://localhost:8000/api/negociacoes \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{
    "empreendimentos_id": 1,
    "empreendimentos_unidades_id": 1,
    "clientes_id": 1,
    "equipe_usuarios_id": 1,
    "corretores_id": 1,
    "valor_contrato": 850000.00,
    "numero_contrato": "CTR-2024-002",
    "data": "2024-01-20",
    "modalidades_vendas_id": 1,
    "situacoes_vendas_id": 1,
    "valor_entrada_ato": 85000.00,
    "quantidade_parcelas_disponiveis_id": 1,
    "valor_financiamento": 595000.00,
    "nome_banco": "Banco do Brasil",
    "percentual_comissao": 5.0,
    "negociacoes_status_id": 1,
    "observacoes": "Cliente pré-aprovado no banco"
  }'
```

### Atualizar Negociação
```bash
curl -X PUT http://localhost:8000/api/negociacoes/1 \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{
    "negociacoes_status_id": 2,
    "numero_contrato": "CTR-2024-002-REV1",
    "observacoes": "Contrato revisado e aprovado"
  }'
```

### Deletar Negociação
```bash
curl -X DELETE http://localhost:8000/api/negociacoes/1 \
  -H "Authorization: Bearer {token}"
```

## Pagamentos

### Listar Pagamentos
```bash
curl -X GET http://localhost:8000/api/pagamentos \
  -H "Authorization: Bearer {token}"
```

### Criar Pagamento
```bash
curl -X POST http://localhost:8000/api/pagamentos \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{
    "negociacoes_id": 1,
    "valor_total_pago": 85000.00,
    "formas_pagamento_id": 1
  }'
```

### Atualizar Pagamento
```bash
curl -X PUT http://localhost:8000/api/pagamentos/1 \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{
    "valor_total_pago": 90000.00
  }'
```

### Deletar Pagamento
```bash
curl -X DELETE http://localhost:8000/api/pagamentos/1 \
  -H "Authorization: Bearer {token}"
```

## Parcelas

### Listar Parcelas
```bash
curl -X GET http://localhost:8000/api/parcelas \
  -H "Authorization: Bearer {token}"
```

### Criar Parcela
```bash
curl -X POST http://localhost:8000/api/parcelas \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{
    "negociacoes_id": 1,
    "valor_parcela": 5000.00,
    "data_limite_pagamento": "2024-02-15",
    "status_pagamentos_parcelas_id": 1
  }'
```

### Atualizar Parcela
```bash
curl -X PUT http://localhost:8000/api/parcelas/1 \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{
    "status_pagamentos_parcelas_id": 2
  }'
```

### Deletar Parcela
```bash
curl -X DELETE http://localhost:8000/api/parcelas/1 \
  -H "Authorization: Bearer {token}"
```

## Leads

### Listar Leads
```bash
curl -X GET "http://localhost:8000/api/leads?search=Maria&per_page=20" \
  -H "Authorization: Bearer {token}"
```

**Resposta esperada:**
```json
{
  "current_page": 1,
  "data": [
    {
      "id": 1,
      "nome": "Maria Silva",
      "telefone": "11999999999",
      "email": "maria@email.com",
      "status_leads": 1,
      "origens_leads_id": 1,
      "data_entrada": "2024-01-15",
      "observacoes": "Interessada em 2 quartos",
      "origem": {
        "id": 1,
        "nome": "Site"
      }
    }
  ],
  "total": 1,
  "per_page": 20
}
```

### Criar Lead
```bash
curl -X POST http://localhost:8000/api/leads \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{
    "nome": "Carlos Oliveira",
    "telefone": "11888888888",
    "email": "carlos@email.com",
    "status_leads": 1,
    "origens_leads_id": 2,
    "observacoes": "Indicação de cliente"
  }'
```

### Criar Lead via Anúncio (Sem Autenticação)
```bash
curl -X POST http://localhost:8000/api/leads/anuncio \
  -H "Content-Type: application/json" \
  -d '{
    "nome": "Ana Costa",
    "telefone": "11777777777",
    "email": "ana@email.com",
    "origens_leads_id": 3,
    "observacoes": "Via Facebook Ads"
  }'
```

### Atualizar Lead
```bash
curl -X PUT http://localhost:8000/api/leads/1 \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{
    "status_leads": 2,
    "observacoes": "Em negociação - agendada visita"
  }'
```

### Deletar Lead
```bash
curl -X DELETE http://localhost:8000/api/leads/1 \
  -H "Authorization: Bearer {token}"
```

## Upload de Arquivos

### Upload de Arquivo Único
```bash
curl -X POST http://localhost:8000/api/upload/file \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: multipart/form-data" \
  -F "file=@/path/to/document.pdf" \
  -F "folder=documentos"
```

**Resposta esperada:**
```json
{
  "success": true,
  "file_path": "documentos/document_123456.pdf",
  "file_url": "http://localhost:8000/storage/documentos/document_123456.pdf"
}
```

### Upload de Múltiplos Arquivos
```bash
curl -X POST http://localhost:8000/api/upload/files \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: multipart/form-data" \
  -F "files[]=@/path/to/doc1.pdf" \
  -F "files[]=@/path/to/doc2.pdf" \
  -F "folder=documentos"
```

**Resposta esperada:**
```json
{
  "success": true,
  "files": [
    {
      "file_path": "documentos/doc1_123456.pdf",
      "file_url": "http://localhost:8000/storage/documentos/doc1_123456.pdf"
    },
    {
      "file_path": "documentos/doc2_123457.pdf",
      "file_url": "http://localhost:8000/storage/documentos/doc2_123457.pdf"
    }
  ]
}
```

### Deletar Arquivo
```bash
curl -X DELETE http://localhost:8000/api/upload/file \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{
    "file_path": "documentos/document_123456.pdf"
  }'
```

## Tabelas Auxiliares

### Listar Cargos
```bash
curl -X GET http://localhost:8000/api/cargos \
  -H "Authorization: Bearer {token}"
```

**Resposta esperada:**
```json
[
  {
    "id": 1,
    "nome": "Administrador"
  },
  {
    "id": 2,
    "nome": "Vendedor"
  },
  {
    "id": 3,
    "nome": "Corretor"
  }
]
```

### Listar Permissões
```bash
curl -X GET http://localhost:8000/api/permissoes \
  -H "Authorization: Bearer {token}"
```

### Listar Tipos de Empreendimento
```bash
curl -X GET http://localhost:8000/api/tipo-empreendimentos \
  -H "Authorization: Bearer {token}"
```

### Listar Tipos de Unidade
```bash
curl -X GET http://localhost:8000/api/tipo-unidades \
  -H "Authorization: Bearer {token}"
```

### Listar Status de Unidades
```bash
curl -X GET http://localhost:8000/api/status-unidades \
  -H "Authorization: Bearer {token}"
```

### Listar Tipos de Área de Lazer
```bash
curl -X GET http://localhost:8000/api/tipo-areas-lazer \
  -H "Authorization: Bearer {token}"
```

### Listar Status de Empreendimentos
```bash
curl -X GET http://localhost:8000/api/empreendimentos-status \
  -H "Authorization: Bearer {token}"
```

### Listar Status de Clientes
```bash
curl -X GET http://localhost:8000/api/status-clientes \
  -H "Authorization: Bearer {token}"
```

### Listar Modalidades de Venda
```bash
curl -X GET http://localhost:8000/api/modalidades-vendas \
  -H "Authorization: Bearer {token}"
```

### Listar Situações de Venda
```bash
curl -X GET http://localhost:8000/api/situacoes-vendas \
  -H "Authorization: Bearer {token}"
```

### Listar Conformidades de Venda
```bash
curl -X GET http://localhost:8000/api/conformidades-vendas \
  -H "Authorization: Bearer {token}"
```

### Listar Registros IBTI
```bash
curl -X GET http://localhost:8000/api/ibti-registro-vendas \
  -H "Authorization: Bearer {token}"
```

### Listar Quantidade de Parcelas Disponíveis
```bash
curl -X GET http://localhost:8000/api/quantidade-parcelas-disponiveis \
  -H "Authorization: Bearer {token}"
```

### Listar Status de Negociações
```bash
curl -X GET http://localhost:8000/api/negociacoes-status \
  -H "Authorization: Bearer {token}"
```

### Listar Status de Pagamentos de Parcelas
```bash
curl -X GET http://localhost:8000/api/status-pagamentos-parcelas \
  -H "Authorization: Bearer {token}"
```

### Listar Formas de Pagamento
```bash
curl -X GET http://localhost:8000/api/formas-pagamento \
  -H "Authorization: Bearer {token}"
```

### Listar Status de Leads
```bash
curl -X GET http://localhost:8000/api/status-leads \
  -H "Authorization: Bearer {token}"
```

## Observações Importantes

1. **Autenticação**: A maioria dos endpoints requer autenticação. Use o token obtido no login com o header `Authorization: Bearer {token}`.

2. **Paginação**: Muitos endpoints de listagem suportam paginação com o parâmetro `per_page`. O padrão é 10000 registros.

3. **Busca**: Endpoints de listagem geralmente suportam o parâmetro `search` para filtrar resultados.

4. **Validação**: Todos os endpoints possuem validação de dados. Em caso de erro, a resposta conterá os detalhes dos campos inválidos.

5. **Respostas de Erro**: 
   - 401: Não autorizado (token inválido ou expirado)
   - 404: Recurso não encontrado
   - 422: Erro de validação
   - 500: Erro interno do servidor

6. **Upload de Arquivos**: 
   - Para empreendimentos, é possível fazer upload via multipart/form-data ou base64
   - Para outros uploads, use os endpoints específicos de upload

7. **Soft Deletes**: Alguns recursos podem usar soft delete, mantendo os registros no banco mas marcados como excluídos.