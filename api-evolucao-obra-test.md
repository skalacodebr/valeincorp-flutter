# API Evolução de Obra - Testes

## 1. Listar Todas as Evoluções de Obra

### Curl Command
```bash
curl -X GET "http://localhost/api/empreendimentos/evolucao-obra" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json"
```

### Com parâmetros opcionais
```bash
# Com paginação
curl -X GET "http://localhost/api/empreendimentos/evolucao-obra?per_page=5" \
  -H "Accept: application/json"

# Filtrar por empreendimento
curl -X GET "http://localhost/api/empreendimentos/evolucao-obra?empreendimento_id=1" \
  -H "Accept: application/json"
```

### Response Esperada
```json
{
  "current_page": 1,
  "data": [
    {
      "id": 1,
      "nome": "Fundação - Etapa 1",
      "data_criacao": "2025-01-15",
      "empreendimento_id": 1,
      "descricao": "Início das obras de fundação",
      "percentual_conclusao": 25,
      "created_at": "2025-01-15T10:30:00.000000Z",
      "updated_at": "2025-01-15T10:30:00.000000Z",
      "empreendimento": {
        "id": 1,
        "nome": "Residencial Vista Bela"
      }
    },
    {
      "id": 2,
      "nome": "Estrutura - Primeiro Andar",
      "data_criacao": "2025-01-10",
      "empreendimento_id": null,
      "descricao": "Construção da estrutura do primeiro andar",
      "percentual_conclusao": 15,
      "created_at": "2025-01-10T08:15:00.000000Z",
      "updated_at": "2025-01-10T08:15:00.000000Z",
      "empreendimento": null
    }
  ],
  "first_page_url": "http://localhost/api/empreendimentos/evolucao-obra?page=1",
  "from": 1,
  "last_page": 1,
  "last_page_url": "http://localhost/api/empreendimentos/evolucao-obra?page=1",
  "links": [
    {
      "url": null,
      "label": "&laquo; Previous",
      "active": false
    },
    {
      "url": "http://localhost/api/empreendimentos/evolucao-obra?page=1",
      "label": "1",
      "active": true
    },
    {
      "url": null,
      "label": "Next &raquo;",
      "active": false
    }
  ],
  "next_page_url": null,
  "path": "http://localhost/api/empreendimentos/evolucao-obra",
  "per_page": 10,
  "prev_page_url": null,
  "to": 2,
  "total": 2
}
```

## 2. Ver Detalhes de uma Evolução Específica

### Curl Command
```bash
curl -X GET "http://localhost/api/empreendimentos/evolucao-obra/1" \
  -H "Accept: application/json"
```

### Response Esperada
```json
{
  "id": 1,
  "nome": "Fundação - Etapa 1",
  "data_criacao": "2025-01-15",
  "empreendimento_id": 1,
  "descricao": "Início das obras de fundação",
  "percentual_conclusao": 25,
  "created_at": "2025-01-15T10:30:00.000000Z",
  "updated_at": "2025-01-15T10:30:00.000000Z",
  "empreendimento": {
    "id": 1,
    "nome": "Residencial Vista Bela",
    "endereco": {
      "id": 1,
      "cep": "12345-678",
      "estado": "SP",
      "cidade": "São Paulo",
      "bairro": "Vila Nova",
      "rua": "Rua das Flores",
      "numero": "123",
      "complemento": "Próximo ao shopping"
    }
  }
}
```

## 3. Criar Nova Evolução (sem empreendimento_id)

### Curl Command
```bash
curl -X POST "http://localhost/api/empreendimentos/evolucao-obra" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -d '{
    "nome": "Nova Etapa de Construção",
    "data_criacao": "2025-01-20",
    "descricao": "Descrição da nova etapa",
    "percentual_conclusao": 0
  }'
```

### Response Esperada
```json
{
  "id": 3,
  "nome": "Nova Etapa de Construção",
  "data_criacao": "2025-01-20",
  "empreendimento_id": null,
  "descricao": "Descrição da nova etapa",
  "percentual_conclusao": 0,
  "created_at": "2025-01-20T14:25:00.000000Z",
  "updated_at": "2025-01-20T14:25:00.000000Z"
}
```

## 4. Vincular Evolução a um Empreendimento (depois)

### Curl Command
```bash
curl -X PUT "http://localhost/api/empreendimentos/evolucao-obra/3" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -d '{
    "nome": "Nova Etapa de Construção",
    "data_criacao": "2025-01-20",
    "descricao": "Descrição da nova etapa",
    "percentual_conclusao": 10,
    "empreendimento_id": 2
  }'
```

### Response Esperada
```json
{
  "id": 3,
  "nome": "Nova Etapa de Construção",
  "data_criacao": "2025-01-20",
  "empreendimento_id": 2,
  "descricao": "Descrição da nova etapa",
  "percentual_conclusao": 10,
  "created_at": "2025-01-20T14:25:00.000000Z",
  "updated_at": "2025-01-20T14:30:00.000000Z"
}
```

## Notas Importantes

- **empreendimento_id** agora é opcional na criação (`nullable`)
- As evoluções são ordenadas por `data_criacao` (mais recente primeiro)
- Campos obrigatórios para criação: `nome`, `data_criacao`
- O percentual de conclusão deve estar entre 0 e 100
- A data de criação não pode ser futura
- Suporte a paginação com parâmetro `per_page`
- Filtro por `empreendimento_id` disponível na listagem