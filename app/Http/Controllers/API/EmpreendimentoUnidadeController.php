<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Arr;
use Illuminate\Validation\ValidationException;

// Models
use App\Models\EmpreendimentoUnidadeVagaGaragem;
use App\Models\EmpreendimentoUnidade;
use App\Models\TipoMedidaUnidade;

class EmpreendimentoUnidadeController extends Controller
{
    public function store(Request $request, $torre_id)
    {
        $validated = $request->validate([
            'numero_andar_apartamento' => 'required|integer',
            'numero_apartamento' => 'required|integer',
            'tamanho_unidade_metros_quadrados' => 'required|numeric',
            'valor' => 'required|numeric',
            'numero_quartos' => 'required|integer',
            'numero_suites' => 'required|integer',
            'numero_banheiros' => 'required|integer',
            'status_unidades_id' => 'required|integer',
            'observacao' => 'nullable|string',
            'posicao' => 'nullable|string',
            'box_unidades_ids' => 'nullable|array',
            'box_unidades_ids.*' => 'integer|exists:empreendimentos_unidades_vagas_garem,id',
            'box_unidades_id' => 'nullable|integer|exists:empreendimentos_unidades_vagas_garem,id',
        ]);

        $boxIds = $this->extractBoxIds($request);

        unset($validated['box_unidades_ids'], $validated['box_unidades_id']);

        $validated['empreendimentos_tores_id'] = $torre_id;

        $unidade = EmpreendimentoUnidade::create($validated);

        $this->syncVagas($unidade, $boxIds);

        $unidadeAtualizada = $this->loadUnidadeDetalhes($unidade->id);

        return response()->json($unidadeAtualizada, 201);
    }

