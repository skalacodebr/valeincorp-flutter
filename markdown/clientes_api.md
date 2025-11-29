# Testes de Integração - API Clientes

**Base URL:** `https://valeincorp-main-s7ucsa.laravel.cloud/api`

**Headers Comuns:**
```bash
-H "Accept: application/json" \
-H "Authorization: Bearer <SEU_TOKEN_AQUI>"
```

## Listar Clientes

### Requisição

```bash
curl -X GET "https://valeincorp-main-s7ucsa.laravel.cloud/api/clientes?search=Maria&per_page=5" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer <SEU_TOKEN_AQUI>"
```

### Resposta Esperada (200 OK)

```json
{
  "data": [
    {
      "id": 10,
      "observacoes": "Cliente VIP",
      "equipe_usuarios_id": 2,
      "imobiliarias_id": 1,
      "corretores_id": 1,
      "equipe_usuarios_id": 3,
      "imobiliarias_id": null,
      "corretores_id": null,
      "pessoa": {
        "nome": "Maria Silva",
        "cpf_cnpj": "12345678901",
        "email": "maria@teste.com",
        "telefone": "5511999999999",
        "documento_rg_base64": "<string_base64_rg>",
        "documento_cpf_base64": "<string_base64_cpf>",
        "comprovante_endereco_base64": "<string_base64_endereco>",
        "carteira_trabalho_base64": "<string_base64_ctps>",
        "pis_base64": "<string_base64_pis>",
        "comprovante_renda_base64": "<string_base64_renda>",
        "declaracao_ir_base64": "<string_base64_ir>",
        "extrato_fgts_base64": "<string_base64_fgts>",
      },
      "endereco": {
        "cep": "01001-000",
        "estado": "SP",
        "cidade": "São Paulo",
        "bairro": "Sé",
        "rua": "Praça da Sé",
        "numero": "100",
        "complemento": null
      },
      "foto": {
        "foto_url": "https://example.com/fotos/10.jpg"
      },
      "status": { /* objeto status */ },
      "equipe": { /* objeto equipe */ }
    }
  ],
  "links": { /* paginação */ },
  "meta": { /* paginação */ }
}
```

## Obter Cliente por ID

### Requisição

```bash
curl -X GET "https://valeincorp-main-s7ucsa.laravel.cloud/api/clientes/10" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer <SEU_TOKEN_AQUI>"
```

### Resposta Esperada (200 OK)

```json
{
  "id": 10,
  "observacoes": "Cliente VIP",
  "status_clientes_id": 2,
  "equipe_usuarios_id": 3,
  "imobiliarias_id": null,
  "corretores_id": null,
  "pessoa": { /* dados da pessoa */ },
  "endereco": { /* dados do endereço */ },
  "foto": { /* dados da foto */ },
  "status": { /* objeto status */ },
  "equipe": { /* objeto equipe */ }
}
```

## Criar Cliente

### Requisição

```bash
curl -X POST "https://valeincorp-main-s7ucsa.laravel.cloud/api/clientes" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer <SEU_TOKEN_AQUI>" \
  -H "Content-Type: application/json" \
  -d '  {
    "observacoes": "Teste criação 2",
    "status_clientes_id": 1,
    "equipe_usuarios_id": 2,
    "imobiliarias_id": 1,
    "corretores_id": 1,
    "pessoa": {
      "nome": "João Pereira",
      "cpf_cnpj": "98765432100",
      "email": "joao@teste.com",
      "telefone": "5511987654321",
      "documento_rg_base64": "base64string_rg",
      "documento_cpf_base64": "base64string_cpf",
      "comprovante_endereco_base64": "base64string_endereco",
      "carteira_trabalho_base64": "base64string_ctps",
      "pis_base64": "base64string_pis",
      "comprovante_renda_base64": "base64string_renda",
      "declaracao_ir_base64": "base64string_ir",
      "extrato_fgts_base64": "base64string_fgts"
    },
    "endereco": {
      "cep": "20040-020",
      "estado": "RJ",
      "cidade": "Rio de Janeiro",
      "bairro": "Centro",
      "rua": "Rua Primeiro de Março",
      "numero": "50",
      "complemento": "Sala 1"
    },
    "foto": {
      "foto_url": "https://example.com/fotos/nova.jpg"
    }
  }'
```

### Resposta Esperada (201 Created)

