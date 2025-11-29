<?php

namespace App\Http\Controllers;

use App\Models\MedidaUnidade;
use App\Models\EmpreendimentoUnidade;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Log;

class MedidaUnidadeController extends Controller
{
    /**
     * Salvar medidas de uma unidade
     */
    public function store(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'unidade_id' => 'required|integer|exists:empreendimentos_unidades,id',
            'medidas' => 'required|array',
            'medidas.*.tipo_medida_id' => 'required|integer|exists:tipos_medida_unidades,id',
            'medidas.*.valor' => 'required|numeric|min:0',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Dados inválidos',
                'errors' => $validator->errors()
            ], 422);
        }

        try {
            $unidadeId = $request->unidade_id;
            $medidas = $request->medidas;

            // Verificar se a unidade existe
            $unidade = EmpreendimentoUnidade::find($unidadeId);
            if (!$unidade) {
                return response()->json([
                    'success' => false,
                    'message' => 'Unidade não encontrada'
                ], 404);
            }

            // Deletar medidas existentes da unidade
            MedidaUnidade::where('unidade_id', $unidadeId)->delete();

            // Inserir novas medidas
            foreach ($medidas as $medida) {
                if ($medida['valor'] > 0) { // Só salva se o valor for maior que 0
                    MedidaUnidade::create([
                        'unidade_id' => $unidadeId,
                        'tipo_medida_id' => $medida['tipo_medida_id'],
                        'valor' => $medida['valor'],
                    ]);
                }
            }

            return response()->json([
                'success' => true,
                'message' => 'Medidas salvas com sucesso'
            ]);

        } catch (\Exception $e) {
            Log::error('Erro ao salvar medidas da unidade: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Erro interno do servidor'
            ], 500);
        }
    }

    /**
     * Buscar medidas de uma unidade
     */
    public function show(int $unidadeId): JsonResponse
    {
        try {
            $medidas = MedidaUnidade::where('unidade_id', $unidadeId)
                ->with('tipoMedida')
                ->get();

            $medidasFormatadas = $medidas->map(function ($medida) {
                return [
                    'tipo_medida_id' => $medida->tipo_medida_id,
                    'tipo_nome' => $medida->tipoMedida->nome,
                    'tipo_unidade' => $medida->tipoMedida->unidade,
                    'valor' => $medida->valor,
                ];
            });

            return response()->json([
                'success' => true,
                'data' => $medidasFormatadas
            ]);

        } catch (\Exception $e) {
            Log::error('Erro ao buscar medidas da unidade: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Erro interno do servidor'
            ], 500);
        }
    }

    /**
     * Deletar medidas de uma unidade
     */
    public function destroy(int $unidadeId): JsonResponse
    {
        try {
            MedidaUnidade::where('unidade_id', $unidadeId)->delete();

            return response()->json([
                'success' => true,
                'message' => 'Medidas removidas com sucesso'
            ]);

        } catch (\Exception $e) {
            Log::error('Erro ao deletar medidas da unidade: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Erro interno do servidor'
            ], 500);
        }
    }
}
