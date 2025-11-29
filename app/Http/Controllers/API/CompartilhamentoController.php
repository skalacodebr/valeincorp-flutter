<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\Compartilhamento;
use App\Models\AcessoCompartilhamento;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\DB;

class CompartilhamentoController extends Controller
{
    /**
     * Listar compartilhamentos do corretor autenticado
     */
    public function index(Request $request): JsonResponse
    {
        $page = $request->get('page', 1);
        $limit = min($request->get('limit', 20), 100);

        $query = Compartilhamento::porCorretor(Auth::id())
            ->with(['entity', 'acessos'])
            ->orderBy('created_at', 'desc');

        // Filtros
        if ($request->has('entity_type')) {
            $query->porTipoEntidade($request->entity_type);
        }

        if ($request->has('entity_id')) {
            $query->where('entity_id', $request->entity_id);
        }

        if ($request->has('ativo')) {
            $query->where('ativo', filter_var($request->ativo, FILTER_VALIDATE_BOOLEAN));
        }

        if ($request->has('data_inicio') && $request->has('data_fim')) {
            $query->whereBetween('created_at', [
                $request->data_inicio,
                $request->data_fim
            ]);
        }

        if ($request->has('search')) {
            $search = trim($request->search);
            $query->where(function ($q) use ($search) {
                $q->where('nome_cliente', 'like', '%' . $search . '%')
                  ->orWhere('link_unico', 'like', '%' . $search . '%');
            });
        }

        $compartilhamentos = $query->paginate($limit, ['*'], 'page', $page);

        return response()->json([
            'success' => true,
            'data' => $compartilhamentos->map(function ($compartilhamento) {
                return $this->formatCompartilhamento($compartilhamento);
            }),
            'pagination' => [
                'currentPage' => $compartilhamentos->currentPage(),
                'totalPages' => $compartilhamentos->lastPage(),
                'totalItems' => $compartilhamentos->total(),
                'itemsPerPage' => $compartilhamentos->perPage(),
                'hasNextPage' => $compartilhamentos->hasMorePages(),
                'hasPreviousPage' => $compartilhamentos->currentPage() > 1,
            ]
        ]);
    }

