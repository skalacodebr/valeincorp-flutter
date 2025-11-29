<?php
echo "=== ADICIONE ESTE DEBUG NA API ===\n\n";

echo "Em routes/api.php, na rota PUT /negociacoes/{id}, adicione:\n\n";

echo "Após linha 1286 (depois de encontrar a negociação):\n";
echo "----------------------------------------\n";
?>

// DEBUG PERMUTA - INÍCIO
\Log::info("===== DEBUG PERMUTA DUPLICAÇÃO =====");
\Log::info("1. Request recebido:");
\Log::info("   - Raw content: " . $request->getContent());
\Log::info("   - Permuta input: " . json_encode($request->input('permuta')));
\Log::info("   - Tipo: " . gettype($request->input('permuta')));

// Verificar valor atual no banco
$valorAtual = \DB::select("SELECT permuta FROM negociacoes WHERE id = ?", [$id])[0]->permuta ?? null;
\Log::info("2. Valor ATUAL no banco: " . $valorAtual);

<?php
echo "----------------------------------------\n\n";

echo "Após linha 1333 (depois da validação):\n";
echo "----------------------------------------\n";
?>

\Log::info("3. Após validação:");
\Log::info("   - Permuta validada: " . json_encode($validated['permuta'] ?? 'null'));
\Log::info("   - Array completo: " . json_encode($validated));

<?php
echo "----------------------------------------\n\n";

echo "ANTES da linha 1337 (antes do update):\n";
echo "----------------------------------------\n";
?>

\Log::info("4. ANTES do update:");
\Log::info("   - Permuta no modelo: " . $negociacao->permuta);
\Log::info("   - Permuta a salvar: " . ($validated['permuta'] ?? 'null'));

// Verificar se há alguma transformação
if (isset($validated['permuta']) && $validated['permuta'] != $request->input('permuta')) {
    \Log::warning("   ⚠️ VALOR FOI MODIFICADO NA VALIDAÇÃO!");
}

<?php
echo "----------------------------------------\n\n";

echo "DEPOIS da linha 1337 (após o update):\n";
echo "----------------------------------------\n";
?>

\Log::info("5. APÓS update:");
\Log::info("   - Permuta no modelo: " . $negociacao->permuta);

// Verificar direto no banco
$valorNoBanco = \DB::select("SELECT permuta FROM negociacoes WHERE id = ?", [$id])[0]->permuta ?? null;
\Log::info("   - Permuta no BANCO: " . $valorNoBanco);

if ($negociacao->permuta != $valorNoBanco) {
    \Log::error("   ❌ DISCREPÂNCIA: Modelo tem " . $negociacao->permuta . " mas banco tem " . $valorNoBanco);
}

// Verificar se foi duplicado
if (isset($validated['permuta']) && $negociacao->permuta == $validated['permuta'] * 2) {
    \Log::error("   ❌ VALOR FOI DUPLICADO! " . $validated['permuta'] . " × 2 = " . $negociacao->permuta);
}

<?php
echo "----------------------------------------\n\n";

echo "DEPOIS da linha 1342 (após fresh):\n";
echo "----------------------------------------\n";
?>

\Log::info("6. APÓS recarregar (fresh):");
\Log::info("   - Permuta final: " . $negociacaoAtualizada->permuta);
\Log::info("   - valorPermuta: " . $negociacaoAtualizada->valorPermuta);

// Análise final
if ($request->input('permuta') == 10 && $negociacaoAtualizada->permuta == 20) {
    \Log::error("❌ CONFIRMADO: 10 virou 20 (duplicação)");
} elseif ($request->input('permuta') == 40 && $negociacaoAtualizada->permuta == 16) {
    \Log::error("❌ CONFIRMADO: 40 virou 16 (× 0.4)");
}

\Log::info("===== FIM DEBUG PERMUTA =====");
// DEBUG PERMUTA - FIM

<?php
echo "----------------------------------------\n\n";

echo "COMO USAR:\n";
echo "1. Adicione o código acima na API (routes/api.php)\n";
echo "2. Faça uma requisição PUT com permuta = 10\n";
echo "3. Verifique os logs: tail -f storage/logs/laravel.log | grep 'DEBUG PERMUTA' -A 50\n";
echo "4. O log mostrará EXATAMENTE onde o valor está sendo modificado\n\n";

echo "EXEMPLO DE LOG ESPERADO:\n";
echo "----------------------------------------\n";
echo "[2025-09-13] local.INFO: ===== DEBUG PERMUTA DUPLICAÇÃO =====\n";
echo "[2025-09-13] local.INFO: 1. Request recebido:\n";
echo "[2025-09-13] local.INFO:    - Permuta input: 10\n";
echo "[2025-09-13] local.INFO: 2. Valor ATUAL no banco: 20\n";
echo "[2025-09-13] local.INFO: 3. Após validação:\n";
echo "[2025-09-13] local.INFO:    - Permuta validada: 10\n";
echo "[2025-09-13] local.INFO: 4. ANTES do update:\n";
echo "[2025-09-13] local.INFO:    - Permuta a salvar: 10\n";
echo "[2025-09-13] local.INFO: 5. APÓS update:\n";
echo "[2025-09-13] local.INFO:    - Permuta no modelo: 20 ← AQUI ESTÁ O PROBLEMA!\n";
echo "----------------------------------------\n";