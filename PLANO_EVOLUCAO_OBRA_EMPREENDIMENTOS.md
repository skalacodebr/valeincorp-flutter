# Plano de Ação: Implementação de Evoluções da Obra em Empreendimentos

## 📋 Visão Geral

Este plano descreve a implementação completa da funcionalidade que permite vincular evoluções da obra aos empreendimentos, salvando o ID da evolução e sua porcentagem de conclusão em uma coluna JSON no banco de dados.

## 🎯 Objetivos

- Adicionar coluna `evolucao` (JSON) na tabela `empreendimentos`
- Salvar array de evoluções com `id` e `percentual_conclusao`
- Implementar endpoints para CRUD das evoluções vinculadas
- Garantir integridade e validação dos dados

---

## 📊 1. ALTERAÇÕES NO BANCO DE DADOS

### 1.1 Migration - Adicionar Coluna `evolucao`

**Arquivo:** `database/migrations/YYYY_MM_DD_add_evolucao_column_to_empreendimentos_table.php`

```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::table('empreendimentos', function (Blueprint $table) {
            $table->json('evolucao')->nullable()->after('observacoes')
                  ->comment('Array JSON com evoluções da obra: [{"id": 1, "percentual_conclusao": 45}]');
        });
    }

    public function down()
    {
        Schema::table('empreendimentos', function (Blueprint $table) {
            $table->dropColumn('evolucao');
        });
    }
};
```

### 1.2 Estrutura JSON Esperada

```json
[
  {
    "id": 1,
    "percentual_conclusao": 45
  },
  {
    "id": 3,
    "percentual_conclusao": 78
  }
]
```

---

## 🏗️ 2. ATUALIZAÇÃO DO MODEL

### 2.1 Empreendimento Model

**Arquivo:** `app/Models/Empreendimento.php`

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Casts\Attribute;

class Empreendimento extends Model
{
    protected $fillable = [
        'nome',
        'tipo_empreendimento_id',
        'tipo_unidades_id',
        'tamanho_total_unidade_metros_quadrados',
        'area_lazer',
        'observacoes',
        'empreendimentos_status_id',
        'equipe_usuarios_id',
        'memorial_descritivo_base64',
        'catalogo_pdf_base64',
        'evolucao', // Nova coluna
    ];

    protected $casts = [
        'evolucao' => 'array', // Cast automático para array
        'area_lazer' => 'boolean',
    ];

    // Accessor para evoluções com dados completos
    protected function evolucaoCompleta(): Attribute
    {
        return Attribute::make(
            get: function () {
                if (!$this->evolucao) return [];
                
                $evolucaoIds = collect($this->evolucao)->pluck('id');
                $evolucoes = EvolucaoObra::whereIn('id', $evolucaoIds)->get();
                
                return collect($this->evolucao)->map(function ($item) use ($evolucoes) {
                    $evolucao = $evolucoes->firstWhere('id', $item['id']);
                    return [
                        'id' => $item['id'],
                        'percentual_conclusao' => $item['percentual_conclusao'],
                        'nome' => $evolucao->nome ?? 'Evolução não encontrada',
                        'data_criacao' => $evolucao->data_criacao ?? null,
                    ];
                });
            }
        );
    }

