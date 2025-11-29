<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\CategoriaFoto;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Auth;
use Exception;

class CategoriaFotoController extends Controller
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
     * Listar todas as categorias de fotos
     */
    public function index()
    {
        try {
            $categorias = CategoriaFoto::ativo()->ordenado()->get();

            return response()->json([
                'data' => $categorias,
                'total' => $categorias->count()
            ], 200);
        } catch (Exception $e) {
            return response()->json([
                'message' => 'Erro ao buscar categorias de fotos',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Criar nova categoria
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
                    'message' => 'Sem permissão para gerenciar categorias de fotos',
                    'required_permission' => 'Configurações'
                ], 403);
            }

            $validator = Validator::make($request->all(), [
                'nome' => 'required|string|max:255|unique:categorias_fotos,nome',
                'codigo' => 'required|string|max:255|unique:categorias_fotos,codigo|regex:/^[a-z0-9_]+$/',
                'descricao' => 'nullable|string',
                'ordem' => 'nullable|integer|min:0',
                'ativo' => 'nullable|boolean'
            ], [
                'nome.required' => 'O nome da categoria é obrigatório',
                'nome.unique' => 'Já existe uma categoria com este nome',
                'codigo.required' => 'O código da categoria é obrigatório',
                'codigo.unique' => 'Já existe uma categoria com este código',
                'codigo.regex' => 'O código deve conter apenas letras minúsculas, números e underscore'
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'message' => 'Erro de validação',
                    'errors' => $validator->errors()
                ], 422);
            }

            $ordem = $request->ordem;
            if ($ordem === null) {
                $maxOrdem = CategoriaFoto::max('ordem');
                $ordem = ($maxOrdem ?? 0) + 1;
            }

            $categoria = CategoriaFoto::create([
                'nome' => $request->nome,
                'codigo' => strtolower($request->codigo),
                'descricao' => $request->descricao,
                'ordem' => $ordem,
                'ativo' => $request->ativo ?? true
            ]);

            return response()->json([
                'message' => 'Categoria criada com sucesso',
                'data' => $categoria
            ], 201);
        } catch (Exception $e) {
            return response()->json([
                'message' => 'Erro ao criar categoria',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Buscar categoria específica
     */
    public function show($id)
    {
        try {
            $categoria = CategoriaFoto::findOrFail($id);

            return response()->json([
                'data' => $categoria
            ], 200);
        } catch (Exception $e) {
            return response()->json([
                'message' => 'Categoria não encontrada',
                'error' => $e->getMessage()
            ], 404);
        }
    }

    /**
     * Atualizar categoria
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
                    'message' => 'Sem permissão para gerenciar categorias de fotos',
                    'required_permission' => 'Configurações'
                ], 403);
            }

            $categoria = CategoriaFoto::find($id);

            if (!$categoria) {
                return response()->json(['message' => 'Categoria não encontrada'], 404);
            }

            $validator = Validator::make($request->all(), [
                'nome' => 'sometimes|required|string|max:255|unique:categorias_fotos,nome,' . $id,
                'codigo' => 'sometimes|required|string|max:255|unique:categorias_fotos,codigo,' . $id . '|regex:/^[a-z0-9_]+$/',
                'descricao' => 'nullable|string',
                'ordem' => 'nullable|integer|min:0',
                'ativo' => 'nullable|boolean'
            ], [
                'nome.required' => 'O nome da categoria é obrigatório',
                'nome.unique' => 'Já existe uma categoria com este nome',
                'codigo.required' => 'O código da categoria é obrigatório',
                'codigo.unique' => 'Já existe uma categoria com este código',
                'codigo.regex' => 'O código deve conter apenas letras minúsculas, números e underscore'
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

            if ($request->has('codigo')) {
                $dataToUpdate['codigo'] = strtolower($request->codigo);
            }

            if ($request->has('descricao')) {
                $dataToUpdate['descricao'] = $request->descricao;
            }

            if ($request->has('ordem')) {
                $dataToUpdate['ordem'] = $request->ordem;
            }

            if ($request->has('ativo')) {
                $dataToUpdate['ativo'] = $request->ativo;
            }

            $categoria->update($dataToUpdate);

            return response()->json([
                'message' => 'Categoria atualizada com sucesso',
                'data' => $categoria->fresh()
            ], 200);
        } catch (Exception $e) {
            return response()->json([
                'message' => 'Erro ao atualizar categoria',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Excluir categoria
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
                    'message' => 'Sem permissão para gerenciar categorias de fotos',
                    'required_permission' => 'Configurações'
                ], 403);
            }

            $categoria = CategoriaFoto::find($id);

            if (!$categoria) {
                return response()->json(['message' => 'Categoria não encontrada'], 404);
            }

            // Verificar se há fotos usando esta categoria
            $fotosUsando = $categoria->fotos()->count();

            if ($fotosUsando > 0) {
                return response()->json([
                    'message' => "Não é possível excluir esta categoria. Existem {$fotosUsando} foto(s) utilizando-a.",
                    'fotos_count' => $fotosUsando
                ], 422);
            }

            $categoria->delete();

            return response()->json([
                'message' => 'Categoria excluída com sucesso',
                'data' => null
            ], 200);
        } catch (Exception $e) {
            return response()->json([
                'message' => 'Erro ao excluir categoria',
                'error' => $e->getMessage()
            ], 500);
        }
    }
}
