# API Documentation - Vale Incorp App

Esta documentação lista todas as rotas de API necessárias para tornar o aplicativo Vale Incorp 100% funcional, com payloads e responses baseadas na análise completa de todas as telas e funcionalidades.

## Índice
- [Autenticação](#autenticação)
- [Usuários](#usuários)
- [Imóveis](#imóveis)
- [Favoritos](#favoritos)
- [Busca e Filtros](#busca-e-filtros)
- [Construtoras](#construtoras)
- [Arquivos e Mídias](#arquivos-e-mídias)
- [Notificações](#notificações)

---

## Autenticação

### POST /api/auth/login
**Descrição:** Realizar login do usuário

**Payload:**
```json
{
  "email": "joao@email.com",
  "senha": "123456"
}
```

**Response (200):**
```json
{
  "success": true,
  "user": {
    "id": 1,
    "nome": "João Silva",
    "email": "joao@email.com",
    "creci": "12345-SP",
    "telefone": "(11) 99999-9999",
    "cpfCnpj": "123.456.789-00",
    "isPessoaJuridica": false,
    "fotoUsuario": null,
    "createdAt": "2024-01-15T10:00:00Z"
  },
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refreshToken": "refresh_token_here"
}
```

**Response (401):**
```json
{
  "success": false,
  "message": "Email ou senha incorretos"
}
```

### POST /api/auth/register
**Descrição:** Registrar novo usuário

**Payload:**
```json
{
  "nomeCompleto": "João Silva",
  "email": "joao@email.com",
  "cpfCnpj": "123.456.789-00",
  "isPessoaJuridica": false,
  "telefone": "(11) 99999-9999",
  "creci": "12345-SP",
  "senha": "123456",
  "confirmarSenha": "123456"
}
```

**Response (201):**
```json
{
  "success": true,
  "message": "Usuário criado com sucesso",
  "user": {
    "id": 1,
    "nome": "João Silva",
    "email": "joao@email.com",
    "creci": "12345-SP",
    "telefone": "(11) 99999-9999",
    "cpfCnpj": "123.456.789-00",
    "isPessoaJuridica": false,
    "createdAt": "2024-01-15T10:00:00Z"
  }
}
```

### POST /api/auth/forgot-password
**Descrição:** Enviar email de recuperação de senha

**Payload:**
```json
{
  "email": "joao@email.com"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Email de recuperação enviado com sucesso"
}
```

### POST /api/auth/reset-password
**Descrição:** Redefinir senha com token

**Payload:**
```json
{
  "token": "reset_token_here",
  "novaSenha": "123456",
  "confirmarSenha": "123456"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Senha alterada com sucesso"
}
```

### POST /api/auth/refresh
**Descrição:** Renovar token de acesso

**Payload:**
```json
{
  "refreshToken": "refresh_token_here"
}
```

**Response (200):**
```json
{
  "success": true,
  "token": "new_access_token",
  "refreshToken": "new_refresh_token"
}
```

---

## Usuários

### GET /api/users/profile
**Descrição:** Obter dados do perfil do usuário logado

**Headers:**
```
Authorization: Bearer <token>
```

**Response (200):**
```json
{
  "success": true,
  "user": {
    "id": 1,
    "nome": "João Silva",
    "email": "joao@email.com",
    "creci": "12345-SP",
    "telefone": "(11) 99999-9999",
    "cpfCnpj": "123.456.789-00",
    "isPessoaJuridica": false,
    "fotoUsuario": "https://example.com/avatar.jpg",
    "createdAt": "2024-01-15T10:00:00Z",
    "updatedAt": "2024-01-20T15:30:00Z"
  }
}
```

### PUT /api/users/profile
**Descrição:** Atualizar dados do perfil

**Headers:**
```
Authorization: Bearer <token>
```

**Payload:**
```json
{
  "nome": "João Silva Santos",
  "telefone": "(11) 98888-8888",
  "creci": "12345-SP"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Perfil atualizado com sucesso",
  "user": {
    "id": 1,
    "nome": "João Silva Santos",
    "email": "joao@email.com",
    "creci": "12345-SP",
    "telefone": "(11) 98888-8888",
    "cpfCnpj": "123.456.789-00",
    "isPessoaJuridica": false,
    "fotoUsuario": "https://example.com/avatar.jpg",
    "updatedAt": "2024-01-20T16:00:00Z"
  }
}
```

### POST /api/users/change-password
**Descrição:** Alterar senha do usuário logado

**Headers:**
```
Authorization: Bearer <token>
```

**Payload:**
```json
{
  "senhaAtual": "senha123",
  "novaSenha": "novasenha123",
  "confirmarSenha": "novasenha123"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Senha alterada com sucesso"
}
```

### POST /api/users/upload-avatar
**Descrição:** Upload da foto de perfil

**Headers:**
```
Authorization: Bearer <token>
Content-Type: multipart/form-data
```

**Payload:**
```
FormData com campo 'avatar' (arquivo de imagem)
```

**Response (200):**
```json
{
  "success": true,
  "message": "Foto de perfil atualizada com sucesso",
  "avatarUrl": "https://example.com/avatars/user_1_avatar.jpg"
}
```

---

## Imóveis

### GET /api/imoveis
**Descrição:** Listar imóveis com paginação e filtros

**Query Parameters:**
- `page` (int): Página atual (default: 1)
- `limit` (int): Itens por página (default: 20)
- `cidade` (string): Filtrar por cidade
- `search` (string): Buscar por código ou nome
- `valorMin` (number): Preço mínimo
- `valorMax` (number): Preço máximo
- `dormitorios` (int): Número mínimo de dormitórios
- `banheiros` (int): Número mínimo de banheiros
- `suites` (int): Número mínimo de suítes
- `suitesMaster` (int): Número mínimo de suítes master
- `vagas` (int): Número mínimo de vagas
- `areaMin` (number): Área mínima
- `areaMax` (number): Área máxima
- `status` (string): Status do imóvel (pronto, na_planta, vendido)

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "codigo": "VIC001",
      "nome": "Casa Colina Sorriso",
      "imagem": "https://example.com/imoveis/imovel_1.jpg",
      "localizacao": "Colina Sorriso - Caxias do Sul",
      "data": "2025-07-24",
      "corretor": "RE/MAX Experience",
      "cidade": "São Paulo",
      "status": "100% Vendido",
      "preco": 1000000,
      "precoFormatado": "R$ 1.000.000,00",
      "dormitorios": 3,
      "banheiros": 2,
      "suites": 1,
      "suitesMaster": 0,
      "vagas": 2,
      "area": 120,
      "areaPrivativa": 525,
      "areaComum": 280.09,
      "areaTotal": 805.09,
      "unidadesDisponiveis": 12,
      "totalUnidades": 48,
      "valorM2": 1904.76,
      "coordenadas": {
        "latitude": -23.5505,
        "longitude": -46.6333
      },
      "createdAt": "2024-01-15T10:00:00Z",
      "updatedAt": "2024-01-20T15:30:00Z"
    }
  ],
  "pagination": {
    "currentPage": 1,
    "totalPages": 5,
    "totalItems": 100,
    "itemsPerPage": 20,
    "hasNextPage": true,
    "hasPreviousPage": false
  }
}
```

### GET /api/imoveis/:id
**Descrição:** Obter detalhes de um imóvel específico

**Response (200):**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "codigo": "VIC001",
    "nome": "Casa Colina Sorriso",
    "descricao": "Lote 16 da quadra 4. Frente Leste e fundos Oeste livre. O condomínio oferece uma excelente infraestrutura com área de lazer completa, segurança 24 horas e localização privilegiada.",
    "imagem": "https://example.com/imoveis/imovel_1.jpg",
    "imagens": [
      "https://example.com/imoveis/imovel_1_1.jpg",
      "https://example.com/imoveis/imovel_1_2.jpg"
    ],
    "localizacao": "Colina Sorriso - Caxias do Sul",
    "endereco": {
      "logradouro": "Rua Alberico Pasinatto, 1234",
      "bairro": "Condomínio Residencial Le Parc",
      "cidade": "Caxias do Sul",
      "estado": "Rio Grande do Sul",
      "cep": "95070-000",
      "complemento": "Unidade 38, Quadra 4 (Lote 16)"
    },
    "data": "2025-07-24",
    "corretor": "RE/MAX Experience",
    "cidade": "São Paulo",
    "status": "Pronto",
    "preco": 1000000,
    "precoFormatado": "R$ 1.000.000,00",
    "dormitorios": 3,
    "banheiros": 2,
    "suites": 1,
    "suitesMaster": 0,
    "vagas": 2,
    "area": 120,
    "areaPrivativa": 525,
    "areaComum": 280.09,
    "areaTotal": 805.09,
    "unidadesDisponiveis": 12,
    "totalUnidades": 48,
    "valorM2": 1904.76,
    "coordenadas": {
      "latitude": -23.5505,
      "longitude": -46.6333
    },
    "videoUrl": "https://www.youtube.com/embed/dQw4w9WgXcQ",
    "diferenciais": [
      {
        "id": 1,
        "nome": "Academia ou Espaço Fitness",
        "icone": "dumbbell"
      },
      {
        "id": 2,
        "nome": "Ampla área aberta",
        "icone": "tree-pine"
      },
      {
        "id": 3,
        "nome": "Área Administrativa",
        "icone": "building-2"
      },
      {
        "id": 4,
        "nome": "Área de festa",
        "icone": "party-popper"
      }
    ],
    "andamentoObra": [
      {
        "nome": "Projetos",
        "progresso": 100
      },
      {
        "nome": "Fundação",
        "progresso": 100
      },
      {
        "nome": "Estrutura",
        "progresso": 100
      },
      {
        "nome": "Instal. Elétrica",
        "progresso": 100
      },
      {
        "nome": "Instal. Hidráulica",
        "progresso": 100
      },
      {
        "nome": "Revestimento",
        "progresso": 85
      },
      {
        "nome": "Esquadrias",
        "progresso": 70
      },
      {
        "nome": "Pavimentação",
        "progresso": 45
      },
      {
        "nome": "Cobertura",
        "progresso": 30
      }
    ],
    "stories": [
      {
        "id": 1,
        "titulo": "Folder",
        "tipo": "folder",
        "imagens": [
          "https://example.com/stories/folder_1.jpg",
          "https://example.com/stories/folder_2.jpg"
        ]
      },
      {
        "id": 2,
        "titulo": "Decorado",
        "tipo": "decorado",
        "imagens": [
          "https://example.com/stories/decorado_1.jpg",
          "https://example.com/stories/decorado_2.jpg"
        ]
      }
    ],
    "pontosReferencia": [
      {
        "nome": "Shopping Center",
        "distancia": "2,5 km"
      },
      {
        "nome": "Hospital Regional",
        "distancia": "3,2 km"
      },
      {
        "nome": "Universidade",
        "distancia": "4,1 km"
      },
      {
        "nome": "Aeroporto",
        "distancia": "15 km"
      }
    ],
    "transporte": [
      {
        "nome": "Ponto de ônibus",
        "distancia": "200m"
      },
      {
        "nome": "Estação de trem",
        "distancia": "5 km"
      },
      {
        "nome": "Acesso à BR-116",
        "distancia": "8 km"
      },
      {
        "nome": "Centro da cidade",
        "distancia": "12 km"
      }
    ],
    "createdAt": "2024-01-15T10:00:00Z",
    "updatedAt": "2024-01-20T15:30:00Z"
  }
}
```

### GET /api/imoveis/:id/images/:storyType
**Descrição:** Obter imagens específicas de um story do imóvel

**Path Parameters:**
- `id`: ID do imóvel
- `storyType`: Tipo do story (folder, decorado, externa, interna, planta)

**Response (200):**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "titulo": "Decorado",
    "tipo": "decorado",
    "imagens": [
      "https://example.com/stories/decorado_1.jpg",
      "https://example.com/stories/decorado_2.jpg",
      "https://example.com/stories/decorado_3.jpg"
    ]
  }
}
```

---

## Favoritos

### GET /api/favoritos
**Descrição:** Listar imóveis favoritos do usuário

**Headers:**
```
Authorization: Bearer <token>
```

**Query Parameters:**
- `page` (int): Página atual (default: 1)
- `limit` (int): Itens por página (default: 20)
- `search` (string): Buscar por código ou nome

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "imovelId": 1,
      "imovel": {
        "id": 1,
        "codigo": "VIC001",
        "nome": "Casa Colina Sorriso",
        "imagem": "https://example.com/imoveis/imovel_1.jpg",
        "localizacao": "Colina Sorriso - Caxias do Sul",
        "preco": 1000000,
        "precoFormatado": "R$ 1.000.000,00",
        "status": "Pronto"
      },
      "favoritadoEm": "2024-01-20T10:00:00Z"
    }
  ],
  "pagination": {
    "currentPage": 1,
    "totalPages": 2,
    "totalItems": 25,
    "itemsPerPage": 20
  }
}
```

### POST /api/favoritos
**Descrição:** Adicionar imóvel aos favoritos

**Headers:**
```
Authorization: Bearer <token>
```

**Payload:**
```json
{
  "imovelId": 1
}
```

**Response (201):**
```json
{
  "success": true,
  "message": "Imóvel adicionado aos favoritos",
  "data": {
    "id": 1,
    "imovelId": 1,
    "userId": 1,
    "favoritadoEm": "2024-01-20T10:00:00Z"
  }
}
```

### DELETE /api/favoritos/:imovelId
**Descrição:** Remover imóvel dos favoritos

**Headers:**
```
Authorization: Bearer <token>
```

**Response (200):**
```json
{
  "success": true,
  "message": "Imóvel removido dos favoritos"
}
```

### GET /api/favoritos/check/:imovelId
**Descrição:** Verificar se imóvel está nos favoritos

**Headers:**
```
Authorization: Bearer <token>
```

**Response (200):**
```json
{
  "success": true,
  "isFavorito": true
}
```

---

## Busca e Filtros

### GET /api/cidades
**Descrição:** Listar cidades disponíveis

**Response (200):**
```json
{
  "success": true,
  "data": [
    "São Paulo",
    "Rio de Janeiro",
    "Belo Horizonte",
    "Brasília",
    "Salvador",
    "Fortaleza",
    "Recife",
    "Porto Alegre"
  ]
}
```

### POST /api/buscar
**Descrição:** Buscar imóveis com filtros avançados

**Payload:**
```json
{
  "localizacao": ["São Paulo", "Rio de Janeiro"],
  "valorDe": 500000,
  "valorAte": 1500000,
  "metragemDe": 80,
  "metragemAte": 300,
  "dormitorios": 2,
  "banheiros": 1,
  "suites": 1,
  "suitesMaster": 0,
  "vagasGaragem": 1,
  "status": ["pronto", "na_planta"],
  "page": 1,
  "limit": 20
}
```

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "codigo": "VIC001",
      "nome": "Casa Colina Sorriso",
      "imagem": "https://example.com/imoveis/imovel_1.jpg",
      "localizacao": "Colina Sorriso - Caxias do Sul",
      "preco": 1000000,
      "precoFormatado": "R$ 1.000.000,00",
      "dormitorios": 3,
      "banheiros": 2,
      "suites": 1,
      "vagas": 2,
      "area": 120,
      "status": "Pronto"
    }
  ],
  "pagination": {
    "currentPage": 1,
    "totalPages": 3,
    "totalItems": 45,
    "itemsPerPage": 20
  },
  "filtrosAplicados": {
    "valorDe": 500000,
    "valorAte": 1500000,
    "dormitorios": 2,
    "status": ["pronto", "na_planta"]
  }
}
```

---

## Construtoras

### GET /api/construtoras
**Descrição:** Listar construtoras

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "nome": "Vale Incorp",
      "logo": "https://example.com/logos/vale_incorp.png",
      "descricao": "Construtora especializada em empreendimentos residenciais de alto padrão",
      "totalEmpreendimentos": 25,
      "empreendimentosAtivos": 8,
      "createdAt": "2020-01-15T10:00:00Z"
    }
  ]
}
```

