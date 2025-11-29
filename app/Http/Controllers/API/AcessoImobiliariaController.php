<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\AcessoImobiliaria;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Auth;

class AcessoImobiliariaController extends Controller
{
    /**
     * Listar acessos de imobiliárias
     */
    public function index(Request $request): JsonResponse
    {
        $page = $request->get('page', 1);
        $limit = min($request->get('limit', 50), 100);

        $query = AcessoImobiliaria::with(['imobiliaria', 'user'])
            ->orderBy('acessado_at', 'desc');

        // Filtros
        if ($request->has('imobiliaria_id')) {
            $query->porImobiliaria($request->imobiliaria_id);
        }

        if ($request->has('tipo_acesso')) {
            $query->porTipoAcesso($request->tipo_acesso);
        }

        if ($request->has('data_inicio') && $request->has('data_fim')) {
            $query->porPeriodo($request->data_inicio, $request->data_fim);
        } elseif ($request->has('data')) {
            $query->porData($request->data);
        }

        $acessos = $query->paginate($limit, ['*'], 'page', $page);

        return response()->json([
            'success' => true,
            'data' => $acessos->map(function ($acesso) {
                return [
                    'id' => $acesso->id,
                    'imobiliaria' => $acesso->imobiliaria ? [
                        'id' => $acesso->imobiliaria->id,
                        'nome' => $acesso->imobiliaria->nome,
                    ] : null,
                    'user' => $acesso->user ? [
                        'id' => $acesso->user->id,
                        'nome' => $acesso->user->nome,
                        'email' => $acesso->user->email,
                    ] : null,
                    'tipo_acesso' => $acesso->tipo_acesso,
                    'ip_address' => $acesso->ip_address,
                    'user_agent' => $acesso->user_agent,
                    'acessado_at' => $acesso->acessado_at->toISOString(),
                    'detalhes' => $acesso->detalhes,
                ];
            }),
            'pagination' => [
                'currentPage' => $acessos->currentPage(),
                'totalPages' => $acessos->lastPage(),
                'totalItems' => $acessos->total(),
                'itemsPerPage' => $acessos->perPage(),
                'hasNextPage' => $acessos->hasMorePages(),
                'hasPreviousPage' => $acessos->currentPage() > 1,
            ]
        ]);
    }

    /**
     * Registrar acesso de imobiliária
     */
    public function store(Request $request): JsonResponse
    {
        $acesso = AcessoImobiliaria::create([
            'imobiliaria_id' => $request->imobiliaria_id ?? Auth::user()?->imobiliarias_id,
            'user_id' => Auth::id(),
            'tipo_acesso' => $request->tipo_acesso ?? 'api_call',
            'ip_address' => $request->ip() ?? $request->ip_address,
            'user_agent' => $request->userAgent() ?? $request->user_agent,
            'acessado_at' => now(),
            'detalhes' => $request->detalhes,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Acesso registrado com sucesso',
            'data' => [
                'id' => $acesso->id,
                'tipo_acesso' => $acesso->tipo_acesso,
                'acessado_at' => $acesso->acessado_at->toISOString(),
            ]
        ], 201);
    }

    /**
     * Obter estatísticas de acessos
     */
    public function estatisticas(Request $request): JsonResponse
    {
        $query = AcessoImobiliaria::query();

        if ($request->has('imobiliaria_id')) {
            $query->porImobiliaria($request->imobiliaria_id);
        }

        if ($request->has('data_inicio') && $request->has('data_fim')) {
            $query->porPeriodo($request->data_inicio, $request->data_fim);
        }

        $totalAcessos = $query->count();
        $acessosPorTipo = $query->clone()
            ->selectRaw('tipo_acesso, COUNT(*) as total')
            ->groupBy('tipo_acesso')
            ->get()
            ->pluck('total', 'tipo_acesso');

        $acessosPorData = $query->clone()
            ->selectRaw('DATE(acessado_at) as data, COUNT(*) as total')
            ->groupBy('data')
            ->orderBy('data', 'desc')
            ->limit(30)
            ->get();

        return response()->json([
            'success' => true,
            'data' => [
                'total_acessos' => $totalAcessos,
                'acessos_por_tipo' => $acessosPorTipo,
                'acessos_por_data' => $acessosPorData,
            ]
        ]);
    }
}
