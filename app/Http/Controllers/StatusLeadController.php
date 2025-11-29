<?php

namespace App\Http\Controllers;

use App\Models\StatusLead;
use App\Models\Lead;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\DB;
use Exception;

class StatusLeadController extends Controller
{
    /**
     * Listar todos os status de leads
     */
    public function index()
    {
        try {
            $status = StatusLead::orderBy('ordem', 'asc')
                ->orderBy('id', 'asc')
                ->get();

            return response()->json([
                'data' => $status
            ], 200);
        } catch (Exception $e) {
            return response()->json([
                'message' => 'Erro ao buscar status de leads',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Criar novo status de lead
     */
    public function store(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'nome' => 'required|string|max:255',
                'cor' => ['required', 'string', 'regex:/^#[0-9A-Fa-f]{6}$/'],
                'ordem' => 'nullable|integer',
                'ativo' => 'nullable|boolean',
            ], [
                'nome.required' => 'O nome é obrigatório',
                'nome.max' => 'O nome não pode ter mais de 255 caracteres',
                'cor.required' => 'A cor é obrigatória',
                'cor.regex' => 'A cor deve ser um código hexadecimal válido (ex: #FF5500)',
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'message' => 'Erro de validação',
                    'errors' => $validator->errors()
                ], 422);
            }

            // Se ordem não foi informada, pegar a próxima ordem disponível
            $ordem = $request->ordem ?? (StatusLead::max('ordem') ?? 0) + 1;

            $status = StatusLead::create([
                'nome' => $request->nome,
                'cor' => $request->cor,
                'ordem' => $ordem,
                'ativo' => $request->ativo ?? true,
            ]);

            return response()->json([
                'message' => 'Status de lead criado com sucesso',
                'data' => $status
            ], 201);
        } catch (Exception $e) {
            return response()->json([
                'message' => 'Erro ao criar status de lead',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Atualizar status de lead
     */
    public function update(Request $request, $id)
    {
        try {
            $status = StatusLead::findOrFail($id);

            $validator = Validator::make($request->all(), [
                'nome' => 'sometimes|string|max:255',
                'cor' => ['sometimes', 'string', 'regex:/^#[0-9A-Fa-f]{6}$/'],
                'ordem' => 'sometimes|integer',
                'ativo' => 'sometimes|boolean',
            ], [
                'nome.max' => 'O nome não pode ter mais de 255 caracteres',
                'cor.regex' => 'A cor deve ser um código hexadecimal válido (ex: #FF5500)',
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'message' => 'Erro de validação',
                    'errors' => $validator->errors()
                ], 422);
            }

            $status->update($request->only(['nome', 'cor', 'ordem', 'ativo']));

            return response()->json([
                'message' => 'Status de lead atualizado com sucesso',
                'data' => $status->fresh()
            ], 200);
        } catch (Exception $e) {
            return response()->json([
                'message' => 'Erro ao atualizar status de lead',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Deletar status de lead
     */
    public function destroy($id)
    {
        try {
            $status = StatusLead::findOrFail($id);

            // Verificar se há leads vinculados a este status
            $leadsCount = Lead::where('status_leads', $id)->count();

            if ($leadsCount > 0) {
                return response()->json([
                    'message' => 'Não é possível excluir este status pois existem leads vinculados a ele',
                    'leads_count' => $leadsCount
                ], 422);
            }

            $status->delete();

            return response()->json([
                'message' => 'Status de lead excluído com sucesso'
            ], 200);
        } catch (Exception $e) {
            return response()->json([
                'message' => 'Erro ao excluir status de lead',
                'error' => $e->getMessage()
            ], 500);
        }
    }
}
