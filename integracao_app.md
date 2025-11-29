# 📱 Integração App Vale Incorp - Testes de API

## 🔧 **Configuração do Ambiente de Testes**

**Base URL:** `https://backend.valeincorp.com.br/api`  
**Autenticação:** Bearer Token (Sanctum)  
**Content-Type:** `application/json`

---

## 🧪 **Testes de Endpoints - Respostas Completas**

### **1. SISTEMA - Health Check**

```bash
curl -X GET "https://backend.valeincorp.com.br/api/health" \
  -H "Content-Type: application/json"
```

**✅ Response (200):**
```json
{
    "success": true,
    "status": "ok",
    "timestamp": "2025-08-06T14:30:15Z",
    "version": "1.0.0"
}
```

---

### **2. SISTEMA - Configuração do App**

```bash
curl -X GET "https://backend.valeincorp.com.br/api/config" \
  -H "Content-Type: application/json"
```

**✅ Response (200):**
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

### **3. AUTENTICAÇÃO - Registro de Usuário**

```bash
curl -X POST "https://backend.valeincorp.com.br/api/auth/register" \
  -H "Content-Type: application/json" \
  -d '{
    "nomeCompleto": "João Silva",
    "email": "joao@email.com",
    "cpfCnpj": "123.456.789-00",
    "isPessoaJuridica": false,
    "telefone": "(11) 99999-9999",
    "creci": "12345-SP",
    "senha": "123456",
    "confirmarSenha": "123456"
  }'
```

**✅ Response (201):**
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
        "createdAt": "2025-08-06T14:30:00Z"
    }
}
```

---

### **4. AUTENTICAÇÃO - Login**

```bash
curl -X POST "https://backend.valeincorp.com.br/api/auth/login" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "joao@email.com",
    "senha": "123456"
  }'
```

**✅ Response (200):**
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
        "createdAt": "2025-08-06T14:30:00Z"
    },
    "token": "1|eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "refresh_token_abc123xyz"
}
```

**❌ Response (401) - Credenciais Inválidas:**
```json
{
    "success": false,
    "message": "Email ou senha incorretos"
}
```

---

### **5. USUÁRIO - Perfil (Requer Token)**

```bash
curl -X GET "https://backend.valeincorp.com.br/api/users/profile" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer 1|eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

**✅ Response (200):**
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
        "fotoUsuario": "https://exemplo.com/avatars/user_1.jpg",
        "createdAt": "2025-08-06T14:30:00Z",
        "updatedAt": "2025-08-06T15:00:00Z"
    }
}
```

---

### **6. USUÁRIO - Atualizar Perfil**

```bash
curl -X PUT "https://backend.valeincorp.com.br/api/users/profile" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer TOKEN_AQUI" \
  -d '{
    "nome": "João Silva Santos",
    "telefone": "(11) 98888-8888",
    "creci": "12345-SP"
  }'
```

**✅ Response (200):**
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
        "fotoUsuario": null,
        "updatedAt": "2025-08-06T15:30:00Z"
    }
}
```

---

### **7. IMÓVEIS - Listar com Filtros**

```bash
curl -X GET "https://backend.valeincorp.com.br/api/imoveis?page=1&limit=10&cidade=São Paulo&search=VIC001" \
  -H "Content-Type: application/json"
