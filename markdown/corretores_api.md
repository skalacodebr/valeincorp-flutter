# API Corretores

Todas as requisições utilizam o base URL:
```
https://valeincorp-main-s7ucsa.laravel.cloud/api/
```
E incluem os headers:
```
-H "Accept: application/json" -H "Authorization: Bearer SEU_TOKEN_AQUI" ```

---

## 1. Corretores

### 1.1 Listar Corretores

```bash
curl -X GET "https://valeincorp-main-s7ucsa.laravel.cloud/api/corretores" -H "Accept: application/json" -H "Authorization: Bearer SEU_TOKEN_AQUI"
```

**Resposta esperada (exemplo):**
```json
{
  "current_page": 1,
  "data": [
    {
      "id": 1,
      "imobiliarias_id": 1,
      "nome": "João Silva",
      "cpf": "123.456.789-00",
      "email": "joao.silva@example.com",
      "senha": "$2y$10$encryptedhash",
      "created_at": "2025-05-27T12:00:00Z",
      "updated_at": "2025-05-27T12:00:00Z",
	  "ativo": "true",
      "imobiliaria": {
        "id": 1,
        "nome": "Imobiliária ABC"
      }
    }
  ]
}
```

### 1.2 Criar Corretor

```bash
curl -X POST "https://valeincorp-main-s7ucsa.laravel.cloud/api/corretores" -H "Accept: application/json" -H "Authorization: Bearer SEU_TOKEN_AQUI" -H "Content-Type: application/json" -d '{
  "imobiliarias_id": 1,
  "nome": "Maria Oliveira",
  "cpf": "987.654.321-00",
  "email": "maria.oliveira@example.com",
  "senha": "secret123"
  "ativo": "false",
}'
```

**Resposta esperada (exemplo):**
```json
{
  "id": 2,
  "imobiliarias_id": 1,
  "nome": "Maria Oliveira",
  "cpf": "987.654.321-00",
  "email": "maria.oliveira@example.com",
  "senha": "$2y$10$encryptedhash",
  "ativo": "false",
  "created_at": "2025-05-28T09:00:00Z",
  "updated_at": "2025-05-28T09:00:00Z"
}
```

### 1.3 Obter Corretor

```bash
curl -X GET "https://valeincorp-main-s7ucsa.laravel.cloud/api/corretores/2" -H "Accept: application/json" -H "Authorization: Bearer SEU_TOKEN_AQUI"
```

**Resposta esperada (exemplo):**
```json
{
  "id": 2,
  "imobiliarias_id": 1,
  "nome": "Maria Oliveira",
  "cpf": "987.654.321-00",
  "email": "maria.oliveira@example.com",
  "senha": "$2y$10$encryptedhash",
  "created_at": "2025-05-28T09:00:00Z",
  "updated_at": "2025-05-28T09:00:00Z",
  "imobiliaria": {
    "id": 1,
    "nome": "Imobiliária ABC"
  }
}
```

### 1.4 Atualizar Corretor

```bash
curl -X PUT "https://valeincorp-main-s7ucsa.laravel.cloud/api/corretores/2" -H "Accept: application/json" -H "Authorization: Bearer SEU_TOKEN_AQUI" -H "Content-Type: application/json" -d '{
  "nome": "Maria O. Santos",
  "email": "maria.santos@example.com"
}'
```

**Resposta esperada (exemplo):**
```json
{
  "id": 2,
  "imobiliarias_id": 1,
  "nome": "Maria O. Santos",
  "cpf": "987.654.321-00",
  "email": "maria.santos@example.com",
  "senha": "$2y$10$encryptedhash",
  "created_at": "2025-05-28T09:00:00Z",
  "updated_at": "2025-05-28T10:00:00Z"
}
```

### 1.5 Deletar Corretor

```bash
curl -X DELETE "https://valeincorp-main-s7ucsa.laravel.cloud/api/corretores/2" -H "Accept: application/json" -H "Authorization: Bearer SEU_TOKEN_AQUI"
```

**Resposta esperada (exemplo):**
```json
{
  "message": "Corretor excluído com sucesso"
}
```
