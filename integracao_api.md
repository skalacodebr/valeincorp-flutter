# Integração com API de Evolução da Obra

Este documento fornece exemplos de integração com a API de Evolução da Obra usando curl.

## URL Base
```
https://backend.valeincorp.com.br/api
```

## Headers Necessários
Todas as requisições devem incluir os seguintes headers:
```bash
-H "Authorization: Bearer {seu_token_aqui}" \
-H "Content-Type: application/json" \
-H "Accept: application/json"
```

## Endpoints

### 1. Listar Evoluções da Obra

Lista todas as evoluções de obra com paginação.

```bash
# Listar todas as evoluções (página 1, 10 itens por página)
curl -X GET "https://backend.valeincorp.com.br/api/empreendimentos/evolucao-obra" \
  -H "Authorization: Bearer {seu_token_aqui}" \
  -H "Accept: application/json"

# Com paginação personalizada
curl -X GET "https://backend.valeincorp.com.br/api/empreendimentos/evolucao-obra?page=2&per_page=20" \
  -H "Authorization: Bearer {seu_token_aqui}" \
  -H "Accept: application/json"

# Filtrar por empreendimento específico
curl -X GET "https://backend.valeincorp.com.br/api/empreendimentos/evolucao-obra?empreendimento_id=1" \
  -H "Authorization: Bearer {seu_token_aqui}" \
  -H "Accept: application/json"
```

### 2. Obter Evolução Específica

Obtém detalhes de uma evolução específica.

```bash
curl -X GET "https://backend.valeincorp.com.br/api/empreendimentos/evolucao-obra/1" \
  -H "Authorization: Bearer {seu_token_aqui}" \
  -H "Accept: application/json"
```

### 3. Criar Nova Evolução

Cria uma nova evolução de obra.

```bash
curl -X POST "https://backend.valeincorp.com.br/api/empreendimentos/evolucao-obra" \
  -H "Authorization: Bearer {seu_token_aqui}" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "nome": "Alvenaria - 2º Pavimento",
    "empreendimento_id": 1,
    "data_criacao": "2024-03-25",
    "descricao": "Início da alvenaria do segundo pavimento",
    "percentual_conclusao": 0
  }'
```

### 4. Atualizar Evolução

Atualiza uma evolução existente.

```bash
curl -X PUT "https://backend.valeincorp.com.br/api/empreendimentos/evolucao-obra/3" \
  -H "Authorization: Bearer {seu_token_aqui}" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "nome": "Alvenaria - 2º Pavimento (Concluído)",
    "descricao": "Alvenaria do segundo pavimento finalizada",
    "percentual_conclusao": 100
  }'
```

### 5. Excluir Evolução

Exclui uma evolução de obra.

```bash
curl -X DELETE "https://backend.valeincorp.com.br/api/empreendimentos/evolucao-obra/3" \
  -H "Authorization: Bearer {seu_token_aqui}" \
  -H "Accept: application/json"
```

### 6. Listar Evoluções por Empreendimento

Lista todas as evoluções de um empreendimento específico.

```bash
curl -X GET "https://backend.valeincorp.com.br/api/empreendimentos/1/evolucao-obra" \
  -H "Authorization: Bearer {seu_token_aqui}" \
  -H "Accept: application/json"
```

## Exemplos de Resposta

### Resposta de Sucesso - Lista de Evoluções
```json
{
  "data": [
    {
      "id": 1,
      "nome": "Fundação",
      "data_criacao": "2024-01-15",
      "empreendimento_id": 1,
      "empreendimento": {
        "id": 1,
        "nome": "Residencial Vista Verde"
      },
      "created_at": "2024-01-15T10:30:00.000Z",
      "updated_at": "2024-01-15T10:30:00.000Z"
    }
  ],
  "meta": {
    "current_page": 1,
    "from": 1,
    "last_page": 5,
    "per_page": 10,
    "to": 10,
    "total": 50
  }
}
```

### Resposta de Sucesso - Evolução Criada
```json
{
  "id": 3,
  "nome": "Alvenaria - 2º Pavimento",
  "data_criacao": "2024-03-25",
  "empreendimento_id": 1,
  "descricao": "Início da alvenaria do segundo pavimento",
  "percentual_conclusao": 0,
  "created_at": "2024-03-25T08:00:00.000Z",
  "updated_at": "2024-03-25T08:00:00.000Z"
}
```

### Resposta de Erro de Validação
```json
{
  "message": "Os dados fornecidos são inválidos.",
  "errors": {
    "nome": ["O campo nome é obrigatório."],
    "empreendimento_id": ["O empreendimento selecionado não existe."]
  }
}
```

## Autenticação

### Obter Token de Acesso

Antes de usar os endpoints de evolução da obra, você precisa obter um token de acesso:

```bash
curl -X POST "https://backend.valeincorp.com.br/api/login" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "email": "seu_email@exemplo.com",
    "senha": "sua_senha"
  }'
```

Resposta:
```json
{
  "access_token": "seu_token_aqui",
  "token_type": "Bearer",
  "usuario": {
    "id": 1,
    "nome": "Nome do Usuário",
    "email": "seu_email@exemplo.com"
  }
}
```

Use o `access_token` recebido em todas as requisições subsequentes.

## Tratamento de Erros

### Códigos de Status HTTP

- **200 OK**: Requisição bem-sucedida
- **201 Created**: Recurso criado com sucesso
- **204 No Content**: Recurso excluído com sucesso
- **401 Unauthorized**: Token inválido ou expirado
- **403 Forbidden**: Sem permissão para acessar o recurso
- **404 Not Found**: Recurso não encontrado
- **422 Unprocessable Entity**: Erro de validação
- **500 Internal Server Error**: Erro no servidor

### Exemplo de Erro 401 - Não Autorizado
```json
{
  "message": "Unauthenticated."
}
```

### Exemplo de Erro 404 - Não Encontrado
```json
{
  "message": "Evolução não encontrada"
}
```

## Notas Importantes

1. **Permissões**: Todos os endpoints de evolução da obra requerem a permissão `Empreendimentos`.
2. **Soft Delete**: As exclusões são lógicas, não físicas. Os registros são marcados como deletados mas não removidos do banco.
3. **Ordenação**: As evoluções são ordenadas por `data_criacao` em ordem decrescente por padrão.
4. **Auditoria**: O sistema registra automaticamente quem criou/editou cada evolução através dos campos `created_by` e `updated_by`.

## Exemplos Completos de Fluxo

### Fluxo Completo de Criação e Atualização

```bash
# 1. Login para obter token
TOKEN=$(curl -s -X POST "https://backend.valeincorp.com.br/api/login" \
  -H "Content-Type: application/json" \
  -d '{"email": "seu_email@exemplo.com", "senha": "sua_senha"}' \
  | jq -r '.access_token')

# 2. Criar nova evolução
EVOLUCAO_ID=$(curl -s -X POST "https://backend.valeincorp.com.br/api/empreendimentos/evolucao-obra" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "nome": "Teste de Evolução",
    "empreendimento_id": 1,
    "data_criacao": "2024-04-01",
    "descricao": "Teste de criação via API",
    "percentual_conclusao": 25
  }' \
  | jq -r '.id')

# 3. Atualizar a evolução criada
curl -X PUT "https://backend.valeincorp.com.br/api/empreendimentos/evolucao-obra/$EVOLUCAO_ID" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "percentual_conclusao": 50,
    "descricao": "Progresso atualizado para 50%"
  }'

# 4. Verificar a atualização
curl -X GET "https://backend.valeincorp.com.br/api/empreendimentos/evolucao-obra/$EVOLUCAO_ID" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Accept: application/json"
```