```

**✅ Response (200):**
```json
{
    "success": true,
    "data": [
        {
            "id": 1,
            "codigo": "VIC001",
            "nome": "Residencial Vista Bela",
            "imagem": "https://exemplo.com/imoveis/residencial_vista_bela.jpg",
            "localizacao": "Vila Madalena - São Paulo",
            "data": "2025-07-24",
            "corretor": "Vale Incorp",
            "cidade": "São Paulo",
            "status": "100% Vendido",
            "preco": 1200000,
            "precoFormatado": "R$ 1.200.000,00",
            "dormitorios": 3,
            "banheiros": 2,
            "suites": 1,
            "suitesMaster": 0,
            "vagas": 2,
            "area": 120,
            "areaPrivativa": 525,
            "areaComum": 280.09,
            "areaTotal": 805.09,
            "unidadesDisponiveis": 8,
            "totalUnidades": 48,
            "valorM2": 1904.76,
            "coordenadas": {
                "latitude": -23.5505,
                "longitude": -46.6333
            },
            "createdAt": "2025-01-15T10:00:00Z",
            "updatedAt": "2025-07-24T15:30:00Z"
        }
    ],
    "pagination": {
        "currentPage": 1,
        "totalPages": 5,
        "totalItems": 45,
        "itemsPerPage": 10,
        "hasNextPage": true,
        "hasPreviousPage": false
    }
}
```

---

### **8. IMÓVEIS - Detalhes Completos**

```bash
curl -X GET "https://backend.valeincorp.com.br/api/imoveis/1" \
  -H "Content-Type: application/json"
```

**✅ Response (200):**
```json
{
    "success": true,
    "data": {
        "id": 1,
        "codigo": "VIC001",
        "nome": "Residencial Vista Bela",
        "descricao": "Excelente empreendimento localizado na Vila Madalena, com infraestrutura completa e acabamento de alto padrão.",
        "imagem": "https://exemplo.com/imoveis/residencial_vista_bela.jpg",
        "imagens": [
            "https://exemplo.com/imoveis/residencial_vista_bela_1.jpg",
            "https://exemplo.com/imoveis/residencial_vista_bela_2.jpg",
            "https://exemplo.com/imoveis/residencial_vista_bela_3.jpg"
        ],
        "localizacao": "Vila Madalena - São Paulo",
        "endereco": {
            "logradouro": "Rua Harmonia, 1234",
            "bairro": "Vila Madalena",
            "cidade": "São Paulo",
            "estado": "SP",
            "cep": "05435-000",
            "complemento": "Torre A"
        },
        "data": "2025-07-24",
        "corretor": "Vale Incorp",
        "cidade": "São Paulo",
        "status": "Pronto",
        "preco": 1200000,
        "precoFormatado": "R$ 1.200.000,00",
        "dormitorios": 3,
        "banheiros": 2,
        "suites": 1,
        "suitesMaster": 0,
        "vagas": 2,
        "area": 120,
        "areaPrivativa": 525,
        "areaComum": 280.09,
        "areaTotal": 805.09,
        "unidadesDisponiveis": 8,
        "totalUnidades": 48,
        "valorM2": 1904.76,
        "coordenadas": {
            "latitude": -23.5505,
            "longitude": -46.6333
        },
        "videoUrl": "https://www.youtube.com/embed/exemplo123",
        "diferenciais": [
            {
                "id": 1,
                "nome": "Academia ou Espaço Fitness",
                "icone": "dumbbell"
            },
            {
                "id": 2,
                "nome": "Piscina Adulto",
                "icone": "waves"
            },
            {
                "id": 3,
                "nome": "Área de Festa",
                "icone": "party-popper"
            },
            {
                "id": 4,
                "nome": "Playground",
                "icone": "baby"
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
                    "https://exemplo.com/stories/folder_1.jpg",
                    "https://exemplo.com/stories/folder_2.jpg"
                ]
            },
            {
                "id": 2,
                "titulo": "Decorado",
                "tipo": "decorado",
                "imagens": [
                    "https://exemplo.com/stories/decorado_1.jpg",
                    "https://exemplo.com/stories/decorado_2.jpg"
                ]
            }
        ],
        "pontosReferencia": [
            {
                "nome": "Shopping Eldorado",
                "distancia": "2,5 km"
            },
            {
                "nome": "Hospital Sírio Libanês",
                "distancia": "3,2 km"
            },
            {
                "nome": "Universidade Mackenzie",
                "distancia": "4,1 km"
            },
            {
                "nome": "Aeroporto Congonhas",
                "distancia": "15 km"
            }
        ],
        "transporte": [
            {
                "nome": "Ponto de ônibus",
                "distancia": "200m"
            },
            {
                "nome": "Estação Faria Lima",
                "distancia": "1,5 km"
            },
            {
                "nome": "Acesso Marginal Pinheiros",
                "distancia": "3 km"
            },
            {
                "nome": "Centro de SP",
                "distancia": "8 km"
            }
        ],
        "createdAt": "2025-01-15T10:00:00Z",
        "updatedAt": "2025-07-24T15:30:00Z"
    }
}
```

---

### **9. FAVORITOS - Listar (Requer Token)**

```bash
curl -X GET "https://backend.valeincorp.com.br/api/favoritos?page=1&limit=20" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer TOKEN_AQUI"
```

**✅ Response (200):**
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
                "nome": "Residencial Vista Bela",
                "imagem": "https://exemplo.com/imoveis/residencial_vista_bela.jpg",
                "localizacao": "Vila Madalena - São Paulo",
                "preco": 1200000,
                "precoFormatado": "R$ 1.200.000,00",
                "status": "Pronto"
            },
            "favoritadoEm": "2025-08-06T10:00:00Z"
        }
    ],
    "pagination": {
        "currentPage": 1,
        "totalPages": 1,
        "totalItems": 1,
        "itemsPerPage": 20
    }
}
```

