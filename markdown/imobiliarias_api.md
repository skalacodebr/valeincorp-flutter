
## 2. Imobiliárias

### 2.1 Listar Imobiliárias

```bash
curl -X GET "https://valeincorp-main-s7ucsa.laravel.cloud/api/imobiliarias" -H "Accept: application/json" -H "Authorization: Bearer SEU_TOKEN_AQUI"
```

**Resposta esperada (exemplo):**
```json
{
  "data": [
    {
      "id": 1,
      "nome": "Imobiliária ABC",
      "cnpj": "12.345.678/0001-90",
      "email": "contato@abcimobiliaria.com",
      "telefone": "51 1234-5678",
	  "creci": "43249208",
      "created_at": "2025-05-27T11:00:00Z",
      "updated_at": "2025-05-27T11:00:00Z"
    }
  ]
}
```

### 2.2 Criar Imobiliária

```bash
curl -X POST "https://valeincorp-main-s7ucsa.laravel.cloud/api/imobiliarias" -H "Accept: application/json" -H "Authorization: Bearer SEU_TOKEN_AQUI" -H "Content-Type: application/json" -d '{
  "nome": "Imobiliária XYZ",
  "cnpj": "98.765.432/0001-10",
  "email": "contato@xyzimobiliaria.com",
  "telefone": "51 8765-4321",
  "creci": "43249208"
}'
```

**Resposta esperada (exemplo):**
```json
{
  "id": 2,
  "nome": "Imobiliária XYZ",
  "cnpj": "98.765.432/0001-10",
  "email": "contato@xyzimobiliaria.com",
  "telefone": "51 8765-4321",
  "creci": "43249208",
  "created_at": "2025-05-28T09:30:00Z",
  "updated_at": "2025-05-28T09:30:00Z"
}
```

### 2.3 Obter Imobiliária

```bash
curl -X GET "https://valeincorp-main-s7ucsa.laravel.cloud/api/imobiliarias/2" -H "Accept: application/json" -H "Authorization: Bearer SEU_TOKEN_AQUI"
```

**Resposta esperada (exemplo):**
```json
{
  "id": 2,
  "nome": "Imobiliária XYZ",
  "cnpj": "98.765.432/0001-10",
  "email": "contato@xyzimobiliaria.com",
  "telefone": "51 8765-4321",
  "creci": "43249208",
  "created_at": "2025-05-28T09:30:00Z",
  "updated_at": "2025-05-28T09:30:00Z"
}
```

### 2.4 Atualizar Imobiliária

```bash
curl -X PUT "https://valeincorp-main-s7ucsa.laravel.cloud/api/imobiliarias/2" -H "Accept: application/json" -H "Authorization: Bearer SEU_TOKEN_AQUI" -H "Content-Type: application/json" -d '{
  "telefone": "51 9999-8888"
}'
```

**Resposta esperada (exemplo):**
```json
{
  "id": 2,
  "nome": "Imobiliária XYZ",
  "cnpj": "98.765.432/0001-10",
  "email": "contato@xyzimobiliaria.com",
  "telefone": "51 9999-8888",
  "creci": "43249208",
  "created_at": "2025-05-28T09:30:00Z",
  "updated_at": "2025-05-28T10:10:00Z"
}
```

### 2.5 Deletar Imobiliária

```bash
curl -X DELETE "https://valeincorp-main-s7ucsa.laravel.cloud/api/imobiliarias/2" -H "Accept: application/json" -H "Authorization: Bearer SEU_TOKEN_AQUI"
```

**Resposta esperada (exemplo):**
```json
{
  "message": "Imobiliária excluída com sucesso"
}
```

---

## 3. Imobiliárias Endereço

### 3.1 Listar Endereços

```bash
curl -X GET "https://valeincorp-main-s7ucsa.laravel.cloud/api/imobiliarias-endereco" -H "Accept: application/json" -H "Authorization: Bearer SEU_TOKEN_AQUI"
```

**Resposta esperada (exemplo):**
```json
{
  "current_page": 1,
  "data": [
    {
      "id": 1,
      "imobiliarias_id": 1,
      "cep": "90000-000",
      "estado": "RS",
      "cidade": "Porto Alegre",
      "bairro": "Centro",
      "rua": "Rua Principal",
      "numero": "100",
      "complemento": "Sala 101",
      "created_at": "2025-05-27T13:00:00Z",
      "updated_at": "2025-05-27T13:00:00Z",
      "imobiliaria": {
        "id": 1,
        "nome": "Imobiliária ABC"
      }
    }
  ]
}
```

### 3.2 Criar Endereço

```bash
curl -X POST "https://valeincorp-main-s7ucsa.laravel.cloud/api/imobiliarias-endereco" -H "Accept: application/json" -H "Authorization: Bearer SEU_TOKEN_AQUI" -H "Content-Type: application/json" -d '{
  "imobiliarias_id": 1,
  "cep": "90000-001",
  "estado": "RS",
  "cidade": "Porto Alegre",
  "bairro": "Cidade Baixa",
  "rua": "Rua Secundária",
  "numero": "200",
  "complemento": "Apto 202"
}'
```

**Resposta esperada (exemplo):**
```json
{
  "id": 2,
  "imobiliarias_id": 1,
  "cep": "90000-001",
  "estado": "RS",
  "cidade": "Porto Alegre",
  "bairro": "Cidade Baixa",
  "rua": "Rua Secundária",
  "numero": "200",
  "complemento": "Apto 202",
  "created_at": "2025-05-28T08:45:00Z",
  "updated_at": "2025-05-28T08:45:00Z"
}
```

### 3.3 Obter Endereço

