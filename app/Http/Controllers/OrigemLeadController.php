<?php

namespace App\Http\Controllers;

use App\Models\OrigemLead;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Exception;

class OrigemLeadController extends Controller
{
    /**
     * Listar todas as origens de lead
     */
    public function index()
    {
        try {
            $origens = OrigemLead::orderBy('nome', 'asc')->get();

            return response()->json([
                'data' => $origens,
                'total' => $origens->count()
            ], 200);
        } catch (Exception $e) {
            return response()->json([
                'message' => 'Erro ao buscar origens de lead',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Criar nova origem de lead
     */
    public function store(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'nome' => 'required|string|max:255',
                'ativo' => 'nullable|boolean',
            ], [
                'nome.required' => 'O nome é obrigatório',
                'nome.max' => 'O nome não pode ter mais de 255 caracteres',
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'message' => 'Erro de validação',
                    'errors' => $validator->errors()
                ], 422);
            }

            $origem = OrigemLead::create([
                'nome' => $request->nome,
                'ativo' => $request->ativo ?? true,
            ]);

            return response()->json([
                'message' => 'Origem de lead criada com sucesso',
                'data' => $origem
            ], 201);
        } catch (Exception $e) {
            return response()->json([
                'message' => 'Erro ao criar origem de lead',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Atualizar origem de lead
     */
    public function update(Request $request, $id)
    {
        try {
            $origem = OrigemLead::findOrFail($id);

            $validator = Validator::make($request->all(), [
                'nome' => 'sometimes|required|string|max:255',
                'ativo' => 'nullable|boolean',
            ], [
                'nome.required' => 'O nome é obrigatório',
                'nome.max' => 'O nome não pode ter mais de 255 caracteres',
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'message' => 'Erro de validação',
                    'errors' => $validator->errors()
                ], 422);
            }

            $origem->update($request->only(['nome', 'ativo']));

            return response()->json([
                'message' => 'Origem de lead atualizada com sucesso',
                'data' => $origem->fresh()
            ], 200);
        } catch (Exception $e) {
            return response()->json([
                'message' => 'Erro ao atualizar origem de lead',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Deletar origem de lead
     */
    public function destroy($id)
    {
        try {
            $origem = OrigemLead::findOrFail($id);
            $origem->delete();

            return response()->json([
                'message' => 'Excluído com sucesso'
            ], 200);
        } catch (Exception $e) {
            return response()->json([
                'message' => 'Erro ao excluir origem de lead',
                'error' => $e->getMessage()
            ], 500);
        }
    }
}