---

### **10. FAVORITOS - Adicionar**

```bash
curl -X POST "https://backend.valeincorp.com.br/api/favoritos" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer TOKEN_AQUI" \
  -d '{
    "imovelId": 1
  }'
```

**✅ Response (201):**
```json
{
    "success": true,
    "message": "Imóvel adicionado aos favoritos",
    "data": {
        "id": 1,
        "imovelId": 1,
        "userId": 1,
        "favoritadoEm": "2025-08-06T15:45:00Z"
    }
}
```

---

### **11. FAVORITOS - Remover**

```bash
curl -X DELETE "https://backend.valeincorp.com.br/api/favoritos/1" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer TOKEN_AQUI"
```

**✅ Response (200):**
```json
{
    "success": true,
    "message": "Imóvel removido dos favoritos"
}
```

---

### **12. BUSCA - Cidades Disponíveis**

```bash
curl -X GET "https://backend.valeincorp.com.br/api/cidades" \
  -H "Content-Type: application/json"
```

**✅ Response (200):**
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
        "Porto Alegre",
        "Caxias do Sul"
    ]
}
```

---

### **13. BUSCA - Filtros Avançados**

```bash
curl -X POST "https://backend.valeincorp.com.br/api/buscar" \
  -H "Content-Type: application/json" \
  -d '{
    "localizacao": ["São Paulo", "Rio de Janeiro"],
    "valorDe": 800000,
    "valorAte": 1500000,
    "metragemDe": 100,
    "metragemAte": 200,
    "dormitorios": 3,
    "banheiros": 2,
    "suites": 1,
    "vagasGaragem": 2,
    "status": ["pronto", "na_planta"],
    "page": 1,
    "limit": 20
  }'