    // Relacionamento com evoluções da obra
    public function evolucoesDaObra()
    {
        if (!$this->evolucao) return collect([]);
        
        $evolucaoIds = collect($this->evolucao)->pluck('id');
        return EvolucaoObra::whereIn('id', $evolucaoIds)->get();
    }
}
```

---

## 🚀 3. ATUALIZAÇÃO DA API (CONTROLLER)

### 3.1 EmpreendimentoController - Método Store

```php
public function store(Request $request)
{
    $validatedData = $request->validate([
        'nome' => 'required|string|max:255',
        'tipo_empreendimento_id' => 'nullable|integer',
        'tipo_unidades_id' => 'nullable|integer',
        'tamanho_total_unidade_metros_quadrados' => 'nullable|numeric',
        'area_lazer' => 'boolean',
        'observacoes' => 'nullable|string',
        'empreendimentos_status_id' => 'nullable|integer',
        'equipe_usuarios_id' => 'nullable|integer',
        'memorial_descritivo' => 'nullable|file|mimes:pdf',
        'catalogo_pdf' => 'nullable|file|mimes:pdf',
        'evolucoes' => 'nullable|string', // JSON string do frontend
    ]);

    // Processar evoluções
    $evolucoes = [];
    if ($request->has('evolucoes') && !empty($request->evolucoes)) {
        $evolucoesParsed = json_decode($request->evolucoes, true);
        
        if (json_last_error() === JSON_ERROR_NONE && is_array($evolucoesParsed)) {
            $evolucoes = $this->validateEvolucoes($evolucoesParsed);
        }
    }

    // Processar arquivos...
    // (código existente para memorial e catálogo)

    $validatedData['evolucao'] = $evolucoes;

    $empreendimento = Empreendimento::create($validatedData);

    return response()->json([
        'message' => 'Empreendimento criado com sucesso',
        'data' => $empreendimento->load('endereco'),
        'evolucoes' => $empreendimento->evolucaoCompleta,
    ], 201);
}
```

### 3.2 EmpreendimentoController - Método Update

```php
public function update(Request $request, $id)
{
    $empreendimento = Empreendimento::findOrFail($id);
    
    $validatedData = $request->validate([
        'nome' => 'sometimes|required|string|max:255',
        // ... outros campos
        'evolucoes' => 'nullable|string',
    ]);

    // Processar evoluções se fornecidas
    if ($request->has('evolucoes')) {
        if (empty($request->evolucoes)) {
            $validatedData['evolucao'] = [];
        } else {
            $evolucoesParsed = json_decode($request->evolucoes, true);
            if (json_last_error() === JSON_ERROR_NONE && is_array($evolucoesParsed)) {
                $validatedData['evolucao'] = $this->validateEvolucoes($evolucoesParsed);
            }
        }
    }

    // Processar arquivos...
    
    $empreendimento->update($validatedData);

    return response()->json([
        'message' => 'Empreendimento atualizado com sucesso',
        'data' => $empreendimento->fresh()->load('endereco'),
        'evolucoes' => $empreendimento->fresh()->evolucaoCompleta,
    ]);
}
```

### 3.3 Método de Validação das Evoluções

```php
private function validateEvolucoes(array $evolucoes): array
{
    $validated = [];
    
    foreach ($evolucoes as $evolucao) {
        // Validar estrutura
        if (!isset($evolucao['id']) || !isset($evolucao['percentual_conclusao'])) {
            continue;
        }
        
        $id = (int) $evolucao['id'];
        $percentual = (float) $evolucao['percentual_conclusao'];
        
        // Validar se a evolução existe
        if (!EvolucaoObra::find($id)) {
            continue;
        }
        
        // Validar percentual (0-100)
        if ($percentual < 0 || $percentual > 100) {
            $percentual = max(0, min(100, $percentual));
        }
        
        $validated[] = [
            'id' => $id,
            'percentual_conclusao' => $percentual,
        ];
    }
    
    return $validated;
}
```

---

## 🔍 4. ENDPOINT PARA BUSCAR EVOLUÇÕES DO EMPREENDIMENTO

### 4.1 Rota Adicional

**Arquivo:** `routes/api.php`

```php
// Buscar evoluções de um empreendimento específico
Route::get('empreendimentos/{id}/evolucao-obra', [EmpreendimentoController::class, 'getEvolucoes']);
```

### 4.2 Método no Controller

```php
public function getEvolucoes($id)
{
    $empreendimento = Empreendimento::findOrFail($id);
    
    if (!$empreendimento->evolucao) {
        return response()->json(['data' => []]);
    }
    
    $evolucoes = $empreendimento->evolucaoCompleta;
    
    return response()->json([
        'data' => $evolucoes->map(function ($item) {
            return [
                'id' => $item['id'],
                'nome' => $item['nome'],
                'data_criacao' => $item['data_criacao'],
                'percentual_conclusao' => $item['percentual_conclusao'],
                'empreendimento_id' => $id, // Para compatibilidade
            ];
        })
    ]);
}
```

---

## ✅ 5. VALIDAÇÕES E REGRAS DE NEGÓCIO

### 5.1 Validações de Entrada

```php
// Request Validator personalizado
class EmpreendimentoEvolucaoRequest extends FormRequest
{
    public function rules()
    {
        return [
            'evolucoes' => 'nullable|string',
            'evolucoes.*' => 'array',
            'evolucoes.*.id' => 'required|integer|exists:evolucao_obras,id',
            'evolucoes.*.percentual_conclusao' => 'required|numeric|min:0|max:100',
        ];
    }
    
    public function messages()
    {
        return [
            'evolucoes.*.id.exists' => 'A evolução selecionada não existe.',
            'evolucoes.*.percentual_conclusao.min' => 'O percentual deve ser maior ou igual a 0.',
            'evolucoes.*.percentual_conclusao.max' => 'O percentual deve ser menor ou igual a 100.',
        ];
    }
}
```

### 5.2 Regras de Negócio

- ✅ Uma evolução não pode ser duplicada no mesmo empreendimento
- ✅ Percentual deve estar entre 0 e 100
- ✅ Apenas evoluções existentes podem ser vinculadas
- ✅ Campo evolucao pode ser nulo (empreendimentos sem evoluções)

---

## 🧪 6. TESTES

### 6.1 Teste de Feature

**Arquivo:** `tests/Feature/EmpreendimentoEvolucaoTest.php`

```php
<?php

namespace Tests\Feature;

use Tests\TestCase;
use App\Models\Empreendimento;
use App\Models\EvolucaoObra;

