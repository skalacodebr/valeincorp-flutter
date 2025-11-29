<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\EvolucaoObra;
use App\Models\Empreendimento;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;

class EvolucaoObraController extends Controller
{
    public function index(Request $request)
    {
        $perPage = $request->get('per_page', 10);
        $query = EvolucaoObra::with('empreendimento:id,nome')
            ->orderByDataCriacao();

        if ($request->has('empreendimento_id')) {
            $query->byEmpreendimento($request->empreendimento_id);
        }

        $evolucoes = $query->paginate($perPage);

        return response()->json($evolucoes);
    }

    public function show($id)
    {
        $evolucao = EvolucaoObra::with([
            'empreendimento' => function ($query) {
                $query->select('id', 'nome')
                    ->with('endereco');
            }
        ])->findOrFail($id);

        return response()->json($evolucao);
    }

    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'nome' => 'required|string|max:255',
            'empreendimento_id' => 'nullable|exists:empreendimentos,id',
            'data_criacao' => 'required|date|before_or_equal:today',
            'descricao' => 'nullable|string',
            'percentual_conclusao' => 'nullable|integer|min:0|max:100'
        ], [
            'nome.required' => 'O campo nome é obrigatório.',
            'nome.max' => 'O campo nome deve ter no máximo 255 caracteres.',
            'empreendimento_id.exists' => 'O empreendimento selecionado não existe.',
            'data_criacao.required' => 'O campo data de criação é obrigatório.',
            'data_criacao.date' => 'O campo data de criação deve ser uma data válida.',
            'data_criacao.before_or_equal' => 'A data de criação não pode ser futura.',
            'percentual_conclusao.min' => 'O percentual de conclusão deve ser no mínimo 0.',
            'percentual_conclusao.max' => 'O percentual de conclusão deve ser no máximo 100.'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Os dados fornecidos são inválidos.',
                'errors' => $validator->errors()
            ], 422);
        }

        $data = $request->all();
        $data['created_by'] = Auth::id();
        $data['updated_by'] = Auth::id();

        $evolucao = EvolucaoObra::create($data);

        return response()->json($evolucao->fresh(), 201);
    }

    public function update(Request $request, $id)
    {
        $evolucao = EvolucaoObra::findOrFail($id);

        $validator = Validator::make($request->all(), [
            'nome' => 'sometimes|required|string|max:255',
            'data_criacao' => 'sometimes|required|date|before_or_equal:today',
            'descricao' => 'nullable|string',
            'percentual_conclusao' => 'nullable|integer|min:0|max:100'
        ], [
            'nome.required' => 'O campo nome é obrigatório.',
            'nome.max' => 'O campo nome deve ter no máximo 255 caracteres.',
            'data_criacao.required' => 'O campo data de criação é obrigatório.',
            'data_criacao.date' => 'O campo data de criação deve ser uma data válida.',
            'data_criacao.before_or_equal' => 'A data de criação não pode ser futura.',
            'percentual_conclusao.min' => 'O percentual de conclusão deve ser no mínimo 0.',
            'percentual_conclusao.max' => 'O percentual de conclusão deve ser no máximo 100.'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Os dados fornecidos são inválidos.',
                'errors' => $validator->errors()
            ], 422);
        }

        $data = $request->only(['nome', 'data_criacao', 'descricao', 'percentual_conclusao']);
        $data['updated_by'] = Auth::id();

        $evolucao->update($data);

        return response()->json($evolucao->fresh());
    }

    public function destroy($id)
    {
        $evolucao = EvolucaoObra::findOrFail($id);
        $evolucao->delete();

        return response()->json(null, 204);
    }

    public function byEmpreendimento($empreendimentoId)
    {
        $empreendimento = Empreendimento::findOrFail($empreendimentoId);
        
        $evolucoes = EvolucaoObra::byEmpreendimento($empreendimentoId)
            ->orderByDataCriacao()
            ->get();

        return response()->json([
            'data' => $evolucoes
        ]);
    }
}