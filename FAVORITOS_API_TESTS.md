# ❤️ API de Favoritos - Testes Completos e Respostas

## 📋 **Setup Implementado**

### **🗄️ Migration Criada:**
- **Arquivo:** `database/migrations/2025_08_06_185000_create_favoritos_table.php`
- **Tabela:** `favoritos`
- **Relacionamentos:** `corretor_id` → `corretores.id`, `empreendimento_id` → `empreendimentos.id`
- **Índices:** Otimizados para performance
- **Constraint:** UNIQUE para evitar favoritos duplicados

### **📱 Model Atualizado:**
- **Arquivo:** `app/Models/Favorito.php`
- **Funcionalidades:** Relacionamentos, scopes, métodos auxiliares

### **🎮 Controller Funcional:**
- **Arquivo:** `app/Http/Controllers/API/FavoritoController.php`
- **5 endpoints** completamente implementados

### **🛣️ Rotas Atualizadas:**
- **Arquivo:** `routes/vale_incorp_api.php`
- **Conectadas ao controller funcional**

---

## 🧪 **Testes dos Endpoints**

### **Base URL:** `https://backend.valeincorp.com.br/api`
### **Autenticação:** Bearer Token (obrigatório para todos os endpoints)

---

### **1. 📋 Listar Favoritos**

**Endpoint:** `GET /api/favoritos`

```bash
curl -X GET "https://backend.valeincorp.com.br/api/favoritos?page=1&limit=10" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer SEU_TOKEN_AQUI"
```

**✅ Response (200) - Com Favoritos:**
```json
{
    "success": true,
    "data": [
        {
            "id": 1,
            "imovelId": 2,
            "imovel": {
                "id": 2,
                "codigo": "VIC002",
                "nome": "CITTÀ SIENA RESIDENCIAL",
                "imagem": "https://backend.valeincorp.com.br/storage/unidades/foto_HkT4zvUX9bEOswnt4bdPnmL6kdRR3Ni0BOsde7ci.jpg",
                "localizacao": "Rondônia - Novo Hamburgo",
                "cidade": "Novo Hamburgo",
                "preco": 1000000,
                "precoFormatado": "R$ 1.000.000,00",
                "status": "100% Vendido",
                "dormitorios": 3,
                "banheiros": 2,
                "area": 120,
                "vagas": 2
            },
            "favoritadoEm": "2025-08-06T18:30:00.000000Z"
        },
        {
            "id": 2,
            "imovelId": 7,
            "imovel": {
                "id": 7,
                "codigo": "VIC007",
                "nome": "CITTÀ RESIDENCIAL",
                "imagem": "https://backend.valeincorp.com.br/storage/unidades/foto_1WI6Pb4PFCRTdSjrpMeyKFvy9YBYKvMhKEYlVLw7.jpg",
                "localizacao": "Vila Nova - Novo Hamburgo",
                "cidade": "Novo Hamburgo",
                "preco": 1000000,
                "precoFormatado": "R$ 1.000.000,00",
                "status": "100% Vendido",
                "dormitorios": 3,
                "banheiros": 2,
                "area": 120,
                "vagas": 2
            },
            "favoritadoEm": "2025-08-06T17:15:00.000000Z"
        }
    ],
    "pagination": {
        "currentPage": 1,
        "totalPages": 1,
        "totalItems": 2,
        "itemsPerPage": 10,
        "hasNextPage": false,
        "hasPreviousPage": false
    }
}
```

**✅ Response (200) - Sem Favoritos:**
```json
{
    "success": true,
    "data": [],
    "pagination": {
        "currentPage": 1,
        "totalPages": 1,
        "totalItems": 0,
        "itemsPerPage": 10,
        "hasNextPage": false,
        "hasPreviousPage": false
    }
}
```

---

### **2. ➕ Adicionar aos Favoritos**

**Endpoint:** `POST /api/favoritos`

```bash
curl -X POST "https://backend.valeincorp.com.br/api/favoritos" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer SEU_TOKEN_AQUI" \
  -d '{
    "imovelId": 2
  }'
```

**✅ Response (201) - Sucesso:**
```json
{
    "success": true,
    "message": "Imóvel adicionado aos favoritos com sucesso",
    "data": {
        "id": 1,
        "imovelId": 2,
        "userId": 1,
        "favoritadoEm": "2025-08-06T18:30:00.000000Z"
    }
}
```

**❌ Response (409) - Já é Favorito:**
```json
{
    "success": false,
    "message": "Este imóvel já está nos seus favoritos"
}
```