### GET /api/construtoras/:id
**Descrição:** Obter dados de uma construtora específica

**Response (200):**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "nome": "Vale Incorp",
    "logo": "https://example.com/logos/vale_incorp.png",
    "descricao": "Construtora especializada em empreendimentos residenciais de alto padrão",
    "totalEmpreendimentos": 25,
    "empreendimentosAtivos": 8,
    "endereco": {
      "logradouro": "Rua das Construtoras, 123",
      "cidade": "São Paulo",
      "estado": "SP",
      "cep": "01234-567"
    },
    "contato": {
      "telefone": "(11) 3333-4444",
      "email": "contato@valeincorp.com.br",
      "website": "https://valeincorp.com.br"
    },
    "createdAt": "2020-01-15T10:00:00Z"
  }
}
```

### GET /api/construtoras/:id/empreendimentos
**Descrição:** Listar empreendimentos de uma construtora

**Query Parameters:**
- `categoria` (string): "novos" ou "terceiros"
- `page` (int): Página atual
- `limit` (int): Itens por página

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "nome": "Residencial Pinheiros",
      "imagem": "https://example.com/empreendimentos/residencial_pinheiros.jpg",
      "status": "100% Vendido",
      "localizacao": "Pinheiros - São Paulo",
      "unidades": 48,
      "precoMin": 800000,
      "precoMax": 1500000,
      "precoFormatado": "R$ 800k a R$ 1,5mi",
      "dormitorios": 3,
      "area": "146 m²",
      "categoria": "novos",
      "dataLancamento": "2023-03-15",
      "dataEntrega": "2025-12-30"
    }
  ],
  "pagination": {
    "currentPage": 1,
    "totalPages": 2,
    "totalItems": 15,
    "itemsPerPage": 10
  }
}
```

