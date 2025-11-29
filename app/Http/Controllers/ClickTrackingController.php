<?php

namespace App\Http\Controllers;

use App\Models\ClickTracking;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;

class ClickTrackingController extends Controller
{
    /**
     * Teste de autenticação
     */
    public function testAuth(Request $request): JsonResponse
    {
        $userId = Auth::id();
        $user = Auth::user();
        $token = $request->bearerToken();
        
        // Verificar qual modelo está sendo usado
        $userModel = Auth::getProvider()->getModel();
        $userTable = $userModel ? $userModel->getTable() : 'unknown';
        
        return response()->json([
            'success' => true,
            'debug' => [
                'user_id' => $userId,
                'user' => $user ? $user->toArray() : null,
                'has_token' => !empty($token),
                'token_preview' => $token ? substr($token, 0, 20) . '...' : null,
                'auth_check' => Auth::check(),
                'auth_guard' => Auth::getDefaultDriver(),
                'user_model' => $userModel ? get_class($userModel) : null,
                'user_table' => $userTable,
                'headers' => $request->headers->all(),
            ]
        ]);
    }

    /**
     * Registra um clique em uma entidade
     */
    public function trackClick(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'entity_type' => 'required|string|in:empreendimento,unidade',
            'entity_id' => 'required|integer|min:1',
            'action_type' => 'required|string|in:view,share',
            'share_platform' => 'nullable|string|in:whatsapp,link,facebook,twitter,instagram',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Dados inválidos',
                'errors' => $validator->errors()
            ], 422);
        }

        try {
            // Verificar autenticação sem usar Auth::id() diretamente
            $user = Auth::user();
            $userId = $user ? $user->id : null;
            $token = $request->bearerToken();
            
            \Log::info('🔍 [CLICK-TRACKING] Debug info:', [
                'user_id' => $userId,
                'user_object' => $user ? $user->toArray() : 'null',
                'has_token' => !empty($token),
                'token_preview' => $token ? substr($token, 0, 20) . '...' : 'null',
                'auth_check' => Auth::check(),
                'auth_guard' => Auth::getDefaultDriver(),
                'request_headers' => $request->headers->all(),
                'request_data' => $request->all(),
                'ip' => $request->ip(),
            ]);

            $clickData = [
                'user_id' => $userId,
                'entity_type' => $request->entity_type,
                'entity_id' => $request->entity_id,
                'action_type' => $request->action_type,
                'share_platform' => $request->share_platform,
                'ip_address' => $request->ip(),
                'user_agent' => $request->userAgent(),
                'click_date' => now()->format('Y-m-d'),
                'clicked_at' => now(),
            ];

            $click = ClickTracking::create($clickData);
            
            \Log::info('✅ [CLICK-TRACKING] Clique registrado:', [
                'click_id' => $click->id,
                'user_id' => $click->user_id,
                'entity_type' => $click->entity_type,
                'entity_id' => $click->entity_id,
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Clique registrado com sucesso'
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erro ao registrar clique: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Estatísticas por entidade
     */
    public function getEntityStats(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'entity_type' => 'nullable|string|in:empreendimento,unidade',
            'entity_id' => 'nullable|integer|min:1',
            'start_date' => 'nullable|date',
            'end_date' => 'nullable|date|after_or_equal:start_date',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Parâmetros inválidos',
                'errors' => $validator->errors()
            ], 422);
        }

        $query = ClickTracking::query();

        if ($request->entity_type) {
            $query->where('entity_type', $request->entity_type);
        }

        if ($request->entity_id) {
            $query->where('entity_id', $request->entity_id);
        }

        if ($request->start_date) {
            $query->where('click_date', '>=', $request->start_date);
        }

        if ($request->end_date) {
            $query->where('click_date', '<=', $request->end_date);
        }

        $stats = $query->selectRaw('
            entity_type,
            entity_id,
            action_type,
            click_date,
            COUNT(*) as total_clicks,
            COUNT(DISTINCT user_id) as unique_users,
            COUNT(DISTINCT ip_address) as unique_ips
        ')
        ->groupBy('entity_type', 'entity_id', 'action_type', 'click_date')
        ->orderBy('click_date', 'desc')
        ->get();

        return response()->json([
            'success' => true,
            'data' => $stats
        ]);
    }

    /**
     * Estatísticas de compartilhamento
     */
    public function getShareStats(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'entity_type' => 'nullable|string|in:empreendimento,unidade',
            'entity_id' => 'nullable|integer|min:1',
            'start_date' => 'nullable|date',
            'end_date' => 'nullable|date|after_or_equal:start_date',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Parâmetros inválidos',
                'errors' => $validator->errors()
            ], 422);
        }

        $query = ClickTracking::where('action_type', 'share');

        if ($request->entity_type) {
            $query->where('entity_type', $request->entity_type);
        }

        if ($request->entity_id) {
            $query->where('entity_id', $request->entity_id);
        }

        if ($request->start_date) {
            $query->where('click_date', '>=', $request->start_date);
        }

        if ($request->end_date) {
            $query->where('click_date', '<=', $request->end_date);
        }

        $stats = $query->selectRaw('
            entity_type,
            entity_id,
            share_platform,
            click_date,
            COUNT(*) as total_shares
        ')
        ->groupBy('entity_type', 'entity_id', 'share_platform', 'click_date')
        ->orderBy('click_date', 'desc')
        ->get();

        return response()->json([
            'success' => true,
            'data' => $stats
        ]);
    }

    /**
     * Estatísticas gerais
     */
    public function getGeneralStats(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'start_date' => 'nullable|date',
            'end_date' => 'nullable|date|after_or_equal:start_date',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Parâmetros inválidos',
                'errors' => $validator->errors()
            ], 422);
        }

        $query = ClickTracking::query();

        if ($request->start_date) {
            $query->where('click_date', '>=', $request->start_date);
        }

        if ($request->end_date) {
            $query->where('click_date', '<=', $request->end_date);
        }

        $stats = $query->selectRaw('
            action_type,
            entity_type,
            click_date,
            COUNT(*) as total_clicks,
            COUNT(DISTINCT user_id) as unique_users,
            COUNT(DISTINCT ip_address) as unique_ips
        ')
        ->groupBy('action_type', 'entity_type', 'click_date')
        ->orderBy('click_date', 'desc')
        ->get();

        return response()->json([
            'success' => true,
            'data' => $stats
        ]);
    }

    /**
     * Estatísticas do usuário autenticado
     */
    public function getUserStats(Request $request): JsonResponse
    {
        $user = Auth::user();
        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'Usuário não autenticado'
            ], 401);
        }

        $validator = Validator::make($request->all(), [
            'start_date' => 'nullable|date',
            'end_date' => 'nullable|date|after_or_equal:start_date',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Parâmetros inválidos',
                'errors' => $validator->errors()
            ], 422);
        }

        $query = ClickTracking::where('user_id', $user->id);

        if ($request->start_date) {
            $query->where('click_date', '>=', $request->start_date);
        }

        if ($request->end_date) {
            $query->where('click_date', '<=', $request->end_date);
        }

        $stats = $query->selectRaw('
            entity_type,
            entity_id,
            action_type,
            click_date,
            COUNT(*) as total_clicks
        ')
        ->groupBy('entity_type', 'entity_id', 'action_type', 'click_date')
        ->orderBy('click_date', 'desc')
        ->get();

        return response()->json([
            'success' => true,
            'data' => $stats
        ]);
    }

    /**
     * Estatísticas por corretor (para relatórios admin)
     */
    public function getCorretorStats(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'start_date' => 'nullable|date',
            'end_date' => 'nullable|date|after_or_equal:start_date',
            'corretor_id' => 'nullable|integer|min:1',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Parâmetros inválidos',
                'errors' => $validator->errors()
            ], 422);
        }

        $query = ClickTracking::whereNotNull('user_id');

        if ($request->corretor_id) {
            $query->where('user_id', $request->corretor_id);
        }

        if ($request->start_date) {
            $query->where('click_date', '>=', $request->start_date);
        }

        if ($request->end_date) {
            $query->where('click_date', '<=', $request->end_date);
        }

        $stats = $query->selectRaw('
            user_id,
            entity_type,
            action_type,
            click_date,
            COUNT(*) as total_clicks,
            COUNT(DISTINCT entity_id) as unique_entities
        ')
        ->groupBy('user_id', 'entity_type', 'action_type', 'click_date')
        ->orderBy('click_date', 'desc')
        ->get();

        // Buscar nomes dos corretores
        $corretorIds = $stats->pluck('user_id')->unique()->filter();
        
        \Log::info('🔍 [CORRETOR-STATS] Debug info:', [
            'corretor_ids' => $corretorIds->toArray(),
            'stats_count' => $stats->count(),
        ]);
        
        $corretores = collect();
        if ($corretorIds->isNotEmpty()) {
            try {
                $corretores = \App\Models\Corretor::whereIn('id', $corretorIds)->pluck('nome', 'id');
            } catch (\Exception $e) {
                \Log::error('❌ [CORRETOR-STATS] Erro ao buscar corretores:', [
                    'error' => $e->getMessage(),
                    'corretor_ids' => $corretorIds->toArray(),
                ]);
                $corretores = collect();
            }
        }

        // Transformar dados para o formato esperado pelo frontend
        $transformedStats = $stats->map(function ($stat) use ($corretores) {
            return [
                'corretor_id' => $stat->user_id,
                'corretor_nome' => $corretores->get($stat->user_id) ?? 'Corretor ' . $stat->user_id,
                'total_views' => $stat->action_type === 'view' ? $stat->total_clicks : 0,
                'total_shares' => $stat->action_type === 'share' ? $stat->total_clicks : 0,
                'empreendimentos_visualizados' => $stat->entity_type === 'empreendimento' ? $stat->unique_entities : 0,
                'unidades_visualizadas' => $stat->entity_type === 'unidade' ? $stat->unique_entities : 0,
                'periodo' => $stat->click_date,
            ];
        });

        return response()->json([
            'success' => true,
            'data' => $transformedStats
        ]);
    }

    /**
     * Estatísticas por empreendimento (para relatórios admin)
     */
    public function getEmpreendimentoStats(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'start_date' => 'nullable|date',
            'end_date' => 'nullable|date|after_or_equal:start_date',
            'entity_type' => 'nullable|string|in:empreendimento,unidade',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Parâmetros inválidos',
                'errors' => $validator->errors()
            ], 422);
        }

        $query = ClickTracking::query();

        if ($request->entity_type) {
            $query->where('entity_type', $request->entity_type);
        }

        if ($request->start_date) {
            $query->where('click_date', '>=', $request->start_date);
        }

        if ($request->end_date) {
            $query->where('click_date', '<=', $request->end_date);
        }

        $stats = $query->selectRaw('
            entity_type,
            entity_id,
            action_type,
            click_date,
            COUNT(*) as total_clicks,
            COUNT(DISTINCT user_id) as unique_users,
            COUNT(DISTINCT ip_address) as unique_ips
        ')
        ->groupBy('entity_type', 'entity_id', 'action_type', 'click_date')
        ->orderBy('total_clicks', 'desc')
        ->orderBy('click_date', 'desc')
        ->get();

        // Buscar nomes dos empreendimentos
        $empreendimentoIds = $stats->pluck('entity_id')->unique()->filter();
        
        $empreendimentos = collect();
        if ($empreendimentoIds->isNotEmpty()) {
            try {
                $empreendimentos = \App\Models\Empreendimento::whereIn('id', $empreendimentoIds)->pluck('nome', 'id');
            } catch (\Exception $e) {
                \Log::error('❌ [EMPREENDIMENTO-STATS] Erro ao buscar empreendimentos:', [
                    'error' => $e->getMessage(),
                    'empreendimento_ids' => $empreendimentoIds->toArray(),
                ]);
                $empreendimentos = collect();
            }
        }

        // Transformar dados para o formato esperado pelo frontend
        $transformedStats = $stats->map(function ($stat) use ($empreendimentos) {
            return [
                'empreendimento_id' => $stat->entity_id,
                'empreendimento_nome' => $empreendimentos->get($stat->entity_id) ?? 'Empreendimento ' . $stat->entity_id,
                'total_views' => $stat->action_type === 'view' ? $stat->total_clicks : 0,
                'total_shares' => $stat->action_type === 'share' ? $stat->total_clicks : 0,
                'unique_users' => $stat->unique_users,
                'periodo' => $stat->click_date,
            ];
        });

        return response()->json([
            'success' => true,
            'data' => $transformedStats
        ]);
    }

    /**
     * Top empreendimentos mais visualizados
     */
    public function getTopEmpreendimentos(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'start_date' => 'nullable|date',
            'end_date' => 'nullable|date|after_or_equal:start_date',
            'limit' => 'nullable|integer|min:1|max:100',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Parâmetros inválidos',
                'errors' => $validator->errors()
            ], 422);
        }

        $query = ClickTracking::where('action_type', 'view');

        if ($request->start_date) {
            $query->where('click_date', '>=', $request->start_date);
        }

        if ($request->end_date) {
            $query->where('click_date', '<=', $request->end_date);
        }

        $stats = $query->selectRaw('
            entity_type,
            entity_id,
            COUNT(*) as total_views,
            COUNT(DISTINCT user_id) as unique_users,
            COUNT(DISTINCT ip_address) as unique_ips
        ')
        ->groupBy('entity_type', 'entity_id')
        ->orderBy('total_views', 'desc')
        ->limit($request->limit ?? 10)
        ->get();

        return response()->json([
            'success' => true,
            'data' => $stats
        ]);
    }

    /**
     * Estatísticas diárias
     */
    public function getDailyStats(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'start_date' => 'nullable|date',
            'end_date' => 'nullable|date|after_or_equal:start_date',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Parâmetros inválidos',
                'errors' => $validator->errors()
            ], 422);
        }

        $query = ClickTracking::query();

        if ($request->start_date) {
            $query->where('click_date', '>=', $request->start_date);
        }

        if ($request->end_date) {
            $query->where('click_date', '<=', $request->end_date);
        }

        $stats = $query->selectRaw('
            click_date,
            action_type,
            entity_type,
            COUNT(*) as total_clicks,
            COUNT(DISTINCT user_id) as unique_users,
            COUNT(DISTINCT ip_address) as unique_ips
        ')
        ->groupBy('click_date', 'action_type', 'entity_type')
        ->orderBy('click_date', 'desc')
        ->get();

        return response()->json([
            'success' => true,
            'data' => $stats
        ]);
    }

    /**
     * Estatísticas detalhadas de um corretor em um empreendimento específico
     */
    public function getCorretorEmpreendimentoStats(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'corretor_id' => 'required|integer|min:1',
            'empreendimento_id' => 'required|integer|min:1',
            'start_date' => 'nullable|date',
            'end_date' => 'nullable|date|after_or_equal:start_date',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Parâmetros inválidos',
                'errors' => $validator->errors()
            ], 422);
        }

        $query = ClickTracking::where('user_id', $request->corretor_id)
            ->where('entity_type', 'empreendimento')
            ->where('entity_id', $request->empreendimento_id);

        if ($request->start_date) {
            $query->where('click_date', '>=', $request->start_date);
        }

        if ($request->end_date) {
            $query->where('click_date', '<=', $request->end_date);
        }

        // Buscar dados agrupados por data e ação
        $stats = $query->selectRaw('
            click_date,
            action_type,
            share_platform,
            COUNT(*) as total_clicks
        ')
        ->groupBy('click_date', 'action_type', 'share_platform')
        ->orderBy('click_date', 'desc')
        ->get();

        // Buscar informações do corretor e empreendimento
        $corretor = \App\Models\Corretor::find($request->corretor_id);
        $empreendimento = \App\Models\Empreendimento::find($request->empreendimento_id);

        // Calcular totais
        $totalViews = $stats->where('action_type', 'view')->sum('total_clicks');
        $totalShares = $stats->where('action_type', 'share')->sum('total_clicks');

        // Agrupar por plataforma de compartilhamento
        $sharesByPlatform = $stats->where('action_type', 'share')
            ->groupBy('share_platform')
            ->map(function ($group) {
                return $group->sum('total_clicks');
            });

        // Agrupar por data
        $statsByDate = $stats->groupBy('click_date')->map(function ($dayStats) {
            return [
                'views' => $dayStats->where('action_type', 'view')->sum('total_clicks'),
                'shares' => $dayStats->where('action_type', 'share')->sum('total_clicks'),
                'shares_by_platform' => $dayStats->where('action_type', 'share')
                    ->groupBy('share_platform')
                    ->map(function ($group) {
                        return $group->sum('total_clicks');
                    })
            ];
        });

        return response()->json([
            'success' => true,
            'data' => [
                'corretor' => [
                    'id' => $corretor ? $corretor->id : null,
                    'nome' => $corretor ? $corretor->nome : 'Corretor não encontrado',
                ],
                'empreendimento' => [
                    'id' => $empreendimento ? $empreendimento->id : null,
                    'nome' => $empreendimento ? $empreendimento->nome : 'Empreendimento não encontrado',
                ],
                'totais' => [
                    'total_views' => $totalViews,
                    'total_shares' => $totalShares,
                ],
                'shares_por_plataforma' => $sharesByPlatform,
                'estatisticas_por_data' => $statsByDate,
                'periodo' => [
                    'inicio' => $request->start_date,
                    'fim' => $request->end_date,
                ]
            ]
        ]);
    }
}