```bash
curl -X GET "https://valeincorp-main-s7ucsa.laravel.cloud/api/imobiliarias-endereco/2" -H "Accept: application/json" -H "Authorization: Bearer SEU_TOKEN_AQUI"
```

**Resposta esperada (exemplo):**
```json
{
  "id": 2,
  "imobiliarias_id": 1,
  "cep": "90000-001",
  "estado": "RS",
  "cidade": "Porto Alegre",
  "bairro": "Cidade Baixa",
  "rua": "Rua Secundária",
  "numero": "200",
  "complemento": "Apto 202",
  "created_at": "2025-05-28T08:45:00Z",
  "updated_at": "2025-05-28T08:45:00Z",
  "imobiliaria": {
    "id": 1,
    "nome": "Imobiliária ABC"
  }
}
```

### 3.4 Atualizar Endereço

```bash
curl -X PUT "https://valeincorp-main-s7ucsa.laravel.cloud/api/imobiliarias-endereco/2" -H "Accept: application/json" -H "Authorization: Bearer SEU_TOKEN_AQUI" -H "Content-Type: application/json" -d '{
  "bairro": "Bela Vista"
}'
```

**Resposta esperada (exemplo):**
```json
{
  "id": 2,
  "imobiliarias_id": 1,
  "cep": "90000-001",
  "estado": "RS",
  "cidade": "Porto Alegre",
  "bairro": "Bela Vista",
  "rua": "Rua Secundária",
  "numero": "200",
  "complemento": "Apto 202",
  "created_at": "2025-05-28T08:45:00Z",
  "updated_at": "2025-05-28T09:15:00Z"
}
```

### 3.5 Deletar Endereço

```bash
curl -X DELETE "https://valeincorp-main-s7ucsa.laravel.cloud/api/imobiliarias-endereco/2" -H "Accept: application/json" -H "Authorization: Bearer SEU_TOKEN_AQUI"
```

**Resposta esperada (exemplo):**
```json
{
  "message": "Endereço excluído com sucesso"
}
```

---

## 4. Imobiliárias Responsáveis

### 4.1 Listar Responsáveis

```bash
curl -X GET "https://valeincorp-main-s7ucsa.laravel.cloud/api/imobiliarias-responsaveis" -H "Accept: application/json" -H "Authorization: Bearer SEU_TOKEN_AQUI"
```

**Resposta esperada (exemplo):**
```json
{
  "current_page": 1,
  "data": [
    {
      "id": 1,
      "imobiliarias_id": 1,
      "nome": "Carlos Pereira",
      "cpf": "111.222.333-44",
      "email": "carlos.pereira@example.com",
      "senha": "$2y$10$encryptedhash",
      "created_at": "2025-05-27T14:00:00Z",
      "updated_at": "2025-05-27T14:00:00Z",
      "imobiliaria": {
        "id": 1,
        "nome": "Imobiliária ABC"
      }
    }
  ]
}
```

### 4.2 Criar Responsável

```bash
curl -X POST "https://valeincorp-main-s7ucsa.laravel.cloud/api/imobiliarias-responsaveis" -H "Accept: application/json" -H "Authorization: Bearer SEU_TOKEN_AQUI" -H "Content-Type: application/json" -d '{
  "imobiliarias_id": 1,
  "nome": "Ana Martins",
  "cpf": "555.666.777-88",
  "email": "ana.martins@example.com",
  "senha": "password123"
}'
```

**Resposta esperada (exemplo):**
```json
{
  "id": 2,
  "imobiliarias_id": 1,
  "nome": "Ana Martins",
  "cpf": "555.666.777-88",
  "email": "ana.martins@example.com",
  "senha": "$2y$10$encryptedhash",
  "created_at": "2025-05-28T10:15:00Z",
  "updated_at": "2025-05-28T10:15:00Z"
}
```

### 4.3 Obter Responsável

```bash
curl -X GET "https://valeincorp-main-s7ucsa.laravel.cloud/api/imobiliarias-responsaveis/2" -H "Accept: application/json" -H "Authorization: Bearer SEU_TOKEN_AQUI"
```

**Resposta esperada (exemplo):**
```json
{
  "id": 2,
  "imobiliarias_id": 1,
  "nome": "Ana Martins",
  "cpf": "555.666.777-88",
  "email": "ana.martins@example.com",
  "senha": "$2y$10$encryptedhash",
  "created_at": "2025-05-28T10:15:00Z",
  "updated_at": "2025-05-28T10:15:00Z",
  "imobiliaria": {
    "id": 1,
    "nome": "Imobiliária ABC"
  }
}
```

### 4.4 Atualizar Responsável

```bash
curl -X PUT "https://valeincorp-main-s7ucsa.laravel.cloud/api/imobiliarias-responsaveis/2" -H "Accept: application/json" -H "Authorization: Bearer SEU_TOKEN_AQUI" -H "Content-Type: application/json" -d '{
  "email": "ana.m@example.com"
}'
```

**Resposta esperada (exemplo):**
```json
{
  "id": 2,
  "imobiliarias_id": 1,
  "nome": "Ana Martins",
  "cpf": "555.666.777-88",
  "email": "ana.m@example.com",
  "senha": "$2y$10$encryptedhash",
  "created_at": "2025-05-28T10:15:00Z",
  "updated_at": "2025-05-28T10:45:00Z"
}
```

### 4.5 Deletar Responsável

```bash
curl -X DELETE "https://valeincorp-main-s7ucsa.laravel.cloud/api/imobiliarias-responsaveis/2" -H "Accept: application/json" -H "Authorization: Bearer SEU_TOKEN_AQUI"
```

**Resposta esperada (exemplo):**
```json
{
  "message": "Responsável excluído com sucesso"
}
```
