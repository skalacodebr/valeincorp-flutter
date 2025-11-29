# API de Evolução da Obra

Este documento descreve os endpoints e formatos de resposta esperados para integração do front-end de Evolução da Obra com o backend.

## Endpoints

### 1. Listar Evoluções da Obra

**Endpoint:** `GET /api/empreendimentos/evolucao-obra`  
**Descrição:** Lista todas as evoluções de obra com paginação

**Query Parameters:**
- `page` (opcional): Número da página (padrão: 1)
- `per_page` (opcional): Itens por página (padrão: 10)
- `empreendimento_id` (opcional): Filtrar por empreendimento específico

**Resposta de Sucesso (200):**
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
    },
    {
      "id": 2,
      "nome": "Estrutura - 1º Pavimento",
      "data_criacao": "2024-02-20",
      "empreendimento_id": 1,
      "empreendimento": {
        "id": 1,
        "nome": "Residencial Vista Verde"
      },
      "created_at": "2024-02-20T14:15:00.000Z",
      "updated_at": "2024-02-20T14:15:00.000Z"
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

### 2. Obter Evolução Específica

**Endpoint:** `GET /api/empreendimentos/evolucao-obra/{id}`  
**Descrição:** Obtém detalhes de uma evolução específica

**Resposta de Sucesso (200):**
```json
{
  "id": 1,
  "nome": "Fundação",
  "data_criacao": "2024-01-15",
  "empreendimento_id": 1,
  "empreendimento": {
    "id": 1,
    "nome": "Residencial Vista Verde",
    "endereco": {
      "rua": "Rua das Palmeiras",
      "numero": "123",
      "bairro": "Jardim Tropical",
      "cidade": "São Paulo",
      "estado": "SP",
      "cep": "12345-678"
    }
  },
  "descricao": "Conclusão da fundação do empreendimento",
  "percentual_conclusao": 100,
  "created_at": "2024-01-15T10:30:00.000Z",
  "updated_at": "2024-01-15T10:30:00.000Z"
}
```

### 3. Criar Nova Evolução

**Endpoint:** `POST /api/empreendimentos/evolucao-obra`  
**Descrição:** Cria uma nova evolução de obra

**Corpo da Requisição:**
```json
{
  "nome": "Alvenaria - 2º Pavimento",
  "empreendimento_id": 1,
  "data_criacao": "2024-03-25",
  "descricao": "Início da alvenaria do segundo pavimento",
  "percentual_conclusao": 0
}
```

**Resposta de Sucesso (201):**
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

**Resposta de Erro de Validação (422):**
```json
{
  "message": "Os dados fornecidos são inválidos.",
  "errors": {
    "nome": ["O campo nome é obrigatório."],
    "empreendimento_id": ["O empreendimento selecionado não existe."]
  }
}
```

### 4. Atualizar Evolução

**Endpoint:** `PUT /api/empreendimentos/evolucao-obra/{id}`  
**Descrição:** Atualiza uma evolução existente

**Corpo da Requisição:**
```json
{
  "nome": "Alvenaria - 2º Pavimento (Concluído)",
  "descricao": "Alvenaria do segundo pavimento finalizada",
  "percentual_conclusao": 100
}
```

**Resposta de Sucesso (200):**
```json
{
  "id": 3,
  "nome": "Alvenaria - 2º Pavimento (Concluído)",
  "data_criacao": "2024-03-25",
  "empreendimento_id": 1,
  "descricao": "Alvenaria do segundo pavimento finalizada",
  "percentual_conclusao": 100,
  "created_at": "2024-03-25T08:00:00.000Z",
  "updated_at": "2024-04-10T16:30:00.000Z"
}
```

### 5. Excluir Evolução

**Endpoint:** `DELETE /api/empreendimentos/evolucao-obra/{id}`  
**Descrição:** Exclui uma evolução de obra

**Resposta de Sucesso (204):**
```
No Content
```

**Resposta de Erro (404):**
```json
{
  "message": "Evolução não encontrada"
}
```

### 6. Listar Evoluções por Empreendimento

**Endpoint:** `GET /api/empreendimentos/{empreendimento_id}/evolucao-obra`  
**Descrição:** Lista todas as evoluções de um empreendimento específico

**Resposta de Sucesso (200):**
```json
{
  "data": [
    {
      "id": 1,
      "nome": "Fundação",
      "data_criacao": "2024-01-15",
      "percentual_conclusao": 100,
      "created_at": "2024-01-15T10:30:00.000Z",
      "updated_at": "2024-01-15T10:30:00.000Z"
    },
    {
      "id": 2,
      "nome": "Estrutura - 1º Pavimento",
      "data_criacao": "2024-02-20",
      "percentual_conclusao": 100,
      "created_at": "2024-02-20T14:15:00.000Z",
      "updated_at": "2024-02-20T14:15:00.000Z"
    }
  ]
}
```

## Estrutura de Dados

### Modelo EvolucaoObra
```typescript
interface EvolucaoObra {
  id: number;
  nome: string;
  data_criacao: string; // formato: YYYY-MM-DD
  empreendimento_id: number;
  descricao?: string;
  percentual_conclusao?: number; // 0-100
  empreendimento?: {
    id: number;
    nome: string;
    endereco?: Endereco;
  };
  created_at: string;
  updated_at: string;
}

interface Endereco {
  rua: string;
  numero: string;
  bairro: string;
  cidade: string;
  estado: string;
  cep: string;
}
```

## Códigos de Status HTTP

- **200 OK**: Requisição bem-sucedida
- **201 Created**: Recurso criado com sucesso
- **204 No Content**: Recurso excluído com sucesso
- **400 Bad Request**: Requisição mal formada
- **401 Unauthorized**: Não autenticado
- **403 Forbidden**: Sem permissão para acessar o recurso
- **404 Not Found**: Recurso não encontrado
- **422 Unprocessable Entity**: Erro de validação
- **500 Internal Server Error**: Erro no servidor

## Headers Necessários

```
Authorization: Bearer {token}
Content-Type: application/json
Accept: application/json
```

## Permissões

Todas as operações de evolução da obra requerem a permissão `Empreendimentos`.

## Observações para Implementação

1. **Paginação**: Todos os endpoints de listagem devem suportar paginação
2. **Ordenação**: As evoluções devem ser ordenadas por `data_criacao` DESC por padrão
3. **Soft Delete**: Considerar implementar exclusão lógica (soft delete) ao invés de exclusão física
4. **Auditoria**: Registrar quem criou/editou cada evolução (campos `created_by` e `updated_by`)
5. **Validações**:
   - Nome é obrigatório e deve ter no máximo 255 caracteres
   - Empreendimento deve existir
   - Data de criação não pode ser futura
   - Percentual de conclusão deve estar entre 0 e 100

## Exemplo de Service para o Frontend

```typescript
// lib/api/evolucao-obra-service.ts
import { apiClient } from "@/lib/api-client"

export interface EvolucaoObra {
  id: number
  nome: string
  data_criacao: string
  empreendimento_id: number
  descricao?: string
  percentual_conclusao?: number
  empreendimento?: {
    id: number
    nome: string
  }
  created_at: string
  updated_at: string
}

export interface EvolucaoObraListResponse {
  data: EvolucaoObra[]
  meta: {
    current_page: number
    from: number
    last_page: number
    per_page: number
    to: number
    total: number
  }
}

export async function listarEvolucoes(
  page = 1,
  perPage = 10,
  empreendimentoId?: number
): Promise<EvolucaoObraListResponse> {
  const params = new URLSearchParams({
    page: page.toString(),
    per_page: perPage.toString(),
  })
  
  if (empreendimentoId) {
    params.append("empreendimento_id", empreendimentoId.toString())
  }

  return apiClient<EvolucaoObraListResponse>(
    `empreendimentos/evolucao-obra?${params}`
  )
}

export async function obterEvolucao(id: number): Promise<EvolucaoObra> {
  return apiClient<EvolucaoObra>(`empreendimentos/evolucao-obra/${id}`)
}

export async function criarEvolucao(data: Partial<EvolucaoObra>): Promise<EvolucaoObra> {
  return apiClient<EvolucaoObra>("empreendimentos/evolucao-obra", {
    method: "POST",
    body: JSON.stringify(data),
  })
}

export async function atualizarEvolucao(
  id: number,
  data: Partial<EvolucaoObra>
): Promise<EvolucaoObra> {
  return apiClient<EvolucaoObra>(`empreendimentos/evolucao-obra/${id}`, {
    method: "PUT",
    body: JSON.stringify(data),
  })
}

export async function excluirEvolucao(id: number): Promise<void> {
  return apiClient<void>(`empreendimentos/evolucao-obra/${id}`, {
    method: "DELETE",
  })
}

export async function listarEvolucoesPorEmpreendimento(
  empreendimentoId: number
): Promise<{ data: EvolucaoObra[] }> {
  return apiClient<{ data: EvolucaoObra[] }>(
    `empreendimentos/${empreendimentoId}/evolucao-obra`
  )
}
```