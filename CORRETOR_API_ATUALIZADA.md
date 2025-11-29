# 👤 API de Corretor - Atualização Completa dos Dados

## 🎯 **Implementação Realizada**

Atualizei a API de perfil do corretor para permitir edição de todos os campos solicitados: **nome, email, telefone, cpf, creci, documento e foto**.

## 📋 **Alterações no UserController.php:**

### **1. Campos Editáveis Expandidos:**
```php
'nome' => 'sometimes|required|string|max:255',
'email' => 'sometimes|required|email|unique:corretores,email,' . $user->id,
'telefone' => 'nullable|string|max:20',
'cpf' => 'nullable|string|max:20',
'creci' => 'nullable|string|max:255',
'documento' => 'nullable|file|mimes:pdf,doc,docx,jpg,jpeg,png|max:5120',
```

### **2. Upload de Documento:**
- ✅ Aceita arquivos: PDF, DOC, DOCX, JPG, JPEG, PNG
- ✅ Limite de 5MB por arquivo
- ✅ Salva URL no campo `documento_url`

### **3. Upload de Foto (Avatar):**
- ✅ Endpoint `/api/users/upload-avatar` já implementado
- ✅ Salva URL no campo `avatar_url`
- ✅ Aceita imagens: JPEG, PNG, JPG, GIF

## 🔗 **Endpoints Disponíveis:**

### **1. Ver Perfil:**
```bash
curl -X GET "https://backend.valeincorp.com.br/api/users/profile" \
  -H "Authorization: Bearer SEU_TOKEN_AQUI"
```

### **2. Atualizar Perfil (Dados + Documento):**
```bash
curl -X PUT "https://backend.valeincorp.com.br/api/users/profile" \
  -H "Authorization: Bearer SEU_TOKEN_AQUI" \
  -F "nome=João Silva Santos" \
  -F "email=joao.silva@email.com" \
  -F "telefone=51999999999" \
  -F "cpf=12345678901" \
  -F "creci=CRECI12345-RS" \
  -F "documento=@/path/to/documento.pdf"
```

### **3. Upload de Foto de Perfil:**
```bash
curl -X POST "https://backend.valeincorp.com.br/api/users/upload-avatar" \
  -H "Authorization: Bearer SEU_TOKEN_AQUI" \
  -F "avatar=@/path/to/foto.jpg"
```

## ✅ **Resposta da API de Perfil:**

```json
{
    "success": true,
    "user": {
        "id": 1,
        "nome": "João Silva Santos",
        "email": "joao.silva@email.com",
        "creci": "CRECI12345-RS",
        "telefone": "51999999999",
        "cpfCnpj": "12345678901",
        "documento": "https://backend.valeincorp.com.br/storage/documentos/user_1_documento_1723056000.pdf",
        "isPessoaJuridica": false,
        "fotoUsuario": "https://backend.valeincorp.com.br/storage/avatars/user_1_avatar.jpg",
        "createdAt": "2025-08-06T10:00:00.000000Z",
        "updatedAt": "2025-08-06T15:30:45.000000Z"
    }
}
```

## 🔒 **Validações Implementadas:**

### **Email Único:**
- ✅ Permite atualizar email do próprio usuário
- ✅ Impede usar email já cadastrado por outro usuário
- ✅ Validação: `unique:corretores,email,{user_id}`

### **Tipos de Documento:**
- ✅ PDF para documentos oficiais
- ✅ DOC/DOCX para documentos editáveis  
- ✅ JPG/JPEG/PNG para documentos escaneados
- ✅ Máximo 5MB por arquivo

### **Foto de Perfil:**
- ✅ Apenas imagens: JPEG, PNG, JPG, GIF
- ✅ Máximo 2MB
- ✅ Gera nome único para evitar conflitos

## 📝 **Exemplos de Uso:**

### **1. Atualizar Apenas Nome e Telefone:**
```bash
curl -X PUT "https://backend.valeincorp.com.br/api/users/profile" \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"nome": "João Santos", "telefone": "51988887777"}'
```

### **2. Atualizar Email:**
```bash
curl -X PUT "https://backend.valeincorp.com.br/api/users/profile" \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"email": "novo.email@email.com"}'
```

### **3. Atualizar CPF e CRECI:**
```bash
curl -X PUT "https://backend.valeincorp.com.br/api/users/profile" \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"cpf": "98765432100", "creci": "CRECI54321-SP"}'
```

### **4. Upload de Documento (Multipart):**
```bash
curl -X PUT "https://backend.valeincorp.com.br/api/users/profile" \
  -H "Authorization: Bearer TOKEN" \
  -F "documento=@documento.pdf"
```

## 🎨 **Frontend - Campos do Formulário:**

```html
<form enctype="multipart/form-data">
  <input name="nome" type="text" placeholder="Nome Completo" />
  <input name="email" type="email" placeholder="E-mail" />
  <input name="telefone" type="text" placeholder="Telefone" />
  <input name="cpf" type="text" placeholder="CPF" />
  <input name="creci" type="text" placeholder="CRECI" />
  <input name="documento" type="file" accept=".pdf,.doc,.docx,.jpg,.jpeg,.png" />
  <button type="submit">Atualizar Perfil</button>
</form>

<!-- Formulário separado para foto -->
<form enctype="multipart/form-data" action="/api/users/upload-avatar">
  <input name="avatar" type="file" accept="image/*" />
  <button type="submit">Atualizar Foto</button>
</form>
```

## 🚨 **Mensagens de Erro:**

### **Email já existe:**
```json
{
    "success": false,
    "message": "Dados inválidos",
    "errors": {
        "email": ["The email has already been taken."]
    }
}
```

### **Arquivo muito grande:**
```json
{
    "success": false,
    "message": "Dados inválidos",
    "errors": {
        "documento": ["The documento may not be greater than 5120 kilobytes."]
    }
}
```

### **Formato inválido:**
```json
{
    "success": false,
    "message": "Dados inválidos",
    "errors": {
        "documento": ["The documento must be a file of type: pdf, doc, docx, jpg, jpeg, png."]
    }
}
```

## 📂 **Estrutura de Arquivos:**

```
storage/
├── avatars/           # Fotos de perfil
│   └── user_1_avatar.jpg
└── documentos/        # Documentos dos corretores
    └── user_1_documento_1723056000.pdf
```

## ✅ **Status dos Campos:**

| Campo | Status | Validação | Obrigatório |
|-------|--------|-----------|-------------|
| `nome` | ✅ | string, max:255 | ✅ |
| `email` | ✅ | email, unique | ✅ |
| `telefone` | ✅ | string, max:20 | ❌ |
| `cpf` | ✅ | string, max:20 | ❌ |
| `creci` | ✅ | string, max:255 | ❌ |
| `documento` | ✅ | file, 5MB max | ❌ |
| `foto` | ✅ | image, 2MB max | ❌ |

## 🔄 **Fluxo Completo:**

1. **Ver perfil atual:** `GET /api/users/profile`
2. **Atualizar dados:** `PUT /api/users/profile`
3. **Upload foto:** `POST /api/users/upload-avatar`
4. **Ver perfil atualizado:** `GET /api/users/profile`

## 🎯 **Benefícios:**

- ✅ **Flexibilidade:** Atualiza apenas os campos enviados
- ✅ **Segurança:** Email único, validações robustas
- ✅ **Usabilidade:** Upload de documentos e fotos
- ✅ **Performance:** Não requer reenvio de todos os dados
- ✅ **Compatibilidade:** Mantém formato de resposta existente

**✅ API do Corretor totalmente funcional com edição de todos os campos solicitados!**