# Testes de API - CRUD de Parcelas

Base URL: https://valeincorp-main-s7ucsa.laravel.cloud/api/

Todos os testes abaixo utilizam token de autenticação e aceitam JSON.

### Headers comuns

```
-H "Accept: application/json" \
-H "Authorization: Bearer SEU_TOKEN_AQUI" \
```

---

## Listar Parcelas

**Requisição:**

```
curl -X GET "https://valeincorp-main-s7ucsa.laravel.cloud/api/parcelas" \
-H "Accept: application/json" \
-H "Authorization: Bearer SEU_TOKEN_AQUI"
```

**Resposta de Sucesso (200):**

```json
[
  {
    "id": 1,
    "negociacao": {
      "id": 123,
      "outros_campos": "..."
    },
    "negociacoes_id": 123,
    "valor_parcela": "1000.00",
    "data_limite_pagamento": "2025-06-01",
    "status_pagamentos_parcelas_id": 2,
    "created_at": "2025-05-20T12:00:00Z",
    "updated_at": "2025-05-20T12:00:00Z"
  }
]
```

## Criar Parcela

**Requisição:**

```
curl -X POST "https://valeincorp-main-s7ucsa.laravel.cloud/api/parcelas" \
-H "Accept: application/json" \
-H "Authorization: Bearer SEU_TOKEN_AQUI" \
-H "Content-Type: application/json" \
-d '{
  "negociacoes_id": 123,
  "valor_parcela": 1500.00,
  "data_limite_pagamento": "2025-07-01",
  "status_pagamentos_parcelas_id": 1
}'
```

**Resposta de Sucesso (201):**

```json
{
  "id": 3,
  "negociacoes_id": 123,
  "valor_parcela": "1500.00",
  "data_limite_pagamento": "2025-07-01",
  "status_pagamentos_parcelas_id": 1,
  "created_at": "2025-05-28T11:00:00Z",
  "updated_at": "2025-05-28T11:00:00Z"
}
```

## Atualizar Parcela

**Requisição:**

```
curl -X PUT "https://valeincorp-main-s7ucsa.laravel.cloud/api/parcelas/3" \
-H "Accept: application/json" \
-H "Authorization: Bearer SEU_TOKEN_AQUI" \
-H "Content-Type: application/json" \
-d '{
  "valor_parcela": 1600.00,
  "status_pagamentos_parcelas_id": 2
}'
```

**Resposta de Sucesso (200):**

```json
{
  "id": 3,
  "negociacoes_id": 123,
  "valor_parcela": "1600.00",
  "data_limite_pagamento": "2025-07-01",
  "status_pagamentos_parcelas_id": 2,
  "created_at": "2025-05-28T11:00:00Z",
  "updated_at": "2025-05-28T12:00:00Z"
}
```

## Deletar Parcela

**Requisição:**

```
curl -X DELETE "https://valeincorp-main-s7ucsa.laravel.cloud/api/parcelas/3" \
-H "Accept: application/json" \
-H "Authorization: Bearer SEU_TOKEN_AQUI"
```

**Resposta de Sucesso (200):**

```json
{
  "message": "Parcela removida com sucesso."
}
```
