<?php
// Script para adicionar debug detalhado na API

echo "=== INSTRUÇÕES PARA DEBUG DO CAMPO PERMUTA ===\n\n";

echo "1. ADICIONAR LOGS NA API\n";
echo "   Arquivo: routes/api.php\n";
echo "   Linha: ~1286 (após encontrar a negociação)\n\n";

echo "Código para adicionar:\n";
echo "----------------------------------------\n";
?>

// Adicionar após linha 1286 em routes/api.php
\Log::info("=== DEBUG PERMUTA ID $id ===");
\Log::info("1. Request Method: " . $request->method());
\Log::info("2. Content-Type: " . $request->header('Content-Type'));
\Log::info("3. Raw Content: " . $request->getContent());
\Log::info("4. All Input: " . json_encode($request->all()));
\Log::info("5. Permuta Input: " . json_encode($request->input('permuta')));
\Log::info("6. Tipo Permuta: " . gettype($request->input('permuta')));

// Após validação (linha ~1333)
\Log::info("7. Após Validação:");
\Log::info("   Permuta validada: " . json_encode($validated['permuta'] ?? 'null'));
\Log::info("   Tipo: " . gettype($validated['permuta'] ?? null));

// Antes do update (linha ~1336)
\Log::info("8. Antes do Update:");
\Log::info("   Permuta atual no banco: " . $negociacao->permuta);
\Log::info("   Permuta a ser salva: " . json_encode($validated['permuta'] ?? 'null'));

// Após o update (linha ~1338)
\Log::info("9. Após Update:");
\Log::info("   Permuta no modelo: " . $negociacao->permuta);
\Log::info("   Dirty: " . json_encode($negociacao->getDirty()));

// Após recarregar (linha ~1343)
\Log::info("10. Após Recarregar:");
\Log::info("   Permuta final: " . $negociacaoAtualizada->permuta);
\Log::info("   ValorPermuta calculado: " . $negociacaoAtualizada->valorPermuta);
\Log::info("=== FIM DEBUG PERMUTA ===");

<?php
echo "----------------------------------------\n\n";

echo "2. VERIFICAR LOGS\n";
echo "   Comando: tail -f storage/logs/laravel.log | grep 'DEBUG PERMUTA' -A 20\n\n";

echo "3. EXEMPLO DE OUTPUT ESPERADO (CORRETO):\n";
echo "----------------------------------------\n";
echo "[2025-09-13] local.INFO: === DEBUG PERMUTA ID 12 ===\n";
echo "[2025-09-13] local.INFO: 1. Request Method: PUT\n";
echo "[2025-09-13] local.INFO: 2. Content-Type: application/json\n";
echo "[2025-09-13] local.INFO: 3. Raw Content: {\"permuta\":40,\"distratado\":false}\n";
echo "[2025-09-13] local.INFO: 4. All Input: {\"permuta\":40,\"distratado\":false}\n";
echo "[2025-09-13] local.INFO: 5. Permuta Input: 40\n";
echo "[2025-09-13] local.INFO: 6. Tipo Permuta: integer\n";
echo "[2025-09-13] local.INFO: 7. Após Validação:\n";
echo "[2025-09-13] local.INFO:    Permuta validada: 40\n";
echo "[2025-09-13] local.INFO:    Tipo: double\n";
echo "[2025-09-13] local.INFO: 8. Antes do Update:\n";
echo "[2025-09-13] local.INFO:    Permuta atual no banco: 16\n";
echo "[2025-09-13] local.INFO:    Permuta a ser salva: 40\n";
echo "[2025-09-13] local.INFO: 9. Após Update:\n";
echo "[2025-09-13] local.INFO:    Permuta no modelo: 40\n";
echo "[2025-09-13] local.INFO: 10. Após Recarregar:\n";
echo "[2025-09-13] local.INFO:    Permuta final: 40 ✅\n";
echo "----------------------------------------\n\n";

echo "4. EXEMPLO COM PROBLEMA (40 → 16):\n";
echo "----------------------------------------\n";
echo "SE O PROBLEMA ACONTECER, VOCÊ VERÁ:\n\n";
echo "Cenário 1: Problema no envio (frontend)\n";
echo "[2025-09-13] local.INFO: 3. Raw Content: {\"permuta\":16,\"distratado\":false} ❌\n";
echo "^ Frontend já está enviando 16 em vez de 40\n\n";
echo "Cenário 2: Problema na validação\n";
echo "[2025-09-13] local.INFO: 5. Permuta Input: 40\n";
echo "[2025-09-13] local.INFO: 7. Permuta validada: 16 ❌\n";
echo "^ Algum middleware está transformando\n\n";
echo "Cenário 3: Problema no modelo\n";
echo "[2025-09-13] local.INFO: 8. Permuta a ser salva: 40\n";
echo "[2025-09-13] local.INFO: 9. Permuta no modelo: 16 ❌\n";
echo "^ Há um mutator ou observer modificando\n";
echo "----------------------------------------\n\n";

echo "5. TESTE RÁPIDO VIA CURL:\n";
echo "----------------------------------------\n";
echo 'curl -X PUT "https://backend.valeincorp.com.br/api/negociacoes/12" \\' . "\n";
echo '-H "Accept: application/json" \\' . "\n";
echo '-H "Content-Type: application/json" \\' . "\n";
echo '-H "Authorization: Bearer SEU_TOKEN" \\' . "\n";
echo '-d \'{"permuta": 40, "distratado": false}\' \\' . "\n";
echo '-w "\n\nHTTP Status: %{http_code}\n"' . "\n";
echo "----------------------------------------\n\n";

echo "6. PONTOS DE VERIFICAÇÃO:\n";
echo "   ✓ O que o frontend está enviando (Network tab)\n";
echo "   ✓ O que a API está recebendo (Raw Content)\n";
echo "   ✓ O que está sendo validado\n";
echo "   ✓ O que está sendo salvo no banco\n";
echo "   ✓ O que está sendo retornado\n\n";

echo "EXECUTAR ESTE SCRIPT: php debug_permuta.php\n";