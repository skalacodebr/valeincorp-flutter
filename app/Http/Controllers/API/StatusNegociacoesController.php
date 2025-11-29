<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\NegociacaoStatus;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Auth;
use Exception;

class StatusNegociacoesController extends Controller
{
    private function getAuthUser()
    {
        try {
            return Auth::user();
        } catch (Exception $e) {
            return null;
        }
    }

    private function hasConfigPermission($user)
    {
        if (!$user) {
            return false;
        }
        return true;
    }

    /**
     * Listar todos os status de negociações
     */
    public function index()
    {
        try {
            $statusNegociacoes = NegociacaoStatus::where('ativo', true)
                ->orderBy('ordem', 'asc')
                ->orderBy('nome', 'asc')
                ->get();

            return response()->json([
                'data' => $statusNegociacoes,
                'total' => $statusNegociacoes->count()
            ], 200);
        } catch (Exception $e) {
            return response()->json([
                'message' => 'Erro ao buscar status de negociações',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Criar novo status de negociação
     */
    public function store(Request $request)
    {
        try {
            $user = $this->getAuthUser();

            if (!$user) {
                return response()->json(['message' => 'Usuário não autenticado'], 401);
            }

            if (!$this->hasConfigPermission($user)) {
                return response()->json([
                    'message' => 'Sem permissão para gerenciar status de negociações',
                    'required_permission' => 'Configurações',
                    'user_id' => $user->id
                ], 403);
            }

            $validator = Validator::make($request->all(), [
                'nome' => 'required|string|max:255|unique:negociacoes_status,nome',
                'cor' => [
                    'required',
                    'string',
                    'regex:/^#[0-9A-Fa-f]{6}$/i'
                ],
                'ordem' => 'nullable|integer|min:0',
                'ativo' => 'nullable|boolean'
            ], [
                'nome.required' => 'O nome do status é obrigatório',
                'nome.unique' => 'Já existe um status com este nome',
                'cor.required' => 'A cor é obrigatória',
                'cor.regex' => 'A cor deve ser um código hexadecimal válido (ex: #FF5500)'
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'message' => 'Erro de validação',
                    'errors' => $validator->errors()
                ], 422);
            }

            $ordem = $request->ordem;
            if ($ordem === null) {
                $maxOrdem = NegociacaoStatus::max('ordem');
                $ordem = ($maxOrdem ?? 0) + 1;
            }

            $status = NegociacaoStatus::create([
                'nome' => $request->nome,
                'cor' => strtoupper($request->cor),
                'ordem' => $ordem,
                'ativo' => $request->ativo ?? true
            ]);

            return response()->json([
                'message' => 'Status criado com sucesso',
                'data' => $status
            ], 201);
        } catch (Exception $e) {
            return response()->json([
                'message' => 'Erro ao criar status',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Buscar um status específico
     */
    public function show($id)
    {
        try {
            $status = NegociacaoStatus::findOrFail($id);

            return response()->json([
                'success' => true,
                'data' => $status
            ]);
        } catch (Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Status não encontrado',
                'error' => $e->getMessage()
            ], 404);
        }
    }

    /**
     * Atualizar status de negociação
     */
    public function update(Request $request, $id)
    {
        try {
            $user = $this->getAuthUser();

            if (!$user) {
                return response()->json(['message' => 'Usuário não autenticado'], 401);
            }

            if (!$this->hasConfigPermission($user)) {
                return response()->json([
                    'message' => 'Sem permissão para gerenciar status de negociações',
                    'required_permission' => 'Configurações',
                    'user_id' => $user->id
                ], 403);
            }

            $status = NegociacaoStatus::find($id);

            if (!$status) {
                return response()->json(['message' => 'Status não encontrado'], 404);
            }

            $validator = Validator::make($request->all(), [
                'nome' => 'sometimes|required|string|max:255|unique:negociacoes_status,nome,' . $id,
                'cor' => [
                    'sometimes',
                    'required',
                    'string',
                    'regex:/^#[0-9A-Fa-f]{6}$/i'
                ],
                'ordem' => 'nullable|integer|min:0',
                'ativo' => 'nullable|boolean'
            ], [
                'nome.required' => 'O nome do status é obrigatório',
                'nome.unique' => 'Já existe um status com este nome',
                'cor.required' => 'A cor é obrigatória',
                'cor.regex' => 'A cor deve ser um código hexadecimal válido (ex: #FF5500)'
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'message' => 'Erro de validação',
                    'errors' => $validator->errors()
                ], 422);
            }

            $dataToUpdate = [];

            if ($request->has('nome')) {
                $dataToUpdate['nome'] = $request->nome;
            }

            if ($request->has('cor')) {
                $dataToUpdate['cor'] = strtoupper($request->cor);
            }

            if ($request->has('ordem')) {
                $dataToUpdate['ordem'] = $request->ordem;
            }

            if ($request->has('ativo')) {
                $dataToUpdate['ativo'] = $request->ativo;
            }

            $status->update($dataToUpdate);

            return response()->json([
                'message' => 'Status atualizado com sucesso',
                'data' => $status->fresh()
            ], 200);
        } catch (Exception $e) {
            return response()->json([
                'message' => 'Erro ao atualizar status',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Excluir status de negociação
     */
    public function destroy($id)
    {
        try {
            $user = $this->getAuthUser();

            if (!$user) {
                return response()->json(['message' => 'Usuário não autenticado'], 401);
            }

            if (!$this->hasConfigPermission($user)) {
                return response()->json([
                    'message' => 'Sem permissão para gerenciar status de negociações',
                    'required_permission' => 'Configurações',
                    'user_id' => $user->id
                ], 403);
            }

            $status = NegociacaoStatus::find($id);

            if (!$status) {
                return response()->json(['message' => 'Status não encontrado'], 404);
            }

            $negociacoesUsando = DB::table('negociacoes')
                ->where('negociacoes_status_id', $id)
                ->count();

            if ($negociacoesUsando > 0) {
                return response()->json([
                    'message' => "Não é possível excluir este status. Existem {$negociacoesUsando} negociação(ões) utilizando-o.",
                    'negociacoes_count' => $negociacoesUsando
                ], 422);
            }

            $status->delete();

            return response()->json([
                'message' => 'Status excluído com sucesso',
                'data' => null
            ], 200);
        } catch (Exception $e) {
            return response()->json([
                'message' => 'Erro ao excluir status',
                'error' => $e->getMessage()
            ], 500);
        }
    }
}