<?php

namespace App\Http\Controllers;

use App\Models\MotivoPerda;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Exception;

class MotivoPerdaController extends Controller
{
    /**
     * Listar todos os motivos de perda ativos
     */
    public function index()
    {
        try {
            $motivos = MotivoPerda::where('ativo', true)
                ->orderBy('motivo', 'asc')
                ->get();

            return response()->json([
                'data' => $motivos
            ], 200);
        } catch (Exception $e) {
            return response()->json([
                'message' => 'Erro ao buscar motivos de perda',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Criar novo motivo de perda
     */
    public function store(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'motivo' => 'required|string|max:255',
                'ativo' => 'nullable|boolean',
            ], [
                'motivo.required' => 'O motivo é obrigatório',
                'motivo.max' => 'O motivo não pode ter mais de 255 caracteres',
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'message' => 'Erro de validação',
                    'errors' => $validator->errors()
                ], 422);
            }

            $motivo = MotivoPerda::create([
                'motivo' => $request->motivo,
                'ativo' => $request->ativo ?? true,
            ]);

            return response()->json([
                'message' => 'Motivo de perda criado com sucesso',
                'data' => $motivo
            ], 201);
        } catch (Exception $e) {
            return response()->json([
                'message' => 'Erro ao criar motivo de perda',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Atualizar motivo de perda
     */
    public function update(Request $request, $id)
    {
        try {
            $motivo = MotivoPerda::findOrFail($id);

            $validator = Validator::make($request->all(), [
                'motivo' => 'sometimes|required|string|max:255',
                'ativo' => 'nullable|boolean',
            ], [
                'motivo.required' => 'O motivo é obrigatório',
                'motivo.max' => 'O motivo não pode ter mais de 255 caracteres',
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'message' => 'Erro de validação',
                    'errors' => $validator->errors()
                ], 422);
            }

            $motivo->update($request->only(['motivo', 'ativo']));

            return response()->json([
                'message' => 'Motivo de perda atualizado com sucesso',
                'data' => $motivo->fresh()
            ], 200);
        } catch (Exception $e) {
            return response()->json([
                'message' => 'Erro ao atualizar motivo de perda',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Deletar motivo de perda
     */
    public function destroy($id)
    {
        try {
            $motivo = MotivoPerda::findOrFail($id);
            $motivo->delete();

            return response()->json([
                'message' => 'Excluído com sucesso'
            ], 200);
        } catch (Exception $e) {
            return response()->json([
                'message' => 'Erro ao excluir motivo de perda',
                'error' => $e->getMessage()
            ], 500);
        }
    }
}