    public function show($id)
    {
        $unidade = EmpreendimentoUnidade::with([
            'torre.empreendimento.endereco', 
            'torre.empreendimento.torres',
            'torre.empreendimento.fotosUnidades',
            'torre.empreendimento.videosUnidades',
            'medidas'
        ])->findOrFail($id);
        
        // Busca informações adicionais
        $torre = $unidade->torre;
        $empreendimento = $torre->empreendimento;
        
        // Formatar as medidas dinâmicas
        $medidasFormatadas = [];
        $areaTotal = $unidade->tamanho_unidade_metros_quadrados; // Fallback inicial
        
        if ($unidade->medidas && $unidade->medidas->count() > 0) {
            // Buscar todos os tipos de medida de uma vez para melhor performance
            $tiposMedida = TipoMedidaUnidade::all()->keyBy('id');

            // Buscar primeiro por "Área Privativa", se não existir busca "Área Total"
            $tipoAreaPrivativa = TipoMedidaUnidade::where('nome', 'Área Privativa')->first();
            if ($tipoAreaPrivativa) {
                $medidaAreaPrivativa = $unidade->medidas->firstWhere('tipo_medida_id', $tipoAreaPrivativa->id);
                if ($medidaAreaPrivativa && $medidaAreaPrivativa->valor > 0) {
                    $areaTotal = $medidaAreaPrivativa->valor;
                }
            }

            // Se não encontrou Área Privativa, busca Área Total
            if ($areaTotal == $unidade->tamanho_unidade_metros_quadrados) {
                $tipoAreaTotal = TipoMedidaUnidade::where('nome', 'Área Total')->first();
                if ($tipoAreaTotal) {
                    $medidaAreaTotal = $unidade->medidas->firstWhere('tipo_medida_id', $tipoAreaTotal->id);
                    if ($medidaAreaTotal && $medidaAreaTotal->valor > 0) {
                        $areaTotal = $medidaAreaTotal->valor;
                    }
                }
            }
            
            $medidasFormatadas = $unidade->medidas->map(function ($medida) use ($tiposMedida) {
                $tipo = $tiposMedida->get($medida->tipo_medida_id);
                
                return [
                    'tipo_medida_id' => $medida->tipo_medida_id,
                    'tipo_nome' => $tipo ? $tipo->nome : 'Tipo não encontrado',
                    'tipo_unidade' => $tipo ? $tipo->unidade : 'm²',
                    'valor' => $medida->valor,
                ];
            })->toArray();
        }
        
        // Calcula estatísticas da unidade usando a área correta
        $valorM2 = $areaTotal > 0 ? 
            round($unidade->valor / $areaTotal, 2) : 0;
        
        // Determina o status
        $statusNome = 'disponivel';
        $statusLabel = 'Disponível';
        
        if ($unidade->status_unidades_id == 3) {
            $statusNome = 'vendida';
            $statusLabel = 'Vendida';
        } elseif ($unidade->status_unidades_id == 2) {
            $statusNome = 'reservada';
            $statusLabel = 'Reservada';
        }
        
        // Busca fotos específicas da unidade (por categoria se disponível)
        $fotosUnidade = $empreendimento->fotosUnidades
            ->where('empreendimentos_tores_id', $torre->id)
            ->pluck('fotos_url')
            ->filter()
            ->unique()
            ->values()
            ->toArray();
            
        // Busca vídeos específicos da unidade
        $videosUnidade = $empreendimento->videosUnidades
            ->where('empreendimentos_tores_id', $torre->id)
            ->map(function($video) {
                return [
                    'id' => $video->id,
                    'url' => $video->video_url ?? $video->videos_url,
                    'categoria' => $video->categoria,
                    'nome_original' => $video->original_name,
                    'tamanho' => $video->file_size
                ];
            })
            ->toArray();
            
        // Busca vagas de garagem associadas à torre
// 1) Existe vaga vinculada a ESTA unidade?
$temVinculadas = \App\Models\EmpreendimentoUnidadeVagaGaragem::query()
    ->where('empreendimentos_tores_id', $torre->id)  // <- nome da sua coluna
    ->where('unidade_id', $unidade->id)              // <- vinculo com a unidade
    ->exists();

// 2) Monta a query correta conforme o caso
$query = \App\Models\EmpreendimentoUnidadeVagaGaragem::query()
    ->where('empreendimentos_tores_id', $torre->id);

if ($temVinculadas) {
    // Só as vagas vinculadas à unidade
    $query->where('unidade_id', $unidade->id);
} else {
    // Nenhuma vinculada: listar as disponíveis da torre (ajuste o valor do status se for diferente)
    $query->whereNull('unidade_id')
          ->where('status', 'disponivel');
}

// 3) Mapeia para o formato de saída
$vagasGaragem = $query->get()
    ->map(function ($vaga) {
        return [
            'id'         => $vaga->id,
            'numero'     => $vaga->numero_vaga,
            'tipo'       => $vaga->tipo_vaga,
            'cobertura'  => $vaga->cobertura,
            'area'       => $vaga->area_total,
            'pavimento'  => $vaga->pavimento,
            'status'     => $vaga->status,
            'observacoes'=> $vaga->observacoes,
        ];
    })
    ->toArray();


        
        // Monta resposta completa
        return response()->json([
            'success' => true,
            'data' => [
                'id' => $unidade->id,
                'numero' => $unidade->numero_apartamento,
                'andar' => $unidade->numero_andar_apartamento,
                'area' => $areaTotal,
                'areaFormatada' => number_format($areaTotal, 2, ',', '.') . ' m²',
                'quartos' => $unidade->numero_quartos,
                'suites' => $unidade->numero_suites,
                'banheiros' => $unidade->numero_banheiros,
                'valor' => $unidade->valor,
                'valorFormatado' => 'R$ ' . number_format($unidade->valor, 2, ',', '.'),
                'valorM2' => $valorM2,
                'valorM2Formatado' => 'R$ ' . number_format($valorM2, 2, ',', '.'),
                'status' => $statusNome,
                'statusLabel' => $statusLabel,
                'statusId' => $unidade->status_unidades_id,
                'observacao' => $unidade->observacao,
                'posicao' => $unidade->posicao ?: $this->getPosicaoUnidade($unidade->numero_apartamento),
                'vistaEspecial' => $unidade->numero_andar_apartamento >= 10,
                'solManha' => $this->getSolOrientacao($unidade->numero_apartamento, 'manha'),
                'solTarde' => $this->getSolOrientacao($unidade->numero_apartamento, 'tarde'),
                'fotos' => $fotosUnidade,
                'videos' => $videosUnidade,
                'vagasGaragem' => $vagasGaragem,
                'medidas' => $medidasFormatadas,
                'planta' => null, // Campo para futura implementação de plantas
                'torre' => [
                    'id' => $torre->id,
                    'nome' => $torre->nome ?? 'Torre ' . $torre->id,
                    'numeroAndares' => $torre->numero_andares,
                    'unidadesPorAndar' => $torre->quantidade_unidades_andar
                ],
                'empreendimento' => [
                    'id' => $empreendimento->id,
                    'nome' => $empreendimento->nome,
                    'area_total' => $empreendimento->area_total,
                    'endereco' => $empreendimento->endereco ? [
                        'logradouro' => trim(($empreendimento->endereco->rua ?? '') . ', ' . ($empreendimento->endereco->numero ?? '')),
                        'bairro' => $empreendimento->endereco->bairro,
                        'cidade' => $empreendimento->endereco->cidade,
                        'estado' => $empreendimento->endereco->estado,
                        'cep' => $empreendimento->endereco->cep
                    ] : null
                ],
                'createdAt' => $unidade->created_at->toISOString(),
                'updatedAt' => $unidade->updated_at->toISOString()
            ]
        ]);
    }

    private function getPosicaoUnidade($numeroApartamento)
    {
        // Determina posição baseada no número do apartamento
        $finalApto = substr($numeroApartamento, -2);
        $numero = intval($finalApto);
        
        if ($numero <= 2) {
            return 'frente';
        } else {
            return 'fundos';
        }
    }

    private function getSolOrientacao($numeroApartamento, $periodo)
    {
        $finalApto = substr($numeroApartamento, -2);
        $numero = intval($finalApto);
        
        if ($periodo === 'manha') {
            return in_array($numero, [1, 2]);
        } else {
            return in_array($numero, [3, 4]);
        }
    }