**❌ Response (422) - Dados Inválidos:**
```json
{
    "success": false,
    "message": "The given data was invalid.",
    "errors": {
        "imovelId": [
            "O campo imovel id é obrigatório.",
            "O campo imovel id deve ser um número inteiro.",
            "O campo imovel id selecionado é inválido."
        ]
    }
}
```

---

### **3. ➖ Remover dos Favoritos**

**Endpoint:** `DELETE /api/favoritos/{imovelId}`

```bash
curl -X DELETE "https://backend.valeincorp.com.br/api/favoritos/2" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer SEU_TOKEN_AQUI"
```

**✅ Response (200) - Sucesso:**
```json
{
    "success": true,
    "message": "Imóvel removido dos favoritos com sucesso"
}
```

**❌ Response (404) - Não é Favorito:**
```json
{
    "success": false,
    "message": "Este imóvel não está nos seus favoritos"
}
```

---

### **4. ✅ Verificar se é Favorito**

**Endpoint:** `GET /api/favoritos/check/{imovelId}`

```bash
curl -X GET "https://backend.valeincorp.com.br/api/favoritos/check/2" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer SEU_TOKEN_AQUI"
```

**✅ Response (200) - É Favorito:**
```json
{
    "success": true,
    "isFavorito": true,
    "data": {
        "imovelId": 2,
        "userId": 1,
        "isFavorito": true
    }
}
```

**✅ Response (200) - Não é Favorito:**
```json
{
    "success": true,
    "isFavorito": false,
    "data": {
        "imovelId": 2,
        "userId": 1,
        "isFavorito": false
    }
}
```

---

### **5. 🔢 Contar Total de Favoritos**

**Endpoint:** `GET /api/favoritos/count`

```bash
curl -X GET "https://backend.valeincorp.com.br/api/favoritos/count" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer SEU_TOKEN_AQUI"
```

**✅ Response (200):**
```json
{
    "success": true,
    "data": {
        "totalFavoritos": 5
    }
}
```

---

## 🔧 **Filtros e Parâmetros**

### **Listagem com Paginação:**
```bash
# Página 2 com 5 itens por página
/api/favoritos?page=2&limit=5

# Primeira página com 20 itens
/api/favoritos?page=1&limit=20
```

---

## ⚠️ **Tratamento de Erros**

### **Token Inválido/Expirado (401):**
```json
{
    "message": "Unauthenticated."
}
```

### **Imóvel Não Encontrado (422):**
```json
{
    "success": false,
    "message": "The given data was invalid.",
    "errors": {
        "imovelId": [
            "O campo imovel id selecionado é inválido."
        ]
    }
}
```

### **Erro do Servidor (500):**
```json
{
    "success": false,
    "message": "Erro ao remover imóvel dos favoritos"
}
```

---

## 🚀 **Deploy no VPS**

### **1. Arquivos para Upload:**
```bash
database/migrations/2025_08_06_185000_create_favoritos_table.php
app/Models/Favorito.php
app/Http/Controllers/API/FavoritoController.php
routes/vale_incorp_api.php (atualizado)
```

### **2. Comandos no Servidor:**
```bash
# Executar migration
php artisan migrate --path=database/migrations/2025_08_06_185000_create_favoritos_table.php

# Limpar cache
php artisan route:clear
php artisan config:clear

# Verificar rotas
php artisan route:list | grep favoritos
```

---

## 📊 **Resumo dos Endpoints**

| Método | Endpoint | Função | Auth |
|--------|----------|--------|------|
| `GET` | `/api/favoritos` | Listar favoritos | ✅ |
| `POST` | `/api/favoritos` | Adicionar favorito | ✅ |
| `DELETE` | `/api/favoritos/{id}` | Remover favorito | ✅ |
| `GET` | `/api/favoritos/check/{id}` | Verificar se é favorito | ✅ |
| `GET` | `/api/favoritos/count` | Contar total | ✅ |

---

## ✅ **Status Final**

- ✅ **Migration:** Tabela criada com relacionamentos e índices
- ✅ **Model:** Completo com métodos auxiliares
- ✅ **Controller:** 5 endpoints funcionais implementados
- ✅ **Rotas:** Conectadas ao controller
- ✅ **Validação:** Dados de entrada validados
- ✅ **Segurança:** Autenticação obrigatória
- ✅ **Performance:** Eager loading nos relacionamentos
- ✅ **Respostas:** Formatadas conforme padrão da API

**🎯 Sistema de Favoritos 100% implementado e pronto para uso!**