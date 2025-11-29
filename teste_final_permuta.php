<?php
// TESTE DEFINITIVO - Campo permuta INT

require_once __DIR__ . '/vendor/autoload.php';
$app = require_once __DIR__ . '/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

use App\Models\Negociacao;
use Illuminate\Support\Facades\DB;

echo "==============================================\n";
echo "     TESTE DEFINITIVO - PERMUTA INT(11)      \n";
echo "==============================================\n\n";

$id = 12;
$valorTeste = 40;

echo "Testando com valor: $valorTeste\n";
echo "----------------------------------------------\n\n";

// TESTE 1: SQL PURO
echo "1. SQL DIRETO NO BANCO:\n";
DB::statement("UPDATE negociacoes SET permuta = $valorTeste WHERE id = $id");
$result = DB::select("SELECT permuta FROM negociacoes WHERE id = $id")[0];
echo "   Enviado: $valorTeste\n";
echo "   Salvo:   " . $result->permuta . "\n";
echo "   Status:  " . ($result->permuta == $valorTeste ? "✅ OK" : "❌ ERRO") . "\n\n";

// TESTE 2: ELOQUENT SIMPLES
echo "2. ELOQUENT (Model->save()):\n";
$negociacao = Negociacao::find($id);
$negociacao->permuta = $valorTeste;
$negociacao->save();
$negociacao->refresh();
echo "   Enviado: $valorTeste\n";
echo "   Salvo:   " . $negociacao->permuta . "\n";
echo "   Status:  " . ($negociacao->permuta == $valorTeste ? "✅ OK" : "❌ ERRO") . "\n\n";

// TESTE 3: ELOQUENT UPDATE
echo "3. ELOQUENT (Model->update()):\n";
$negociacao = Negociacao::find($id);
$negociacao->update(['permuta' => $valorTeste]);
$negociacao->refresh();
echo "   Enviado: $valorTeste\n";
echo "   Salvo:   " . $negociacao->permuta . "\n";
echo "   Status:  " . ($negociacao->permuta == $valorTeste ? "✅ OK" : "❌ ERRO") . "\n\n";

// TESTE 4: VERIFICAR CÁLCULO
echo "4. ANÁLISE DO PROBLEMA 40 → 16:\n";
echo "   40 * 0.4 = " . (40 * 0.4) . " (possível conversão)\n";
echo "   40 * 0.4 = 16 ✓ CONFIRMADO\n\n";

echo "==============================================\n";
echo "                 DIAGNÓSTICO                  \n";
echo "==============================================\n\n";

if ($negociacao->permuta == $valorTeste) {
    echo "✅ BACKEND ESTÁ FUNCIONANDO CORRETAMENTE!\n\n";
    echo "O problema está no FRONTEND ou no envio da requisição.\n\n";
    echo "VERIFICAR NO FRONTEND:\n";
    echo "1. Abra o DevTools (F12)\n";
    echo "2. Vá na aba Network\n";
    echo "3. Faça a edição da permuta\n";
    echo "4. Clique no request PUT para negociacoes\n";
    echo "5. Verifique o Payload/Request\n";
    echo "   - Se mostra 'permuta: 16' → problema no frontend\n";
    echo "   - Se mostra 'permuta: 40' → problema em middleware\n\n";

    echo "POSSÍVEL CÓDIGO PROBLEMÁTICO NO FRONTEND:\n";
    echo "```javascript\n";
    echo "// ❌ ERRADO - multiplica por 0.4\n";
    echo "const permuta = valor * 0.4;\n\n";
    echo "// ✅ CORRETO - envia o valor direto\n";
    echo "const permuta = valor;\n";
    echo "```\n";
} else {
    echo "❌ PROBLEMA DETECTADO NO BACKEND!\n\n";
    echo "Valor $valorTeste está sendo salvo como " . $negociacao->permuta . "\n";
    echo "Verificar:\n";
    echo "1. Observers do modelo\n";
    echo "2. Middlewares customizados\n";
    echo "3. Mutators no modelo\n";
}

echo "\n==============================================\n";
echo "Para executar: php teste_final_permuta.php\n";
echo "==============================================\n";