class EmpreendimentoEvolucaoTest extends TestCase
{
    public function test_can_create_empreendimento_with_evolucoes()
    {
        $evolucao1 = EvolucaoObra::factory()->create();
        $evolucao2 = EvolucaoObra::factory()->create();
        
        $evolucoes = [
            ['id' => $evolucao1->id, 'percentual_conclusao' => 45],
            ['id' => $evolucao2->id, 'percentual_conclusao' => 78],
        ];
        
        $response = $this->post('/api/empreendimentos', [
            'nome' => 'Teste Empreendimento',
            'area_lazer' => false,
            'evolucoes' => json_encode($evolucoes),
        ]);
        
        $response->assertStatus(201);
        
        $empreendimento = Empreendimento::latest()->first();
        $this->assertCount(2, $empreendimento->evolucao);
        $this->assertEquals(45, $empreendimento->evolucao[0]['percentual_conclusao']);
    }
    
    public function test_can_update_empreendimento_evolucoes()
    {
        $empreendimento = Empreendimento::factory()->create([
            'evolucao' => [
                ['id' => 1, 'percentual_conclusao' => 30]
            ]
        ]);
        
        $novasEvolucoes = [
            ['id' => 1, 'percentual_conclusao' => 60],
            ['id' => 2, 'percentual_conclusao' => 25],
        ];
        
        $response = $this->put("/api/empreendimentos/{$empreendimento->id}", [
            'evolucoes' => json_encode($novasEvolucoes),
        ]);
        
        $response->assertStatus(200);
        
        $empreendimento->refresh();
        $this->assertEquals(60, $empreendimento->evolucao[0]['percentual_conclusao']);
        $this->assertCount(2, $empreendimento->evolucao);
    }
}
```

---

## 📚 7. DOCUMENTAÇÃO DA API

### 7.1 Endpoint: POST /api/empreendimentos

**Parâmetros adicionais:**

```json
{
    "evolucoes": "[{\"id\":1,\"percentual_conclusao\":45},{\"id\":3,\"percentual_conclusao\":78}]"
}
```

**Resposta:**

```json
{
    "message": "Empreendimento criado com sucesso",
    "data": {
        "id": 1,
        "nome": "Residencial Vista Bela",
        "evolucao": [
            {
                "id": 1,
                "percentual_conclusao": 45
            },
            {
                "id": 3,
                "percentual_conclusao": 78
            }
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

### 7.2 Endpoint: GET /api/empreendimentos/{id}/evolucao-obra

**Resposta:**

```json
{
    "data": [
        {
            "id": 1,
            "nome": "Fundação",
            "data_criacao": "2025-01-15",
            "percentual_conclusao": 45,
            "empreendimento_id": 1
        }
    ]
}
```

---

## 🚀 8. CRONOGRAMA DE IMPLEMENTAÇÃO

### Fase 1: Banco de Dados (1-2 horas)
- [ ] Criar migration
- [ ] Executar migration em desenvolvimento
- [ ] Testar estrutura JSON

### Fase 2: Model e Validações (2-3 horas)
- [ ] Atualizar Empreendimento model
- [ ] Implementar cast e accessor
- [ ] Criar validações personalizadas

### Fase 3: API Endpoints (3-4 horas)
- [ ] Atualizar métodos store/update
- [ ] Implementar método de validação
- [ ] Criar endpoint para busca de evoluções
- [ ] Testar endpoints via Postman/Insomnia

### Fase 4: Testes (2-3 horas)
- [ ] Escrever testes unitários
- [ ] Escrever testes de feature
- [ ] Validar todos os cenários

### Fase 5: Documentação (1 hora)
- [ ] Atualizar documentação da API
- [ ] Criar exemplos de uso
- [ ] Validar com frontend

---

## 🔧 9. COMANDOS ÚTEIS

```bash
# Criar e executar migration
php artisan make:migration add_evolucao_column_to_empreendimentos_table
php artisan migrate

# Criar testes
php artisan make:test EmpreendimentoEvolucaoTest --feature

# Executar testes específicos
php artisan test --filter EmpreendimentoEvolucaoTest

# Reverter migration (se necessário)
php artisan migrate:rollback --step=1
```

---

## ⚠️ 10. CONSIDERAÇÕES IMPORTANTES

### Performance
- ✅ Índice na coluna `evolucao` se necessário para buscas complexas
- ✅ Cache das evoluções mais consultadas
- ✅ Lazy loading para dados relacionados

### Segurança
- ✅ Validar se usuário tem permissão para vinculação
- ✅ Sanitizar dados JSON de entrada
- ✅ Prevenir SQL injection em queries dinâmicas

### Manutenibilidade
- ✅ Documentar formato JSON no código
- ✅ Criar helpers para manipulação das evoluções
- ✅ Implementar logs para alterações importantes

---

## 🎉 Conclusão

Este plano garante uma implementação robusta e escalável para vincular evoluções da obra aos empreendimentos, mantendo a flexibilidade do formato JSON e a integridade dos dados através de validações adequadas.

**Status:** 🟡 Aguardando implementação
**Estimativa total:** 8-12 horas de desenvolvimento
**Complexidade:** Média