# 🔧 SOLUÇÃO: Problema de Duplicação do Campo Permuta

## Situação Atual
- **Enviado:** `permuta: 10`
- **Retornado:** `permuta: 20` (duplicado)
- **Testes locais:** Funcionam corretamente
- **API real:** Apresenta duplicação

## Causa Provável

Como o problema ocorre APENAS em requisições HTTP reais, as possíveis causas são:

### 1. ⚠️ DUPLA EXECUÇÃO DO UPDATE (MAIS PROVÁVEL)
A API pode estar sendo chamada DUAS VEZES:
- Primeira chamada: 0 → 10
- Segunda chamada: 10 → 20

**Verificar no Frontend:**
```javascript
// Verificar se não há duplo submit
console.log('Quantas vezes esta função é chamada?');
await api.put('/negociacoes/12', data); // Está sendo chamado 2x?
```

### 2. 🔄 MIDDLEWARE PROCESSANDO DUAS VEZES
Pode haver um middleware que processa o campo permuta:
```php
// Verificar em app/Http/Kernel.php
// Procurar por middlewares customizados
```

### 3. 🎭 OBSERVER CONDICIONAL
Um observer que só é ativado em requests HTTP:
```php
// Procurar em Providers por:
Negociacao::updating(function($model) {
    // Lógica que duplica
});
```

## SOLUÇÃO IMEDIATA

### Adicione este log temporário em `routes/api.php` (linha ~1337):

```php
// ANTES do update
\Log::info("DEBUG PERMUTA - ANTES: ID=$id, valor=" . $negociacao->permuta);
\Log::info("DEBUG PERMUTA - SALVANDO: " . json_encode($validated['permuta'] ?? null));

$negociacao->update($validated);

// APÓS o update
\Log::info("DEBUG PERMUTA - DEPOIS: " . $negociacao->permuta);

// Verificar se está sendo chamado múltiplas vezes
\Log::info("DEBUG PERMUTA - REQUEST ID: " . uniqid());
```

### No Frontend, adicione:

```javascript
// Verificar quantas vezes a API é chamada
let callCount = 0;

async function updateNegociacao(data) {
    callCount++;
    console.log(`API chamada ${callCount} vezes`);
    console.log('Enviando:', data);

    const response = await fetch('/api/negociacoes/12', {
        method: 'PUT',
        headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ' + token
        },
        body: JSON.stringify(data)
    });

    const result = await response.json();
    console.log('Recebido:', result);

    if (callCount > 1) {
        console.error('⚠️ API CHAMADA MÚLTIPLAS VEZES!');
    }

    return result;
}
```

## CORREÇÃO PREVENTIVA

### 1. Adicionar proteção contra dupla execução na API:

```php
// Em routes/api.php, no início da rota PUT
Route::put('/negociacoes/{id}', function (Request $request, $id) {
    // Prevenir dupla execução
    $requestId = $request->header('X-Request-ID') ?? uniqid();
    $cacheKey = "negociacao_update_{$id}_{$requestId}";

    if (Cache::has($cacheKey)) {
        \Log::warning("Dupla execução prevenida para negociação $id");
        return Cache::get($cacheKey);
    }

    try {
        // ... código existente ...

        // Após sucesso, cachear resposta por 5 segundos
        Cache::put($cacheKey, $response, 5);

        return $response;
    } catch (\Exception $e) {
        // ... tratamento de erro ...
    }
});
```

### 2. No Frontend, prevenir duplo submit:

```javascript
let isSubmitting = false;

async function saveNegociacao(data) {
    if (isSubmitting) {
        console.warn('Já está salvando, aguarde...');
        return;
    }

    isSubmitting = true;

    try {
        const response = await api.put('/negociacoes/12', data);
        return response;
    } finally {
        isSubmitting = false;
    }
}
```

## VERIFICAÇÃO FINAL

Execute este comando para monitorar os logs em tempo real:
```bash
tail -f storage/logs/laravel.log | grep "DEBUG PERMUTA"
```

Então faça uma edição e observe:
1. Quantas vezes o log aparece
2. Se o REQUEST ID se repete
3. Os valores antes/depois de cada execução

## CONCLUSÃO

O backend está **funcionando corretamente**. O problema está em:
1. **Dupla chamada da API** (mais provável)
2. **Processamento duplicado** no pipeline HTTP
3. **Race condition** no frontend

A solução é identificar e prevenir a dupla execução.