# Documentação de APIs - Valeincorp Flutter

## Base URL

```
https://backend.valeincorp.com.br/api
```

---

## 1. Autenticação

### Login
```
POST /auth/login
Content-Type: application/json

Request Body:
{
  "email": "string",
  "senha": "string"
}

Response:
{
  "success": true,
  "data": {
    "token": "string",
    "user": {
      "id": number,
      "nome": "string",
      "email": "string",
      "creci": "string",
      "foto": "string"
    }
  }
}
```

### Registro
```
POST /auth/register
Content-Type: application/json

Request Body:
{
  "nome": "string",
  "email": "string",
  "senha": "string",
  "creci": "string",
  "telefone": "string"
}
```

### Esqueci Senha
```
POST /auth/forgot-password
Content-Type: application/json

Request Body:
{
  "email": "string"
}
```

### Refresh Token
```
POST /auth/refresh
Authorization: Bearer {token}
```

---

## 2. Imóveis (Empreendimentos)

### Listar Imóveis
```
GET /imoveis
Query Parameters:
  - page: number
  - limit: number
  - cidade: string
  - search: string
  - valorMin: number
  - valorMax: number
  - dormitorios: number
  - banheiros: number
  - suites: number
  - vagas: number
  - areaMin: number
  - areaMax: number
  - status: string

Response:
{
  "success": true,
  "data": [
    {
      "id": number,
      "codigo": "string",
      "nome": "string",
      "imagem": "string",
      "localizacao": "string",
      "dataEntrega": "string",
      "corretor": "string",
      "cidade": "string",
      "status": "string",
      "preco": number,
      "precoFormatado": "string",
      "dormitorios": number,
      "banheiros": number,
      "suites": number,
      "vagas": number,
      "area": number,
      "unidadesDisponiveis": number,
      "totalUnidades": number
    }
  ],
  "pagination": {
    "page": number,
    "limit": number,
    "total": number,
    "totalPages": number
  }
}
```

### Detalhes do Imóvel
```
GET /imoveis/{id}

Response:
{
  "success": true,
  "data": {
    "id": number,
    "codigo": "string",
    "nome": "string",
    "imagem": "string",
    "localizacao": "string",
    "dataEntrega": "string",
    "corretor": "string",
    "cidade": "string",
    "status": "string",
    "preco": number,
    "precoFormatado": "string",
    "dormitorios": number,
    "banheiros": number,
    "suites": number,
    "vagas": number,
    "area": number,
    "areaComum": number,
    "areaTotal": number,
    "unidadesDisponiveis": number,
    "totalUnidades": number,
    "unidadesVendidas": number,
    "valorM2": number,
    "descricao": "string",
    "imagens": ["string"],
    "videoUrl": "string",
    "coordenadas": {
      "lat": number,
      "lng": number
    },
    "endereco": {
      "logradouro": "string",
      "bairro": "string",
      "cidade": "string",
      "estado": "string",
      "cep": "string"
    },
    "stories": [
      {
        "id": number,
        "titulo": "string",
        "tipo": "string", // folder, decorado, externa, interna, planta
        "imagens": [
          {
            "fotos_url": "string",
            "legenda": "string"
          }
        ]
      }
    ],
    "documentos": [
      {
        "id": number,
        "arquivo_url": "string",
        "tipo_documento": {
          "id": number,
          "nome": "string",
          "tipo_arquivo": "string"
        }
      }
    ],
    "videos_unidades": [
      {
        "id": number,
        "video_url": "string",
        "categoria": "string"
      }
    ],
    "andamentoObra": [
      {
        "nome": "string",
        "progresso": number
      }
    ],
    "diferenciais": [
      {
        "id": number,
        "nome": "string",
        "icone": "string"
      }
    ]
  }
}
```

### Imagens por Story Type
```
GET /imoveis/{id}/images/{storyType}

storyType: folder | decorado | externa | interna | planta

Response:
{
  "success": true,
  "data": [
    {
      "fotos_url": "string",
      "legenda": "string"
    }
  ]
}
```

---

## 3. Empreendimentos (Detalhes Adicionais)

### Detalhes do Empreendimento
```
GET /empreendimentos/{id}

Response:
{
  "id": number,
  "nome": "string",
  "imagem_empreendimento": "string",
  "area_lazer": boolean,
  "unidades_disponiveis": number,
  "unidades_reservadas": number,
  "unidades_vendidas": number,
  "total_unidades": number,
  "torres": [
    {
      "id": number,
      "nome": "string",
      "numero_andares": number,
      "quantidade_unidades_andar": number,
      "total_unidades": number,
      "unidades_disponiveis": number
    }
  ],
  "videos_unidades": [
    {
      "id": number,
      "video_url": "string",
      "categoria": "string"
    }
  ]
}
```

---

## 4. Torres

