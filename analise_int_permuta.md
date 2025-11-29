# Análise: Campo PERMUTA tipo INT

## Situação Atual

### ✅ Estrutura do Banco (CORRETA)
```sql
Campo: permuta
Tipo: int(11)  -- Armazena valores inteiros de -2147483648 a 2147483647
Null: YES
Default: NULL
```

### ✅ Comportamento Esperado com INT

| Valor Enviado | Valor Salvo (INT) | Status |
|--------------|-------------------|--------|
| 10 | 10 | ✅ Correto |
| 40 | 40 | ✅ Correto |
| 40.5 | 41 | ✅ Normal (arredondamento) |
| 100 | 100 | ✅ Correto |

### ❌ Problema Identificado

| Valor Enviado | Valor Esperado | Valor Salvo | Problema |
|--------------|----------------|-------------|----------|
| 40 | 40 | **16** | ❌ Conversão indevida |

**Cálculo suspeito:** `40 * 0.4 = 16`

## Análise da Conversão 40 → 16

### 1. O que NÃO é o problema:
- ❌ **Não é o tipo INT** - INT funciona corretamente
- ❌ **Não é o banco de dados** - Testes diretos SQL salvam 40 corretamente
- ❌ **Não é o modelo Eloquent** - Model salva corretamente quando testado isoladamente
- ❌ **Não há triggers no banco** - Verificado e confirmado

### 2. Onde pode estar o problema:

#### A) Frontend (MAIS PROVÁVEL)
```javascript
// Possíveis erros no JavaScript:

// Erro 1: Aplicando percentual incorretamente
const permuta = valorOriginal * 0.4;  // 40 * 0.4 = 16

// Erro 2: Conversão de unidade errada
const permuta = (percentual / 100) * 40;  // (40/100) * 40 = 16

// Erro 3: Aplicando desconto
const permuta = valor * (1 - 0.6);  // 40 * 0.4 = 16
```

#### B) Middleware/Interceptor
- Algum middleware pode estar interpretando permuta como percentual
- Pode haver um transformer aplicando fator de conversão

#### C) Regra de Negócio
- Pode existir uma regra que aplica 40% sobre o valor
- Comissão ou desconto sendo aplicado incorretamente

## Como Identificar o Problema

### 1. Teste Direto via CURL
```bash
# Este teste bypassa o frontend completamente
curl -X PUT "https://backend.valeincorp.com.br/api/negociacoes/12" \
-H "Content-Type: application/json" \
-H "Authorization: Bearer TOKEN" \
-d '{"permuta": 40}'
```

**Se retornar 40:** Problema está no frontend
**Se retornar 16:** Problema está no backend

### 2. Verificar no Frontend

#### No Console do Navegador (F12):
```javascript
// Ver o que está sendo enviado
console.log('Valor antes de enviar:', permuta);

// Interceptar o fetch/axios
const originalFetch = window.fetch;
window.fetch = function(...args) {
    console.log('Request:', args);
    return originalFetch.apply(this, args);
};
```

#### Na Aba Network:
1. Filtrar por "negociacoes"
2. Clicar no request PUT
3. Ver aba "Payload" ou "Request"
4. Verificar se `permuta: 40` ou `permuta: 16`

### 3. Debug no Backend

Adicione em `routes/api.php` (linha ~1286):
```php
\Log::info("PERMUTA DEBUG - Recebido: " . json_encode([
    'raw' => $request->getContent(),
    'input' => $request->input('permuta'),
    'all' => $request->all()
]));
```

## Soluções

### Se o problema for no Frontend:
1. Procurar por `* 0.4` ou `* 0.40` no código JavaScript
2. Verificar funções de formatação/conversão
3. Checar se há transforms no Axios/Fetch

### Se o problema for no Backend:
1. Verificar middlewares em `app/Http/Kernel.php`
2. Procurar por observers do modelo Negociacao
3. Verificar se há algum service/helper processando o valor

## Recomendação Imediata

### Teste Isolado
```php
// Criar arquivo: test_permuta_isolado.php
<?php
require_once __DIR__ . '/vendor/autoload.php';
$app = require_once __DIR__ . '/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

use App\Models\Negociacao;
use Illuminate\Support\Facades\DB;

// Teste 1: SQL Direto
DB::statement("UPDATE negociacoes SET permuta = 40 WHERE id = 12");
$result = DB::select("SELECT permuta FROM negociacoes WHERE id = 12")[0];
echo "SQL Direto: " . $result->permuta . "\n";  // Deve mostrar 40

// Teste 2: Eloquent
$negociacao = Negociacao::find(12);
$negociacao->permuta = 40;
$negociacao->save();
$negociacao->refresh();
echo "Eloquent: " . $negociacao->permuta . "\n";  // Deve mostrar 40

// Se ambos mostrarem 40, o problema está no frontend ou na API
```

## Conclusão

O campo sendo **INT está correto** para armazenar percentuais inteiros (0-100).

O problema **40 → 16** indica uma **multiplicação por 0.4** acontecendo em algum ponto do fluxo, provavelmente:
1. **Frontend aplicando conversão** (mais provável)
2. **Middleware/Transformer** no request
3. **Regra de negócio** mal implementada

**Próximo passo:** Execute o teste via CURL para isolar se o problema está no frontend ou backend.