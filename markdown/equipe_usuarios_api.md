# Testes de Integração - API Equipe de Usuários

**Base URL:** `https://valeincorp-main-s7ucsa.laravel.cloud/api`

**Headers Comuns:**
```bash
-H "Accept: application/json" \
-H "Authorization: Bearer <SEU_TOKEN_AQUI>"
```

---

## Listar Usuários da Equipe

### Requisição

```bash
curl -X GET "https://valeincorp-main-s7ucsa.laravel.cloud/api/equipe-usuarios?search=João&per_page=5" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer <SEU_TOKEN_AQUI>"
```

### Resposta Esperada (200 OK)

```json
{
  "data": [
    {
      "id": 3,
      "nome": "João da Silva",
      "telefone": "5511999887766",
      "email": "joao@empresa.com",
      "data_entrada": "2025-01-15",
      "cargos_id": 2,
      "status": true,
      "cargo": { /* objeto cargo */ },
      "permissoes": [ /* array de objetos permissao */ ]
    }
  ],
  "links": { /* paginação */ },
  "meta": { /* paginação */ }
}
```

---

## Obter Usuário por ID

### Requisição

```bash
curl -X GET "https://valeincorp-main-s7ucsa.laravel.cloud/api/equipe-usuarios/3" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer <SEU_TOKEN_AQUI>"
```

### Resposta Esperada (200 OK)

```json
{
  "id": 3,
  "nome": "João da Silva",
  "telefone": "5511999887766",
  "email": "joao@empresa.com",
  "data_entrada": "2025-01-15",
  "cargos_id": 2,
  "status": true,
  "cargo": { /* objeto cargo */ },
  "permissoes": [ /* array de objetos permissao */ ]
}
```

---

## Criar Usuário da Equipe

### Requisição

```bash
curl -X POST "https://valeincorp-main-s7ucsa.laravel.cloud/api/equipe-usuarios" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer <SEU_TOKEN_AQUI>" \
  -H "Content-Type: application/json" \
  -d '{
    "nome": "Maria Souza",
    "telefone": "5511988776655",
    "email": "maria@empresa.com",
    "senha": "SenhaForte123",
    "senha_confirmation": "SenhaForte123",
    "data_entrada": "2025-05-10",
    "cargos_id": 1,
    "status": true,
    "permissoes": [1, 3, 5]
  }'
```

### Resposta Esperada (201 Created)

```json
{
  "id": 10,
  "nome": "Maria Souza",
  "telefone": "5511988776655",
  "email": "maria@empresa.com",
  "data_entrada": "2025-05-10",
  "cargos_id": 1,
  "status": true,
  "cargo": { /* objeto cargo */ },
  "permissoes": [ /* array de objetos permissao */ ]
}
```

---

## Atualizar Usuário da Equipe

### Requisição

```bash
curl -X PUT "https://valeincorp-main-s7ucsa.laravel.cloud/api/equipe-usuarios/10" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer <SEU_TOKEN_AQUI>" \
  -H "Content-Type: application/json" \
  -d '{
    "nome": "Maria S. Atualizada",
    "telefone": "5511988776655",
    "email": "maria.atualizada@empresa.com",
    "data_entrada": "2025-05-10",
    "cargos_id": 2,
    "status": false,
    "permissoes": [2, 4]
  }'
```

### Resposta Esperada (200 OK)

```json
{
  "id": 10,
  "nome": "Maria S. Atualizada",
  "telefone": "5511988776655",
  "email": "maria.atualizada@empresa.com",
  "data_entrada": "2025-05-10",
  "cargos_id": 2,
  "status": false,
  "cargo": { /* objeto cargo */ },
  "permissoes": [ /* array de objetos permissao */ ]
}
```

---

## Excluir Usuário da Equipe

### Requisição

```bash
curl -X DELETE "https://valeincorp-main-s7ucsa.laravel.cloud/api/equipe-usuarios/10" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer <SEU_TOKEN_AQUI>"
```

### Resposta Esperada (200 OK)

```json
{ "message": "Usuário removido com sucesso." }
```
