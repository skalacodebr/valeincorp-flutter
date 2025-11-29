# Testes de CRUD para Leads

Todas as requisições devem incluir os headers:
```
-H "Accept: application/json" \
```

Base URL:
```
https://valeincorp-main-s7ucsa.laravel.cloud/api
```

---

## Listar Leads (GET /leads)

```bash
curl -X GET "https://valeincorp-main-s7ucsa.laravel.cloud/api/leads?per_page=15&search=João" \
-H "Accept: application/json" \

```

### Exemplo de resposta (200 OK)

```json
{
  "current_page": 1,
  "data": [
    {
      "id": 1,
      "nome": "João Silva",
      "telefone": "(11) 98765-4321",
      "email": "joao.silva@example.com",
      "status_leads": 1,
      "origens_leads_id": 2,
      "observacoes": "Contato via web",
      "data_entrada": "2025-05-22",
      "origem": {
        "id": 2,
        "nome": "Website"
      }
    }
  ],
  "per_page": 15,
  "total": 1
}
```


## Listar todos os Leads sem filtros (GET /leads)

```bash
curl -X GET "https://valeincorp-main-s7ucsa.laravel.cloud/api/leads" \
-H "Accept: application/json" \

```

> **Observação:** Este comando retorna a primeira página com 15 leads por padrão. Utilize o parâmetro `per_page` para ajustar a quantidade por página se necessário.
---
---

## Detalhar Lead (GET /leads/{id})

```bash
curl -X GET "https://valeincorp-main-s7ucsa.laravel.cloud/api/leads/1" \
-H "Accept: application/json" \

```

### Exemplo de resposta (200 OK)

```json
{
  "id": 1,
  "nome": "João Silva",
  "telefone": "(11) 98765-4321",
  "email": "joao.silva@example.com",
  "status_leads": 1,
  "origens_leads_id": 2,
  "observacoes": "Contato via web",
  "data_entrada": "2025-05-22",
  "origem": {
    "id": 2,
    "nome": "Website"
  }
}
```

---

## Criar Lead (POST /leads)

```bash
curl -X POST "https://valeincorp-main-s7ucsa.laravel.cloud/api/leads" \
-H "Accept: application/json" \
 \
-H "Content-Type: application/json" \
-d '{
  "nome": "Maria Souza",
  "telefone": "(21) 91234-5678",
  "email": "maria.souza@example.com",
  "status_leads": 2,
  "origens_leads_id": 3,
  "observacoes": "Interessada em orçamento"
}'
```

### Exemplo de resposta (201 Created)

```json
{
  "id": 2,
  "nome": "Maria Souza",
  "telefone": "(21) 91234-5678",
  "email": "maria.souza@example.com",
  "status_leads": 2,
  "origens_leads_id": 3,
  "observacoes": "Interessada em orçamento",
  "data_entrada": "2025-05-22",
  "origem": {
    "id": 3,
    "nome": "E-mail"
  }
}
```

---

## Atualizar Lead (PUT /leads/{id})

```bash
curl -X PUT "https://valeincorp-main-s7ucsa.laravel.cloud/api/leads/2" \
-H "Accept: application/json" \
 \
-H "Content-Type: application/json" \
-d '{
  "nome": "Maria Souza",
  "telefone": "(21) 91234-5678",
  "email": "maria.souza@novoexemplo.com",
  "status_leads": 3,
  "origens_leads_id": 1,
  "observacoes": "Atualizado para contato telefônico"
}'
```

### Exemplo de resposta (200 OK)

```json
{
  "id": 2,
  "nome": "Maria Souza",
  "telefone": "(21) 91234-5678",
  "email": "maria.souza@novoexemplo.com",
  "status_leads": 3,
  "origens_leads_id": 1,
  "observacoes": "Atualizado para contato telefônico",
  "data_entrada": "2025-05-22",
  "origem": {
    "id": 1,
    "nome": "Telefone"
  }
}
```

---

## Excluir Lead (DELETE /leads/{id})

```bash
curl -X DELETE "https://valeincorp-main-s7ucsa.laravel.cloud/api/leads/2" \
-H "Accept: application/json" \

```

### Exemplo de resposta (200 OK)

```json
{
  "message": "Lead removido com sucesso."
}
```