---

## Arquivos e Mídias

### POST /api/upload
**Descrição:** Upload de arquivos (imagens, documentos)

**Headers:**
```
Authorization: Bearer <token>
Content-Type: multipart/form-data
```

**Payload:**
```
FormData com campo 'file' e metadados opcionais
```

**Response (200):**
```json
{
  "success": true,
  "message": "Arquivo enviado com sucesso",
  "data": {
    "id": 1,
    "filename": "documento.pdf",
    "originalName": "Folder Empreendimento.pdf",
    "mimeType": "application/pdf",
    "size": 2048576,
    "url": "https://example.com/uploads/documento.pdf",
    "uploadedAt": "2024-01-20T10:00:00Z"
  }
}
```

### GET /api/media/:type/:id
**Descrição:** Obter mídias específicas (folder, decorado, etc.)

**Path Parameters:**
- `type`: Tipo de mídia (folder, decorado, externa, interna, planta)
- `id`: ID do imóvel

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "titulo": "Folder",
      "tipo": "folder",
      "url": "https://example.com/media/folder_1.pdf",
      "thumbnail": "https://example.com/media/thumbs/folder_1.jpg",
      "ordem": 1
    }
  ]
}
```

---

## Notificações

### GET /api/notifications
**Descrição:** Listar notificações do usuário

**Headers:**
```
Authorization: Bearer <token>
```

**Query Parameters:**
- `page` (int): Página atual
- `limit` (int): Itens por página
- `unreadOnly` (boolean): Apenas não lidas

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "titulo": "Novo imóvel disponível",
      "mensagem": "Um novo imóvel foi adicionado na sua área de interesse",
      "tipo": "novo_imovel",
      "imovelId": 1,
      "lida": false,
      "createdAt": "2024-01-20T15:00:00Z"
    }
  ],
  "pagination": {
    "currentPage": 1,
    "totalPages": 3,
    "totalItems": 25,
    "itemsPerPage": 10
  },
  "totalUnread": 5
}
```