    public function update(Request $request, $id)
    {
        $unidade = EmpreendimentoUnidade::findOrFail($id);
        $validated = $request->validate([
            'numero_andar_apartamento' => 'sometimes|integer',
            'numero_apartamento' => 'sometimes|integer',
            'tamanho_unidade_metros_quadrados' => 'sometimes|numeric',
            'valor' => 'sometimes|numeric',
            'numero_quartos' => 'sometimes|integer',
            'numero_suites' => 'sometimes|integer',
            'numero_banheiros' => 'sometimes|integer',
            'status_unidades_id' => 'sometimes|integer',
            'observacao' => 'nullable|string',
            'posicao' => 'nullable|string',
            'box_unidades_ids' => 'nullable|array',
            'box_unidades_ids.*' => 'integer|exists:empreendimentos_unidades_vagas_garem,id',
            'box_unidades_id' => 'nullable|integer|exists:empreendimentos_unidades_vagas_garem,id',
        ]);
        $boxIds = $this->extractBoxIds($request);

        unset($validated['box_unidades_ids'], $validated['box_unidades_id']);

        $unidade->update($validated);

        $this->syncVagas($unidade, $boxIds);

        $unidadeAtualizada = $this->loadUnidadeDetalhes($unidade->id);

        return response()->json($unidadeAtualizada);
    }

    private function extractBoxIds(Request $request): array
    {
        $ids = Arr::wrap($request->input('box_unidades_ids', []));
        $single = $request->input('box_unidades_id');

        if ($single !== null) {
            $ids[] = $single;
        }

        return collect($ids)
            ->filter(function ($value) {
                return $value !== null && $value !== '' && is_numeric($value);
            })
            ->map(fn($value) => (int) $value)
            ->unique()
            ->values()
            ->all();
    }

    private function syncVagas(EmpreendimentoUnidade $unidade, array $boxIds): void
    {
        $ids = collect($boxIds)
            ->filter(fn($id) => $id > 0)
            ->unique()
            ->values();

        if ($ids->isEmpty()) {
            EmpreendimentoUnidadeVagaGaragem::where('empreendimentos_tores_id', $unidade->empreendimentos_tores_id)
                ->where('unidade_id', $unidade->id)
                ->update(['unidade_id' => null]);
            return;
        }

        $vagas = EmpreendimentoUnidadeVagaGaragem::where('empreendimentos_tores_id', $unidade->empreendimentos_tores_id)
            ->whereIn('id', $ids)
            ->get();

        $idsEncontrados = $vagas->pluck('id');
        $idsInexistentes = $ids->diff($idsEncontrados);

        if ($idsInexistentes->isNotEmpty()) {
            throw ValidationException::withMessages([
                'box_unidades_ids' => 'Algumas vagas selecionadas não pertencem a esta torre: ' . $idsInexistentes->implode(', ')
            ]);
        }

        $vagasOcupadas = $vagas->filter(function ($vaga) use ($unidade) {
            return $vaga->unidade_id !== null && $vaga->unidade_id !== $unidade->id;
        })->pluck('id');

        if ($vagasOcupadas->isNotEmpty()) {
            throw ValidationException::withMessages([
                'box_unidades_ids' => 'As vagas ' . $vagasOcupadas->implode(', ') . ' já estão vinculadas a outra unidade.'
            ]);
        }

        EmpreendimentoUnidadeVagaGaragem::where('empreendimentos_tores_id', $unidade->empreendimentos_tores_id)
            ->where('unidade_id', $unidade->id)
            ->whereNotIn('id', $ids)
            ->update(['unidade_id' => null]);

        EmpreendimentoUnidadeVagaGaragem::where('empreendimentos_tores_id', $unidade->empreendimentos_tores_id)
            ->whereIn('id', $ids)
            ->update(['unidade_id' => $unidade->id]);
    }

    private function loadUnidadeDetalhes(int $id): EmpreendimentoUnidade
    {
        $unidade = EmpreendimentoUnidade::with([
            'medidas',
            'vagas:id,empreendimentos_tores_id,unidade_id,numero_vaga,status'
        ])->findOrFail($id);

        if ($unidade->medidas && $unidade->medidas->count() > 0) {
            $tiposMedida = TipoMedidaUnidade::all()->keyBy('id');

            $unidade->medidas = $unidade->medidas->map(function ($medida) use ($tiposMedida) {
                $tipo = $tiposMedida->get($medida->tipo_medida_id);

                return [
                    'tipo_medida_id' => $medida->tipo_medida_id,
                    'tipo_nome' => $tipo ? $tipo->nome : 'Tipo não encontrado',
                    'tipo_unidade' => $tipo ? $tipo->unidade : 'm²',
                    'valor' => $medida->valor,
                ];
            });
        }

        $unidade->box_unidades_ids = $unidade->vagas
            ? $unidade->vagas
                ->pluck('id')
                ->filter()
                ->values()
                ->all()
            : [];

        return $unidade;
    }
} 
