<?php
// Teste rápido para verificar os logs

require_once __DIR__ . '/vendor/autoload.php';
$app = require_once __DIR__ . '/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

use App\Models\Negociacao;
use Illuminate\Support\Facades\Log;

echo "=== TESTE RÁPIDO DE PERMUTA ===\n\n";

$id = 12;
$valorTeste = 10;

echo "1. Testando atualização direta...\n";

$negociacao = Negociacao::find($id);
if (!$negociacao) {
    die("Negociação ID $id não encontrada!\n");
}

echo "   Valor atual: " . $negociacao->permuta . "\n";

// Simular exatamente o que a API faz
Log::info("=== TESTE MANUAL INICIADO ===");
Log::info("Valor atual: " . $negociacao->permuta);
Log::info("Tentando salvar: " . $valorTeste);

$negociacao->permuta = $valorTeste;
$negociacao->save();

Log::info("Após save(): " . $negociacao->permuta);

$negociacao->refresh();

echo "   Valor após save: " . $negociacao->permuta . "\n";

if ($negociacao->permuta == $valorTeste) {
    echo "   ✅ SUCESSO - Backend funcionando!\n";
    Log::info("✅ Teste manual: SUCESSO");
} else {
    echo "   ❌ ERRO - Valor não foi salvo!\n";
    Log::error("❌ Teste manual: FALHOU");
}

echo "\n2. Verifique os logs em: storage/logs/laravel.log\n";
echo "3. Ou execute: ./monitor_permuta.sh\n";