### PUT /api/notifications/:id/read
**Descrição:** Marcar notificação como lida

**Headers:**
```
Authorization: Bearer <token>
```

**Response (200):**
```json
{
  "success": true,
  "message": "Notificação marcada como lida"
}
```

### PUT /api/notifications/read-all
**Descrição:** Marcar todas as notificações como lidas

**Headers:**
```
Authorization: Bearer <token>
```

**Response (200):**
```json
{
  "success": true,
  "message": "Todas as notificações foram marcadas como lidas"
}
```

---

## Endpoints de Sistema

### GET /api/health
**Descrição:** Verificar status da API

**Response (200):**
```json
{
  "success": true,
  "status": "ok",
  "timestamp": "2024-01-20T16:00:00Z",
  "version": "1.0.0"
}
```

### GET /api/config
**Descrição:** Obter configurações do app

**Response (200):**
```json
{
  "success": true,
  "data": {
    "app": {
      "name": "Vale Incorp",
      "version": "1.0.0",
      "environment": "production"
    },
    "features": {
      "favoritos": true,
      "notifications": true,
      "stories": true,
      "videos": true
    },
    "limits": {
      "maxFavorites": 100,
      "maxUploadSize": 10485760,
      "itemsPerPage": 20
    }
  }
}
```

---