```json
{
  "observacoes": "Teste criação 2",
  "status_clientes_id": 1,
  "equipe_usuarios_id": 2,
  "imobiliarias_id": 1,
  "corretores_id": 1,
  "updated_at": "2025-06-02T17:35:14.000000Z",
  "created_at": "2025-06-02T17:35:14.000000Z",
  "id": 16,
  "pessoa": {
    "id": 16,
    "clientes_id": 16,
    "nome": "João Pereira",
    "cpf_cnpj": "98765432100",
    "email": "joao@teste.com",
    "telefone": "5511987654321",
    "created_at": "2025-06-02T17:35:14.000000Z",
    "updated_at": "2025-06-02T17:35:14.000000Z",
    "documento_rg_base64": "base64string_rg",
    "documento_cpf_base64": "base64string_cpf",
    "comprovante_endereco_base64": "base64string_endereco",
    "carteira_trabalho_base64": "base64string_ctps",
    "pis_base64": "base64string_pis",
    "comprovante_renda_base64": "base64string_renda",
    "declaracao_ir_base64": "base64string_ir",
    "extrato_fgts_base64": "base64string_fgts"
  },
  "endereco": {
    "id": 16,
    "clientes_id": 16,
    "cep": "20040-020",
    "estado": "RJ",
    "cidade": "Rio de Janeiro",
    "bairro": "Centro",
    "rua": "Rua Primeiro de Março",
    "numero": "50",
    "complemento": "Sala 1",
    "created_at": "2025-06-02T17:35:14.000000Z",
    "updated_at": "2025-06-02T17:35:14.000000Z"
  },
  "foto": {
    "id": 13,
    "clientes_id": 16,
    "foto_url": "https://example.com/fotos/nova.jpg",
    "created_at": "2025-06-02T17:35:14.000000Z",
    "updated_at": "2025-06-02T17:35:14.000000Z"
  },
  "status": {
    "id": 1,
    "nome": "Potencial",
    "created_at": "2025-05-27T15:50:48.000439Z",
    "updated_at": "2025-05-27T15:50:48.000439Z"
  },
  "equipe": null
}
```

## Atualizar Cliente

### Requisição

```bash
curl -X PUT "https://valeincorp-main-s7ucsa.laravel.cloud/api/clientes/11" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer <SEU_TOKEN_AQUI>" \
  -H "Content-Type: application/json" \
  -d '{
  "observacoes": "Teste atualização",
  "status_clientes_id": 2,
  "equipe_usuarios_id": 3,
  "pessoa": {
    "nome": "João Pereira Atualizado",
    "cpf_cnpj": "98765432100",
    "email": "joao.atualizado@teste.com",
    "telefone": "5511987654321",
    "documento_rg_base64": "base64_rg",
    "documento_cpf_base64": "base64_cpf",
    "comprovante_endereco_base64": "base64_endereco",
    "carteira_trabalho_base64": "base64_ctps",
    "pis_base64": "base64_pis",
    "comprovante_renda_base64": "base64_renda",
    "declaracao_ir_base64": "base64_ir",
    "extrato_fgts_base64": "base64_fgts"
  },
  "endereco": {
    "cep": "20040-020",
    "estado": "RJ",
    "cidade": "Rio de Janeiro",
    "bairro": "Centro",
    "rua": "Rua Primeiro de Março",
    "numero": "50",
    "complemento": "Apto 2"
  },
  "foto": {
    "foto_url": "https://example.com/fotos/atualizada.jpg"
  }
}
'
```

### Resposta Esperada (200 OK)

```json
{
  "id": 11,
  "observacoes": "Teste atualização",
  "status_clientes_id": 2,
  "equipe_usuarios_id": 3,
  "imobiliarias_id": 1,
  "corretores_id": 1,
  "created_at": "2025-05-28T14:15:19.000000Z",
  "updated_at": "2025-06-02T17:50:47.000000Z",
  "pessoa": {
    "id": 11,
    "clientes_id": 11,
    "nome": "João Pereira Atualizado",
    "cpf_cnpj": "98765432100",
    "email": "joao.atualizado@teste.com",
    "telefone": "5511987654321",
    "created_at": "2025-05-28T14:15:19.000000Z",
    "updated_at": "2025-06-02T17:50:47.000000Z",
    "documento_rg_base64": "base64_rg",
    "documento_cpf_base64": "base64_cpf",
    "comprovante_endereco_base64": "base64_endereco",
    "carteira_trabalho_base64": "base64_ctps",
    "pis_base64": "base64_pis",
    "comprovante_renda_base64": "base64_renda",
    "declaracao_ir_base64": "base64_ir",
    "extrato_fgts_base64": "base64_fgts"
  },
  "endereco": {
    "id": 11,
    "clientes_id": 11,
    "cep": "20040-020",
    "estado": "RJ",
    "cidade": "Rio de Janeiro",
    "bairro": "Centro",
    "rua": "Rua Primeiro de Março",
    "numero": "50",
    "complemento": "Apto 2",
    "created_at": "2025-05-28T14:15:19.000000Z",
    "updated_at": "2025-06-02T17:50:47.000000Z"
  },
  "foto": {
    "id": 9,
    "clientes_id": 11,
    "foto_url": "https://example.com/fotos/atualizada.jpg",
    "created_at": "2025-05-28T14:15:19.000000Z",
    "updated_at": "2025-06-02T17:50:47.000000Z"
  },
  "status": {
    "id": 2,
    "nome": "Contato Feito",
    "created_at": "2025-05-27T15:50:48.000439Z",
    "updated_at": "2025-05-27T15:50:48.000439Z"
  },
  "equipe": null
}
```

## Excluir Cliente

### Requisição

```bash
curl -X DELETE "https://valeincorp-main-s7ucsa.laravel.cloud/api/clientes/11" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer <SEU_TOKEN_AQUI>"
```

### Resposta Esperada (200 OK)

```json
{ "message": "Cliente excluído com sucesso." }
```
