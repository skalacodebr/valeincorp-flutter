# Exemplos de Teste da API - Campo Permuta

## 1. Exemplo com CURL (Teste via Terminal)

### Enviando permuta = 40
```bash
curl -X PUT "https://backend.valeincorp.com.br/api/negociacoes/12" \
-H "Accept: application/json" \
-H "Content-Type: application/json" \
-H "Authorization: Bearer SEU_TOKEN_AQUI" \
-d '{
  "permuta": 40,
  "distratado": false
}'
```

### Resposta Esperada (Correta)
```json
{
  "id": 12,
  "permuta": 40,
  "valorPermuta": 40,
  "distratado": false,
  "valor_contrato": 100.00,
  // ... outros campos
}
```

### Resposta com Problema (40 → 16)
```json
{
  "id": 12,
  "permuta": 16,        // ❌ Problema: deveria ser 40
  "valorPermuta": 16,   // ❌ Calculado com base em 16
  "distratado": false,
  "valor_contrato": 100.00,
  // ... outros campos
}
```

## 2. Exemplo JavaScript (Frontend)

### Código de Envio Correto
```javascript
// ✅ FORMA CORRETA
async function atualizarPermuta() {
  const data = {
    permuta: 40,           // Enviando como número
    distratado: false
  };

  const response = await fetch('https://backend.valeincorp.com.br/api/negociacoes/12', {
    method: 'PUT',
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ' + token
    },
    body: JSON.stringify(data)
  });

  const result = await response.json();

  console.log('Enviado:', data);
  console.log('Recebido:', result);

  // Verificar se houve conversão indevida
  if (data.permuta !== result.permuta) {
    console.error('⚠️ PROBLEMA: Permuta enviada:', data.permuta, 'Recebida:', result.permuta);
  }
}
```

### Possíveis Problemas no Frontend

```javascript
// ❌ PROBLEMA 1: Conversão acidental para porcentagem
const permuta = 40;
const data = {
  permuta: permuta * 0.4,  // ❌ Erro: está multiplicando por 0.4
  distratado: false
};

// ❌ PROBLEMA 2: Aplicando desconto incorretamente
const valorOriginal = 40;
const desconto = 0.6;  // 60% de desconto
const data = {
  permuta: valorOriginal * (1 - desconto),  // ❌ Resulta em 16
  distratado: false
};

// ❌ PROBLEMA 3: Conversão de unidade errada
const permutaPercentual = 40;  // 40%
const data = {
  permuta: permutaPercentual / 100 * 40,  // ❌ 0.4 * 40 = 16
  distratado: false
};
```

## 3. Teste PHP Completo

```php
<?php
// test_api_permuta.php

$token = 'SEU_TOKEN_AQUI';
$negociacaoId = 12;

// Valores para testar
$testCases = [
    ['valor' => 10, 'esperado' => 10],
    ['valor' => 20, 'esperado' => 20],
    ['valor' => 40, 'esperado' => 40],  // Caso problemático
    ['valor' => 50, 'esperado' => 50],
    ['valor' => 100, 'esperado' => 100],
];

foreach ($testCases as $test) {
    $data = [
        'permuta' => $test['valor'],
        'distratado' => false
    ];

    $ch = curl_init("https://backend.valeincorp.com.br/api/negociacoes/$negociacaoId");
    curl_setopt($ch, CURLOPT_CUSTOMREQUEST, "PUT");
    curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_HTTPHEADER, [
        'Content-Type: application/json',
        'Accept: application/json',
        'Authorization: Bearer ' . $token
    ]);

    $response = curl_exec($ch);
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);

    $result = json_decode($response, true);

    echo "Enviado: {$test['valor']} | ";
    echo "Recebido: {$result['permuta']} | ";
    echo "Status: " . ($result['permuta'] == $test['esperado'] ? "✅ OK" : "❌ ERRO") . "\n";

    if ($result['permuta'] != $test['esperado']) {
        echo "  ⚠️ Conversão detectada: {$test['valor']} → {$result['permuta']}\n";

        // Verificar se é multiplicação por 0.4
        if ($result['permuta'] == $test['valor'] * 0.4) {
            echo "  📊 Padrão identificado: valor * 0.4\n";
        }
    }
}
```

## 4. Logs para Adicionar no Backend

Para debugar, adicione estes logs em `routes/api.php` (linha 1286):

```php
// Adicionar após linha 1286
\Log::info("=== DEBUG PERMUTA ===");
\Log::info("Request method: " . $request->method());
\Log::info("Request headers: " . json_encode($request->headers->all()));
\Log::info("Raw input: " . $request->getContent());
\Log::info("Request all: " . json_encode($request->all()));
\Log::info("Permuta específica: " . json_encode($request->input('permuta')));
\Log::info("Tipo da permuta: " . gettype($request->input('permuta')));
```

## 5. Checklist de Verificação no Frontend

### ✅ Verificar no DevTools do Navegador:

1. **Aba Network → Request**
   - Ver o payload enviado
   - Confirmar que `permuta: 40` está sendo enviado

2. **Aba Network → Response**
   - Ver o que a API retorna
   - Verificar se `permuta` volta como 40 ou 16

3. **Console JavaScript**
   ```javascript
   // Antes de enviar
   console.log('Dados a enviar:', JSON.stringify(data));

   // Após receber
   console.log('Resposta da API:', response);
   ```

### ⚠️ Pontos Críticos para Verificar:

1. **Interceptors/Middlewares no Frontend**
   - Axios interceptors
   - Custom transformers
   - Formatadores de dados

2. **Validações/Máscaras de Input**
   - Máscaras de porcentagem
   - Conversões automáticas
   - Formatadores de número

3. **Estado do Componente**
   ```javascript
   // Verificar se não há transformação no setState
   setPermuta(value * 0.4);  // ❌ Erro comum
   ```

## 6. Teste Rápido para Identificar o Problema

```javascript
// Cole isto no console do navegador na página da aplicação
async function testarPermuta() {
  const valores = [10, 20, 30, 40, 50];

  for (const valor of valores) {
    const response = await fetch('/api/negociacoes/12', {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ' + localStorage.getItem('token')
      },
      body: JSON.stringify({ permuta: valor })
    });

    const result = await response.json();
    console.log(`Enviado: ${valor} → Recebido: ${result.permuta}`);

    if (valor !== result.permuta) {
      console.error(`❌ Conversão detectada: ${valor} → ${result.permuta}`);
      if (result.permuta === valor * 0.4) {
        console.warn('Padrão: multiplicação por 0.4');
      }
    }
  }
}

// Executar o teste
testarPermuta();
```

## Resultado Esperado vs Problema

| Valor Enviado | Resultado Correto | Resultado com Problema | Padrão |
|--------------|-------------------|----------------------|--------|
| 10 | 10 | 4 | 10 × 0.4 |
| 20 | 20 | 8 | 20 × 0.4 |
| 40 | 40 | **16** | **40 × 0.4** |
| 50 | 50 | 20 | 50 × 0.4 |
| 100 | 100 | 40 | 100 × 0.4 |