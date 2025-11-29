<?php

namespace App\Http\Controllers;

use App\Models\TipoMedidaUnidade;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Validator;

class TipoMedidaUnidadeController extends Controller
{
    /**
     * Listar todos os tipos de medida
     */
    public function index(): JsonResponse
    {
        $tipos = TipoMedidaUnidade::ordenados()->get();

        return response()->json([
            'success' => true,
            'data' => $tipos
        ]);
    }

    /**
     * Listar apenas tipos ativos
     */
    public function ativos(): JsonResponse
    {
        $tipos = TipoMedidaUnidade::ativos()->ordenados()->get();

        return response()->json([
            'success' => true,
            'data' => $tipos
        ]);
    }

    /**
     * Criar novo tipo de medida
     */
    public function store(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'nome' => 'required|string|max:255',
            'unidade' => 'required|string|max:50',
            'ativo' => 'boolean',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Dados inválidos',
                'errors' => $validator->errors()
            ], 422);
        }

        $tipo = TipoMedidaUnidade::create($request->all());

        return response()->json([
            'success' => true,
            'message' => 'Tipo de medida criado com sucesso',
            'data' => $tipo
        ], 201);
    }

    /**
     * Atualizar tipo de medida
     */
    public function update(Request $request, int $id): JsonResponse
    {
        $tipo = TipoMedidaUnidade::find($id);

        if (!$tipo) {
            return response()->json([
                'success' => false,
                'message' => 'Tipo de medida não encontrado'
            ], 404);
        }

        $validator = Validator::make($request->all(), [
            'nome' => 'required|string|max:255',
            'unidade' => 'required|string|max:50',
            'ativo' => 'boolean',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Dados inválidos',
                'errors' => $validator->errors()
            ], 422);
        }

        $tipo->update($request->all());

        return response()->json([
            'success' => true,
            'message' => 'Tipo de medida atualizado com sucesso',
            'data' => $tipo
        ]);
    }

    /**
     * Excluir tipo de medida
     */
    public function destroy(int $id): JsonResponse
    {
        $tipo = TipoMedidaUnidade::find($id);

        if (!$tipo) {
            return response()->json([
                'success' => false,
                'message' => 'Tipo de medida não encontrado'
            ], 404);
        }

        // Verificar se há medidas usando este tipo
        if ($tipo->medidasUnidades()->count() > 0) {
            return response()->json([
                'success' => false,
                'message' => 'Não é possível excluir este tipo pois existem unidades usando esta medida'
            ], 400);
        }

        $tipo->delete();

        return response()->json([
            'success' => true,
            'message' => 'Tipo de medida excluído com sucesso'
        ]);
    }

}
