# Testes de Integração - API Unidades

**Base URL:** `https://valeincorp-main-s7ucsa.laravel.cloud/api`

**Headers Comuns:**
```bash
-H "Accept: application/json" \
-H "Authorization: Bearer <SEU_TOKEN_AQUI>"
```

---

## Listar Unidades de Torre

### Requisição

```bash
curl -X GET "https://valeincorp-main-s7ucsa.laravel.cloud/api/torres/3/unidades?per_page=5" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer <SEU_TOKEN_AQUI>"
```

### Resposta Esperada (200 OK)

```json
{
  "data": [
    {
      "id": 45,
      "empreendimentos_tores_id": 3,
      "numero_andar_apartamento": 10,
      "numero_apartamento": 1001,
      "tamanho_unidade_metros_quadrados": 75.5,
      "valor": 500000.00,
      "numero_quartos": 2,
      "numero_suites": 1,
      "numero_banheiros": 2,
      "status_unidades_id": 1,
      "created_at": "2025-05-20T08:00:00Z",
      "updated_at": "2025-05-20T08:00:00Z"
    }
  ],
  "links": { /* paginação */ },
  "meta": { /* paginação */ }
}
```

---

## Criar Unidade

### Requisição

```bash
curl -X POST "https://valeincorp-main-s7ucsa.laravel.cloud/api/torres/3/unidades" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer <SEU_TOKEN_AQUI>" \
  -H "Content-Type: application/json" \
  -d '{
    "numero_andar_apartamento": 12,
    "numero_apartamento": 1203,
    "tamanho_unidade_metros_quadrados": 80.0,
    "valor": 550000.00,
    "numero_quartos": 3,
    "numero_suites": 2,
    "numero_banheiros": 3,
    "status_unidades_id": 1
  }'
```

### Resposta Esperada (201 Created)

```json
{
  "id": 46,
  "empreendimentos_tores_id": 3,
  "numero_andar_apartamento": 12,
  "numero_apartamento": 1203,
  "tamanho_unidade_metros_quadrados": 80.0,
  "valor": 550000.00,
  "numero_quartos": 3,
  "numero_suites": 2,
  "numero_banheiros": 3,
  "status_unidades_id": 1,
  "created_at": "2025-05-26T14:30:00Z",
  "updated_at": "2025-05-26T14:30:00Z"
}
```

---

## Atualizar Unidade

### Requisição

```bash
curl -X PUT "https://valeincorp-main-s7ucsa.laravel.cloud/api/unidades/46" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer <SEU_TOKEN_AQUI>" \
  -H "Content-Type: application/json" \
  -d '{
    "valor": 560000.00,
    "status_unidades_id": 2
  }'
```

### Resposta Esperada (200 OK)

```json
{
  "id": 46,
  "empreendimentos_tores_id": 3,
  "numero_andar_apartamento": 12,
  "numero_apartamento": 1203,
  "tamanho_unidade_metros_quadrados": 80.0,
  "valor": 560000.00,
  "numero_quartos": 3,
  "numero_suites": 2,
  "numero_banheiros": 3,
  "status_unidades_id": 2,
  "created_at": "2025-05-26T14:30:00Z",
  "updated_at": "2025-05-27T10:00:00Z"
}
```

---

## Excluir Unidade

### Requisição

```bash
curl -X DELETE "https://valeincorp-main-s7ucsa.laravel.cloud/api/unidades/46" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer <SEU_TOKEN_AQUI>"
```

### Resposta Esperada (200 OK)

```json
{ "message": "Unidade removida com sucesso." }
```

---

## Listar Vagas de Garagem de Torre

### Requisição

```bash
curl -X GET "https://valeincorp-main-s7ucsa.laravel.cloud/api/torres/3/vagas-garagem" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer <SEU_TOKEN_AQUI>"
```

### Resposta Esperada (200 OK)

```json
[
  {
    "id": 101,
    "empreendimentos_tores_id": 3,
    "numero_vaga": "GAR-001",
    "created_at": "2025-05-20T09:00:00Z",
    "updated_at": "2025-05-20T09:00:00Z"
  }
]
```

---

## Criar Vaga de Garagem

### Requisição

```bash
curl -X POST "https://valeincorp-main-s7ucsa.laravel.cloud/api/torres/3/vagas-garagem" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer <SEU_TOKEN_AQUI>" \
  -H "Content-Type: application/json" \
  -d '{ "numero_vaga": "GAR-050" }'
```

### Resposta Esperada (201 Created)

```json
{
  "id": 102,
  "empreendimentos_tores_id": 3,
  "numero_vaga": "GAR-050",
  "created_at": "2025-05-26T15:00:00Z",
  "updated_at": "2025-05-26T15:00:00Z"
}
```

---

## Excluir Vaga de Garagem

### Requisição

```bash
curl -X DELETE "https://valeincorp-main-s7ucsa.laravel.cloud/api/vagas-garagem/102" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer <SEU_TOKEN_AQUI>"
```

### Resposta Esperada (200 OK)

```json
{ "message": "Vaga de garagem removida com sucesso." }
```

---

## Listar Fotos das Unidades de Torre

### Requisição

```bash
curl -X GET "https://valeincorp-main-s7ucsa.laravel.cloud/api/torres/3/fotos-unidade" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer <SEU_TOKEN_AQUI>"
```

### Resposta Esperada (200 OK)

```json
[
  {
    "id": 201,
    "empreendimentos_tores_id": 3,
    "fotos_url": "https://example.com/fotos/201.jpg",
    "created_at": "2025-05-20T09:30:00Z",
    "updated_at": "2025-05-20T09:30:00Z"
  }
]
```

---

## Criar Foto de Unidade

### Requisição

```bash
curl -X POST "https://valeincorp-main-s7ucsa.laravel.cloud/api/torres/3/fotos-unidade" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer <SEU_TOKEN_AQUI>" \
  -H "Content-Type: application/json" \
  -d '{ "fotos_url": "https://example.com/fotos/nova_unidade.jpg" }'
```

### Resposta Esperada (201 Created)

```json
{
  "id": 202,
  "empreendimentos_tores_id": 3,
  "fotos_url": "https://example.com/fotos/nova_unidade.jpg",
  "created_at": "2025-05-26T15:30:00Z",
  "updated_at": "2025-05-26T15:30:00Z"
}
```

---

## Excluir Foto de Unidade

### Requisição

```bash
curl -X DELETE "https://valeincorp-main-s7ucsa.laravel.cloud/api/fotos-unidade/202" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer <SEU_TOKEN_AQUI>"
```

### Resposta Esperada (200 OK)

```json
{ "message": "Foto removida com sucesso." }
```