```

**✅ Response (200):**
```json
{
    "success": true,
    "data": [
        {
            "id": 1,
            "codigo": "VIC001",
            "nome": "Residencial Vista Bela",
            "imagem": "https://exemplo.com/imoveis/residencial_vista_bela.jpg",
            "localizacao": "Vila Madalena - São Paulo",
            "preco": 1200000,
            "precoFormatado": "R$ 1.200.000,00",
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
        "totalPages": 1,
        "totalItems": 1,
        "itemsPerPage": 20
    },
    "filtrosAplicados": {
        "valorDe": 800000,
        "valorAte": 1500000,
        "dormitorios": 3,
        "status": ["pronto", "na_planta"]
    }
}
```

---

### **14. CONSTRUTORAS - Listar**

```bash
curl -X GET "https://backend.valeincorp.com.br/api/construtoras" \
  -H "Content-Type: application/json"
```

**✅ Response (200):**
```json
{
    "success": true,
    "data": [
        {
            "id": 1,
            "nome": "Vale Incorp",
            "logo": "https://exemplo.com/logos/vale_incorp.png",
            "descricao": "Construtora especializada em empreendimentos residenciais de alto padrão",
            "totalEmpreendimentos": 25,
            "empreendimentosAtivos": 8,
            "createdAt": "2020-01-15T10:00:00Z"
        }
    ]
}
```

---

### **15. UPLOAD - Arquivo (Requer Token)**

```bash
curl -X POST "https://backend.valeincorp.com.br/api/upload" \
  -H "Authorization: Bearer TOKEN_AQUI" \
  -F "file=@/caminho/para/imagem.jpg"
```

**✅ Response (200):**
```json
{
    "success": true,
    "message": "Arquivo enviado com sucesso",
    "data": {
        "id": 1,
        "filename": "imagem_123.jpg",
        "originalName": "imagem.jpg",
        "mimeType": "image/jpeg",
        "size": 2048576,
        "url": "https://exemplo.com/uploads/imagem_123.jpg",
        "uploadedAt": "2025-08-06T16:00:00Z"
    }
}
```

---

## 🔐 **Autenticação - Exemplos Práticos**

### **Fluxo Completo de Autenticação:**

```bash
# 1. Registrar usuário
TOKEN_RESPONSE=$(curl -s -X POST "https://backend.valeincorp.com.br/api/auth/register" \
  -H "Content-Type: application/json" \
  -d '{"nomeCompleto":"João Silva","email":"joao@email.com","cpfCnpj":"123.456.789-00","senha":"123456","confirmarSenha":"123456"}')

# 2. Extrair token (usando jq)
TOKEN=$(echo $TOKEN_RESPONSE | jq -r '.token')

# 3. Usar token em requisições autenticadas
curl -X GET "https://backend.valeincorp.com.br/api/users/profile" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN"
```

---

## ⚠️ **Tratamento de Erros**

### **Token Inválido/Expirado (401):**
```json
{
    "message": "Unauthenticated."
}
```

### **Dados Inválidos (422):**
```json
{
    "success": false,
    "message": "Dados inválidos",
    "errors": {
        "email": ["O campo email é obrigatório."],
        "senha": ["O campo senha deve ter pelo menos 6 caracteres."]
    }
}
```

### **Recurso Não Encontrado (404):**
```json
{
    "success": false,
    "message": "Imóvel não encontrado"
}
```

### **Erro Interno do Servidor (500):**
```json
{
    "success": false,
    "message": "Erro interno do servidor"
}
```

---

## 📊 **Resumo de Status**

| Endpoint | Status | Autenticação | Observações |
|----------|--------|--------------|-------------|
| `/api/health` | ✅ | Não | Sistema |
| `/api/config` | ✅ | Não | Sistema |
| `/api/auth/login` | ✅ | Não | Autenticação |
| `/api/auth/register` | ✅ | Não | Autenticação |
| `/api/users/profile` | ✅ | Sim | Perfil |
| `/api/imoveis` | ✅ | Não | Listagem |
| `/api/imoveis/{id}` | ✅ | Não | Detalhes |
| `/api/favoritos` | ✅ | Sim | CRUD Favoritos |
| `/api/cidades` | ✅ | Não | Filtros |
| `/api/construtoras` | ✅ | Não | Construtoras |
| `/api/upload` | ✅ | Sim | Upload |

---

## 🚀 **Deploy e Configuração**

### **Variáveis de Ambiente Necessárias:**
```env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=valeincorp
DB_USERNAME=root
DB_PASSWORD=senha

SANCTUM_STATEFUL_DOMAINS=seu-dominio.com
SESSION_DOMAIN=.seu-dominio.com
```

### **Comandos Pós-Deploy:**
```bash
composer install --optimize-autoloader --no-dev
php artisan config:cache
php artisan route:cache
php artisan migrate --force
```

---

**📱 APIs 100% prontas para integração com o app mobile Vale Incorp!**