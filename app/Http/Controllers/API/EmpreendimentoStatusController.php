<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\EmpreendimentoStatus;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class EmpreendimentoStatusController extends Controller
{
    /**
     * Lista todos os status de empreendimentos
     * GET /api/empreendimentos-status
     */
    public function index(Request $request)
    {
        $page = $request->get('page', 1);
        $limit = min($request->get('limit', 20), 100);

        $query = EmpreendimentoStatus::orderBy('id', 'asc');

        // Filtro por nome (opcional)
        if ($request->has('search') && !empty(trim($request->search))) {
            $search = trim($request->search);
            $query->where('nome', 'like', '%' . $search . '%');
        }

        $status = $query->paginate($limit, ['*'], 'page', $page);

        return response()->json([
            'success' => true,
            'data' => $status->items(),
            'pagination' => [
                'currentPage' => $status->currentPage(),
                'totalPages' => $status->lastPage(),
                'totalItems' => $status->total(),
                'itemsPerPage' => $status->perPage(),
                'hasNextPage' => $status->hasMorePages(),
                'hasPreviousPage' => $status->currentPage() > 1,
            ]
        ]);
    }

    /**
     * Visualiza um status específico
     * GET /api/empreendimentos-status/{id}
     */
    public function show($id)
    {
        $status = EmpreendimentoStatus::find($id);

        if (!$status) {
            return response()->json([
                'success' => false,
                'message' => 'Status não encontrado'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => $status
        ]);
    }

    /**
     * Cria um novo status
     * POST /api/empreendimentos-status
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'nome' => 'required|string|max:255|unique:empreendimentos_status,nome'
        ], [
            'nome.required' => 'O nome do status é obrigatório',
            'nome.unique' => 'Já existe um status com este nome',
            'nome.max' => 'O nome não pode ter mais de 255 caracteres'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Erro de validação',
                'errors' => $validator->errors()
            ], 422);
        }

        $status = EmpreendimentoStatus::create([
            'nome' => $request->nome
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Status criado com sucesso',
            'data' => $status
        ], 201);
    }

    /**
     * Atualiza um status existente
     * PUT /api/empreendimentos-status/{id}
     */
    public function update(Request $request, $id)
    {
        $status = EmpreendimentoStatus::find($id);

        if (!$status) {
            return response()->json([
                'success' => false,
                'message' => 'Status não encontrado'
            ], 404);
        }

        $validator = Validator::make($request->all(), [
            'nome' => 'required|string|max:255|unique:empreendimentos_status,nome,' . $id
        ], [
            'nome.required' => 'O nome do status é obrigatório',
            'nome.unique' => 'Já existe um status com este nome',
            'nome.max' => 'O nome não pode ter mais de 255 caracteres'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Erro de validação',
                'errors' => $validator->errors()
            ], 422);
        }

        $status->update([
            'nome' => $request->nome
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Status atualizado com sucesso',
            'data' => $status
        ]);
    }

    /**
     * Deleta um status
     * DELETE /api/empreendimentos-status/{id}
     */
    public function destroy($id)
    {
        $status = EmpreendimentoStatus::find($id);

        if (!$status) {
            return response()->json([
                'success' => false,
                'message' => 'Status não encontrado'
            ], 404);
        }

        // Verifica se o status está sendo usado por algum empreendimento
        $emUso = \App\Models\Empreendimento::where('empreendimentos_status_id', $id)->exists();

        if ($emUso) {
            return response()->json([
                'success' => false,
                'message' => 'Não é possível deletar este status pois ele está sendo usado por empreendimentos'
            ], 409);
        }

        $status->delete();

        return response()->json([
            'success' => true,
            'message' => 'Status deletado com sucesso'
        ]);
    }
}