## Códigos de Status HTTP

- **200** - Sucesso
- **201** - Criado com sucesso  
- **400** - Requisição inválida
- **401** - Não autorizado
- **403** - Acesso negado
- **404** - Recurso não encontrado
- **409** - Conflito (ex: email já cadastrado)
- **422** - Dados de entrada inválidos
- **500** - Erro interno do servidor

## Autenticação

Todas as rotas que requerem autenticação devem incluir o header:
```
Authorization: Bearer <token>
```

O token tem validade de 24 horas e deve ser renovado usando o endpoint `/api/auth/refresh`.

## Paginação

Endpoints que retornam listas suportam paginação com os parâmetros:
- `page`: Página atual (padrão: 1)
- `limit`: Itens por página (padrão: 20, máximo: 100)

## Filtros e Ordenação

Muitos endpoints suportam filtros adicionais:
- `search`: Busca textual
- `orderBy`: Campo para ordenação
- `orderDirection`: "asc" ou "desc"

## Taxa de Requisições (Rate Limiting)

- Endpoints de autenticação: 5 requisições por minuto por IP
- Endpoints gerais: 100 requisições por minuto por usuário
- Upload de arquivos: 10 requisições por minuto por usuário

---

Esta documentação cobre todas as funcionalidades identificadas no aplicativo Vale Incorp. Para tornar o app 100% funcional, implemente todos esses endpoints seguindo os padrões e estruturas de dados especificados.