### Unidades por Torre
```
GET /torres/{torreId}/unidades

Response:
{
  "success": true,
  "data": [
    {
      "id": number,
      "numero_apartamento": "string",
      "numero_andar_apartamento": number,
      "posicao": "string",
      "tipologia": "string",
      "tamanho_unidade_metros_quadrados": number,
      "numero_quartos": number,
      "numero_suites": number,
      "numero_banheiros": number,
      "valor": number,
      "status_unidades_id": number // 1=disponivel, 2=reservado, 3=vendido
    }
  ]
}
```

---

## 5. Unidades

### Detalhes da Unidade
```
GET /unidades/{id}

Response:
{
  "success": true,
  "data": {
    "id": number,
    "numero": number,
    "andar": number,
    "area": "string",
    "areaFormatada": "string",
    "quartos": number,
    "suites": number,
    "banheiros": number,
    "valor": "string",
    "valorFormatado": "string",
    "valorM2": number,
    "valorM2Formatado": "string",
    "status": "string",
    "statusLabel": "string",
    "statusId": number,
    "observacao": "string",
    "posicao": "string",
    "vistaEspecial": boolean,
    "solManha": boolean,
    "solTarde": boolean,
    "fotos": [
      {
        "id": number,
        "fotos_url": "string",
        "legenda": "string"
      }
    ],
    "vagasGaragem": [
      {
        "id": number,
        "numero": "string",
        "tipo": "string",
        "cobertura": boolean,
        "area": "string",
        "pavimento": "string",
        "status": "string"
      }
    ],
    "medidas": [
      {
        "tipo_medida_id": number,
        "tipo_nome": "string",
        "tipo_unidade": "string",
        "valor": number
      }
    ],
    "torre": {
      "id": number,
      "nome": "string",
      "numeroAndares": number,
      "unidadesPorAndar": number
    },
    "empreendimento": {
      "id": number,
      "nome": "string",
      "descricao": "string",
      "endereco": {
        "logradouro": "string",
        "bairro": "string",
        "cidade": "string",
        "estado": "string",
        "cep": "string"
      }
    }
  }
}
```

---

## 6. Favoritos

### Listar Favoritos
```
GET /favoritos
Authorization: Bearer {token}

Response:
{
  "success": true,
  "data": [
    { /* Imovel object */ }
  ]
}
```

### Adicionar Favorito
```
POST /favoritos
Authorization: Bearer {token}
Content-Type: application/json

Request Body:
{
  "imovelId": number
}
```

### Remover Favorito
```
DELETE /favoritos/{imovelId}
Authorization: Bearer {token}
```

### Verificar Favorito
```
GET /favoritos/check/{imovelId}
Authorization: Bearer {token}

Response:
{
  "success": true,
  "isFavorito": boolean
}
```

### Contar Favoritos
```
GET /favoritos/count
Authorization: Bearer {token}

Response:
{
  "success": true,
  "count": number
}
```

---

## 7. Busca

### Listar Cidades
```
GET /cidades

Response:
{
  "success": true,
  "data": ["string"]
}
```

### Busca Avançada
```
POST /buscar
Content-Type: application/json

Request Body:
{
  "localizacao": ["string"],
  "valorDe": number,
  "valorAte": number,
  "metragemDe": number,
  "metragemAte": number,
  "dormitorios": number,
  "banheiros": number,
  "suites": number,
  "vagasGaragem": number,
  "status": ["string"],
  "page": number,
  "limit": number
}
```

---

## 8. Usuário

### Perfil
```
GET /users/profile
Authorization: Bearer {token}

Response:
{
  "success": true,
  "data": {
    "id": number,
    "nome": "string",
    "email": "string",
    "creci": "string",
    "telefone": "string",
    "foto": "string"
  }
}
```

### Upload Avatar
```
POST /users/upload-avatar
Authorization: Bearer {token}
Content-Type: multipart/form-data

Form Data:
  - avatar: File
```

---

## 9. Proxies (para evitar CORS)

### Proxy de Imagem
```
GET /api/proxy/image?url={imageUrl}
```

### Proxy de PDF
```
GET /api/proxy/pdf?url={pdfUrl}
```

### Proxy de Vídeo
```
GET /api/proxy/video?url={videoUrl}
```

---

## Status Codes

| Code | Descrição |
|------|-----------|
| 200 | Sucesso |
| 201 | Criado com sucesso |
| 400 | Requisição inválida |
| 401 | Não autorizado |
| 403 | Acesso negado |
| 404 | Não encontrado |
| 500 | Erro interno do servidor |

---

## Estrutura de Resposta Padrão

```json
{
  "success": boolean,
  "message": "string", // opcional, geralmente em erros
  "data": any, // dados da resposta
  "pagination": { // opcional, para listagens
    "page": number,
    "limit": number,
    "total": number,
    "totalPages": number
  }
}
```

---

## Status de Unidades

| ID | Status |
|----|--------|
| 1 | Disponível |
| 2 | Reservado |
| 3 | Vendido |

---

## Tipos de Stories

| Tipo | Descrição |
|------|-----------|
| folder | Folder do empreendimento |
| decorado | Fotos do apartamento decorado |
| externa | Fotos externas do prédio |
| interna | Fotos internas das áreas comuns |
| planta | Plantas baixas das unidades |