    /**
     * Criar novo compartilhamento
     */
    public function store(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'entity_type' => 'required|in:empreendimento,unidade',
            'entity_id' => 'required|integer',
            'nome_cliente' => 'nullable|string|max:255',
            'anotacao' => 'nullable|string',
            'receber_notificacao' => 'boolean',
            'mostrar_espelho_vendas' => 'boolean',
            'mostrar_endereco' => 'boolean',
            'compartilhar_descricao' => 'boolean',
            'expira_em' => 'nullable|date|after:now',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Dados inválidos',
                'errors' => $validator->errors()
            ], 422);
        }

        // Verificar se a entidade existe
        $entityExists = false;
        if ($request->entity_type === 'empreendimento') {
            $entityExists = \App\Models\Empreendimento::where('id', $request->entity_id)->exists();
        } elseif ($request->entity_type === 'unidade') {
            $entityExists = \App\Models\EmpreendimentoUnidade::where('id', $request->entity_id)->exists();
        }

        if (!$entityExists) {
            return response()->json([
                'success' => false,
                'message' => 'Entidade não encontrada'
            ], 404);
        }

        $compartilhamento = Compartilhamento::create([
            'corretor_id' => Auth::id(),
            'entity_type' => $request->entity_type,
            'entity_id' => $request->entity_id,
            'nome_cliente' => $request->nome_cliente,
            'anotacao' => $request->anotacao,
            'receber_notificacao' => $request->receber_notificacao ?? false,
            'mostrar_espelho_vendas' => $request->mostrar_espelho_vendas ?? false,
            'mostrar_endereco' => $request->mostrar_endereco ?? true,
            'compartilhar_descricao' => $request->compartilhar_descricao ?? true,
            'expira_em' => $request->expira_em,
            'ativo' => true,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Compartilhamento criado com sucesso',
            'data' => $this->formatCompartilhamento($compartilhamento->load('entity'))
        ], 201);
    }

    /**
     * Obter detalhes de um compartilhamento
     */
    public function show($id): JsonResponse
    {
        $compartilhamento = Compartilhamento::porCorretor(Auth::id())
            ->with(['entity', 'acessos'])
            ->findOrFail($id);

        return response()->json([
            'success' => true,
            'data' => $this->formatCompartilhamento($compartilhamento)
        ]);
    }

    /**
     * Atualizar compartilhamento
     */
    public function update(Request $request, $id): JsonResponse
    {
        $compartilhamento = Compartilhamento::porCorretor(Auth::id())->findOrFail($id);

        $validator = Validator::make($request->all(), [
            'nome_cliente' => 'nullable|string|max:255',
            'anotacao' => 'nullable|string',
            'receber_notificacao' => 'boolean',
            'mostrar_espelho_vendas' => 'boolean',
            'mostrar_endereco' => 'boolean',
            'compartilhar_descricao' => 'boolean',
            'expira_em' => 'nullable|date|after:now',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Dados inválidos',
                'errors' => $validator->errors()
            ], 422);
        }

        $compartilhamento->update($request->only([
            'nome_cliente',
            'anotacao',
            'receber_notificacao',
            'mostrar_espelho_vendas',
            'mostrar_endereco',
            'compartilhar_descricao',
            'expira_em',
        ]));

        return response()->json([
            'success' => true,
            'message' => 'Compartilhamento atualizado com sucesso',
            'data' => $this->formatCompartilhamento($compartilhamento->load('entity'))
        ]);
    }

    /**
     * Desativar compartilhamento
     */
    public function destroy($id): JsonResponse
    {
        $compartilhamento = Compartilhamento::porCorretor(Auth::id())->findOrFail($id);

        $compartilhamento->update(['ativo' => false]);

        return response()->json([
            'success' => true,
            'message' => 'Compartilhamento desativado com sucesso'
        ]);
    }

    /**
     * Obter estatísticas de um compartilhamento
     */
    public function estatisticas($id): JsonResponse
    {
        $compartilhamento = Compartilhamento::porCorretor(Auth::id())->findOrFail($id);

        $acessos = AcessoCompartilhamento::porCompartilhamento($compartilhamento->id)
            ->selectRaw('DATE(acessado_at) as data, COUNT(*) as total')
            ->groupBy('data')
            ->orderBy('data', 'desc')
            ->get();

        $totalAcessos = $compartilhamento->acessos()->count();
        $acessosUnicos = $compartilhamento->acessos()->distinct('ip_address')->count('ip_address');

        return response()->json([
            'success' => true,
            'data' => [
                'total_visualizacoes' => $compartilhamento->total_visualizacoes,
                'total_acessos' => $totalAcessos,
                'acessos_unicos' => $acessosUnicos,
                'ultima_visualizacao' => $compartilhamento->ultima_visualizacao_at?->toISOString(),
                'acessos_por_data' => $acessos,
                'criado_em' => $compartilhamento->created_at->toISOString(),
            ]
        ]);
    }

    /**
     * Formatar compartilhamento para resposta
     */
    private function formatCompartilhamento(Compartilhamento $compartilhamento): array
    {
        $entity = null;
        if ($compartilhamento->entity_type === 'empreendimento') {
            $entity = $compartilhamento->empreendimento;
        } elseif ($compartilhamento->entity_type === 'unidade') {
            $entity = $compartilhamento->unidade;
        }

        return [
            'id' => $compartilhamento->id,
            'corretor_id' => $compartilhamento->corretor_id,
            'entity_type' => $compartilhamento->entity_type,
            'entity_id' => $compartilhamento->entity_id,
            'entity' => $entity ? [
                'id' => $entity->id,
                'nome' => $entity->nome ?? ($entity->codigo ?? 'N/A'),
            ] : null,
            'link_unico' => $compartilhamento->link_unico,
            'url_completa' => $compartilhamento->url_completa,
            'nome_cliente' => $compartilhamento->nome_cliente,
            'anotacao' => $compartilhamento->anotacao,
            'receber_notificacao' => $compartilhamento->receber_notificacao,
            'mostrar_espelho_vendas' => $compartilhamento->mostrar_espelho_vendas,
            'mostrar_endereco' => $compartilhamento->mostrar_endereco,
            'compartilhar_descricao' => $compartilhamento->compartilhar_descricao,
            'total_visualizacoes' => $compartilhamento->total_visualizacoes,
            'ultima_visualizacao_at' => $compartilhamento->ultima_visualizacao_at?->toISOString(),
            'ativo' => $compartilhamento->ativo,
            'is_expirado' => $compartilhamento->isExpirado(),
            'expira_em' => $compartilhamento->expira_em?->toISOString(),
            'created_at' => $compartilhamento->created_at->toISOString(),
            'updated_at' => $compartilhamento->updated_at->toISOString(),
        ];
    }
}
