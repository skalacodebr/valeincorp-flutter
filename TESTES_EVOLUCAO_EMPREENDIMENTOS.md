# Testes - Evolução da Obra em Empreendimentos

## ✅ Implementações Concluídas

### 1. **Migration** ✅
- ✅ Adicionada coluna `evolucao` (JSON) na tabela `empreendimentos`
- ✅ Comentário descritivo na coluna
- ✅ Método `down()` para rollback

### 2. **Model Empreendimento** ✅
- ✅ Adicionado `evolucao` ao `$fillable`
- ✅ Cast `evolucao => array` implementado
- ✅ Accessor `evolucaoCompleta` implementado
- ✅ Método `evolucoesDaObra()` implementado

### 3. **Controller EmpreendimentoController** ✅
- ✅ Validação de `evolucoes` (string JSON) nos métodos `store` e `update`
- ✅ Processamento e validação de evoluções
- ✅ Método `validateEvolucoes()` privado implementado
- ✅ Método `getEvolucoes()` implementado
- ✅ Respostas incluem dados de evolução

### 4. **Rotas** ✅
- ✅ Nova rota: `GET /api/empreendimentos/{id}/evolucoes`

---

## 🧪 Testes para Executar

### **Teste 1: Criar Empreendimento com Evoluções**

```bash
POST /api/empreendimentos
Content-Type: application/json

{
    "nome": "Residencial Vista Bela",
    "area_lazer": true,
    "observacoes": "Empreendimento teste",
    "evolucoes": "[{\"id\":1,\"percentual_conclusao\":45},{\"id\":2,\"percentual_conclusao\":78}]"
}
```

**Resposta Esperada:**
```json
{
    "message": "Empreendimento criado com sucesso",
    "data": {
        "id": 1,
        "nome": "Residencial Vista Bela",
        "evolucao": [
            {"id": 1, "percentual_conclusao": 45},
            {"id": 2, "percentual_conclusao": 78}
        ]
    },
    "evolucoes": [
        {
            "id": 1,
            "percentual_conclusao": 45,
            "nome": "Fundação",
            "data_criacao": "2025-01-15"
        }
    ]
}
```

### **Teste 2: Atualizar Empreendimento com Novas Evoluções**

```bash
PUT /api/empreendimentos/1
Content-Type: application/json

{
    "nome": "Residencial Vista Bela Atualizado",
    "evolucoes": "[{\"id\":1,\"percentual_conclusao\":60},{\"id\":3,\"percentual_conclusao\":25}]"
}
```

### **Teste 3: Buscar Evoluções de um Empreendimento**

```bash
GET /api/empreendimentos/1/evolucoes
```

**Resposta Esperada:**
```json
{
    "data": [
        {
            "id": 1,
            "nome": "Fundação",
            "data_criacao": "2025-01-15",
            "percentual_conclusao": 60,
            "empreendimento_id": 1
        },
        {
            "id": 3,
            "nome": "Estrutura",
            "data_criacao": "2025-01-20",
            "percentual_conclusao": 25,
            "empreendimento_id": 1
        }
    ]
}
```

### **Teste 4: Remover Evoluções (Array Vazio)**

```bash
PUT /api/empreendimentos/1
Content-Type: application/json

{
    "evolucoes": "[]"
}
```

### **Teste 5: Validações - IDs Inválidos**

```bash
POST /api/empreendimentos
Content-Type: application/json

{
    "nome": "Teste Validação",
    "area_lazer": false,
    "evolucoes": "[{\"id\":999,\"percentual_conclusao\":50}]"
}
```

**Comportamento:** ID 999 será ignorado se não existir

### **Teste 6: Validações - Percentuais Inválidos**

```bash
POST /api/empreendimentos
Content-Type: application/json

{
    "nome": "Teste Percentual",
    "area_lazer": false,
    "evolucoes": "[{\"id\":1,\"percentual_conclusao\":150}]"
}
```

**Comportamento:** Percentual será limitado a 100

---

## 🔧 Comandos para Testar Localmente

### 1. Executar Migration
```bash
php artisan migrate
```

### 2. Verificar Estrutura da Tabela
```sql
DESCRIBE empreendimentos;
```

### 3. Testar com Artisan Tinker
```bash
php artisan tinker
```

```php
// Criar empreendimento com evoluções
$emp = App\Models\Empreendimento::create([
    'nome' => 'Teste Tinker',
    'area_lazer' => true,
    'evolucao' => [
        ['id' => 1, 'percentual_conclusao' => 45],
        ['id' => 2, 'percentual_conclusao' => 78]
    ]
]);

// Verificar dados
$emp->evolucao;
$emp->evolucaoCompleta;
```

---

## 🚨 Problemas Conhecidos e Soluções

### Problema 1: "could not find driver"
**Solução:** Instalar driver MySQL
```bash
# Ubuntu/Debian
sudo apt-get install php-mysql php-pdo-mysql
sudo systemctl restart apache2

# Windows/XAMPP
# Descomentar ;extension=pdo_mysql no php.ini
```

### Problema 2: Migration não roda
**Solução:** Verificar configuração do banco em `.env`
```env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=valeincorp
DB_USERNAME=root
DB_PASSWORD=senha
```

---

## 📊 Estrutura JSON Esperada

### **Formato de Entrada (Frontend → Backend)**
```javascript
// String JSON enviada no campo 'evolucoes'
const evolucoes = JSON.stringify([
    {id: 1, percentual_conclusao: 45},
    {id: 2, percentual_conclusao: 78}
]);

// Envio via FormData ou JSON
fetch('/api/empreendimentos', {
    method: 'POST',
    headers: {'Content-Type': 'application/json'},
    body: JSON.stringify({
        nome: 'Residencial Teste',
        area_lazer: true,
        evolucoes: evolucoes
    })
});
```

### **Formato Armazenado (Banco de Dados)**
```json
[
    {"id": 1, "percentual_conclusao": 45},
    {"id": 2, "percentual_conclusao": 78}
]
```

### **Formato de Saída (Backend → Frontend)**
```json
{
    "evolucoes": [
        {
            "id": 1,
            "percentual_conclusao": 45,
            "nome": "Fundação",
            "data_criacao": "2025-01-15"
        }
    ]
}
```

---

## 🎯 Status Final

✅ **Implementação:** 100% Concluída  
⚠️ **Testes:** Aguardando configuração do banco de dados  
✅ **Documentação:** Completa  

**Próximo Passo:** Configurar ambiente de banco de dados para testes práticos.