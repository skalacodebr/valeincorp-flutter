<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\API\AuthController;
use App\Http\Controllers\API\UserController;
use App\Http\Controllers\API\ImovelController;
use App\Http\Controllers\API\FavoritoController;
use App\Http\Controllers\API\ConstrutorController;
use App\Http\Controllers\API\NotificationController;
use App\Http\Controllers\API\FileUploadController;
use App\Http\Controllers\API\EmpreendimentoStatusController;
use App\Http\Controllers\API\CompartilhamentoController;
use App\Http\Controllers\API\AcessoImobiliariaController;

/*
|--------------------------------------------------------------------------
| Vale Incorp API Routes
|--------------------------------------------------------------------------
|
| Rotas específicas para o aplicativo Vale Incorp conforme documentação
| API_DOCUMENTATION.md
|
*/

// ================================================
// ROTAS DE AUTENTICAÇÃO (/api/auth/*)
// ================================================
Route::prefix('auth')->group(function () {
    Route::post('/login', [AuthController::class, 'login']);
    Route::post('/register', [AuthController::class, 'register']);
    Route::post('/forgot-password', [AuthController::class, 'forgotPassword']);
    Route::post('/reset-password', [AuthController::class, 'resetPassword']);
    Route::post('/refresh', [AuthController::class, 'refresh']);
});

// ================================================
// ROTAS DE USUÁRIOS (/api/users/*) - REQUER AUTH
// ================================================
Route::middleware('auth:sanctum')->prefix('users')->group(function () {
    Route::get('/profile', [UserController::class, 'profile']);
    Route::put('/profile', [UserController::class, 'updateProfile']);
    Route::post('/change-password', [UserController::class, 'changePassword']);
    Route::post('/upload-avatar', [UserController::class, 'uploadAvatar']);
});

// ================================================
// ROTAS DE IMÓVEIS (/api/imoveis/*)
// ================================================
Route::prefix('imoveis')->group(function () {
    Route::get('/', [ImovelController::class, 'index']);
    Route::get('/{id}', [ImovelController::class, 'show']);
    Route::get('/{id}/images/{storyType}', [ImovelController::class, 'getImages']);
});

// ================================================
// ROTAS DE STATUS DE EMPREENDIMENTOS (/api/empreendimentos-status/*)
// ================================================
Route::prefix('empreendimentos-status')->group(function () {
    Route::get('/', [EmpreendimentoStatusController::class, 'index']);
    Route::get('/{id}', [EmpreendimentoStatusController::class, 'show']);
    Route::post('/', [EmpreendimentoStatusController::class, 'store']);
    Route::put('/{id}', [EmpreendimentoStatusController::class, 'update']);
    Route::delete('/{id}', [EmpreendimentoStatusController::class, 'destroy']);
});

// ================================================
// ROTAS DE FAVORITOS (/api/favoritos/*) - REQUER AUTH
// ================================================
Route::middleware('auth:sanctum')->prefix('favoritos')->group(function () {
    Route::get('/', [FavoritoController::class, 'index']);
    Route::post('/', [FavoritoController::class, 'store']);
    Route::delete('/{imovelId}', [FavoritoController::class, 'destroy']);
    Route::get('/check/{imovelId}', [FavoritoController::class, 'check']);
    Route::get('/count', [FavoritoController::class, 'count']);
});

// ================================================
// ROTAS DE COMPARTILHAMENTOS (/api/compartilhamentos/*) - REQUER AUTH
// ================================================
Route::middleware('auth:sanctum')->prefix('compartilhamentos')->group(function () {
    Route::get('/', [CompartilhamentoController::class, 'index']);
    Route::post('/', [CompartilhamentoController::class, 'store']);
    Route::get('/{id}/estatisticas', [CompartilhamentoController::class, 'estatisticas']);
    Route::get('/{id}', [CompartilhamentoController::class, 'show']);
    Route::put('/{id}', [CompartilhamentoController::class, 'update']);
    Route::delete('/{id}', [CompartilhamentoController::class, 'destroy']);
});

// ================================================
// ROTAS DE TESTE - COMPARTILHAMENTOS SEM AUTH (APENAS PARA DESENVOLVIMENTO LOCAL)
// ================================================
if (app()->environment('local')) {
    Route::prefix('test-compartilhamentos')->group(function () {
        // Criar compartilhamento de teste (sem autenticação)
        Route::post('/', function (Request $request) {
            $validator = \Illuminate\Support\Facades\Validator::make($request->all(), [
                'entity_type' => 'required|in:empreendimento,unidade',
                'entity_id' => 'required|integer',
                'nome_cliente' => 'nullable|string|max:255',
                'corretor_id' => 'nullable|integer', // Opcional para testes
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Dados inválidos',
                    'errors' => $validator->errors()
                ], 422);
            }

            $compartilhamento = \App\Models\Compartilhamento::create([
                'corretor_id' => $request->corretor_id ?? 1,
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
                'message' => 'Compartilhamento criado com sucesso (MODO TESTE)',
                'data' => [
                    'id' => $compartilhamento->id,
                    'link_unico' => $compartilhamento->link_unico,
                    'url_completa' => $compartilhamento->url_completa,
                    'entity_type' => $compartilhamento->entity_type,
                    'entity_id' => $compartilhamento->entity_id,
                    'nome_cliente' => $compartilhamento->nome_cliente,
                    'created_at' => $compartilhamento->created_at->toISOString(),
                ]
            ], 201);
        });

        // Listar compartilhamentos (sem autenticação)
        Route::get('/', function () {
            $compartilhamentos = \App\Models\Compartilhamento::orderBy('created_at', 'desc')->get();
            return response()->json([
                'success' => true,
                'data' => $compartilhamentos
            ]);
        });
    });
}

// ================================================
// ROTAS DE TESTE - FAVORITOS SEM AUTH (PARA DESENVOLVIMENTO)
// ================================================
Route::prefix('test-favoritos')->group(function () {
    // Listar favoritos de um corretor de teste
    Route::get('/', function (Request $request) {
        $corretorId = $request->get('corretor_id', 1);
        
        $favoritos = \App\Models\Favorito::with([
            'empreendimento.endereco', 
            'empreendimento.imagensArquivos', 
            'empreendimento.fotosUnidades', 
            'empreendimento.unidades',
        ])
        ->where('corretor_id', $corretorId)
        ->orderBy('created_at', 'desc')
        ->get();

        $data = $favoritos->map(function ($favorito) {
            $emp = $favorito->empreendimento;
            if (!$emp) return null;
            
            return [
                'id' => $favorito->id,
                'imovelId' => $emp->id,
                'imovel' => [
                    'id' => $emp->id,
                    'codigo' => $emp->codigo ?? 'VIC' . str_pad($emp->id, 3, '0', STR_PAD_LEFT),
                    'nome' => $emp->nome ?? '',
                    'imagem' => $emp->fotosUnidades->first()?->fotos_url 
                              ?? $emp->imagensArquivos->first()?->arquivo_url 
                              ?? null,
                    'localizacao' => ($emp->endereco?->bairro ?? '') . ' - ' . ($emp->endereco?->cidade ?? ''),
                    'cidade' => $emp->endereco?->cidade ?? '',
                    'status' => $emp->status ?? 'Em Comercialização',
                    'preco' => $emp->unidades->avg('valor') ?? 0,
                    'precoFormatado' => 'R$ ' . number_format($emp->unidades->avg('valor') ?? 0, 2, ',', '.'),
                    'dormitorios' => $emp->unidades->first()?->quarto ?? 0,
                    'banheiros' => $emp->unidades->first()?->banheiro ?? 0,
                    'suites' => $emp->unidades->first()?->suite ?? 0,
                    'vagas' => $emp->unidades->first()?->vaga_garagem ?? 0,
                    'area' => $emp->unidades->first()?->area_privativa ?? 0,
                    'unidadesDisponiveis' => $emp->unidades->where('status', 'disponivel')->count(),
                    'totalUnidades' => $emp->unidades->count(),
                    'unidadesVendidas' => $emp->unidades->where('status', 'vendida')->count(),
                    'percentualVendido' => $emp->unidades->count() > 0 
                        ? round(($emp->unidades->where('status', 'vendida')->count() / $emp->unidades->count()) * 100, 1)
                        : 0,
                ],
                'favoritadoEm' => $favorito->created_at->toISOString(),
            ];
        })->filter()->values();

        return response()->json([
            'success' => true,
            'data' => $data,
            'pagination' => [
                'currentPage' => 1,
                'totalPages' => 1,
                'totalItems' => $data->count(),
                'itemsPerPage' => 20,
                'hasNextPage' => false,
                'hasPreviousPage' => false
            ]
        ]);
    });

    // Adicionar favorito
    Route::post('/', function (Request $request) {
        $corretorId = $request->get('corretor_id', 1);
        $imovelId = $request->get('imovelId') ?? $request->get('imovel_id');
        
        if (!$imovelId) {
            return response()->json([
                'success' => false,
                'message' => 'imovelId é obrigatório'
            ], 422);
        }

        // Verifica se já existe
        $existente = \App\Models\Favorito::where('corretor_id', $corretorId)
            ->where('empreendimento_id', $imovelId)
            ->first();

        if ($existente) {
            return response()->json([
                'success' => true,
                'message' => 'Imóvel já está nos favoritos',
                'data' => ['id' => $existente->id]
            ]);
        }

        $favorito = \App\Models\Favorito::create([
            'corretor_id' => $corretorId,
            'empreendimento_id' => $imovelId,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Favorito adicionado com sucesso',
            'data' => ['id' => $favorito->id]
        ], 201);
    });

    // Remover favorito
    Route::delete('/{imovelId}', function ($imovelId, Request $request) {
        $corretorId = $request->get('corretor_id', 1);
        
        $favorito = \App\Models\Favorito::where('corretor_id', $corretorId)
            ->where('empreendimento_id', $imovelId)
            ->first();

        if (!$favorito) {
            return response()->json([
                'success' => false,
                'message' => 'Favorito não encontrado'
            ], 404);
        }

        $favorito->delete();

        return response()->json([
            'success' => true,
            'message' => 'Favorito removido com sucesso'
        ]);
    });

    // Verificar se é favorito
    Route::get('/check/{imovelId}', function ($imovelId, Request $request) {
        $corretorId = $request->get('corretor_id', 1);
        
        $isFavorito = \App\Models\Favorito::where('corretor_id', $corretorId)
            ->where('empreendimento_id', $imovelId)
            ->exists();

        return response()->json([
            'success' => true,
            'isFavorito' => $isFavorito
        ]);
    });

    // Contar favoritos
    Route::get('/count', function (Request $request) {
        $corretorId = $request->get('corretor_id', 1);
        
        $total = \App\Models\Favorito::where('corretor_id', $corretorId)->count();

        return response()->json([
            'success' => true,
            'totalFavoritos' => $total
        ]);
    });
});

// ================================================
// ROTAS DE ACESSOS DE IMOBILIÁRIAS (/api/acessos-imobiliarias/*) - REQUER AUTH
// ================================================
Route::middleware('auth:sanctum')->prefix('acessos-imobiliarias')->group(function () {
    Route::get('/', [AcessoImobiliariaController::class, 'index']);
    Route::post('/', [AcessoImobiliariaController::class, 'store']);
    Route::get('/estatisticas', [AcessoImobiliariaController::class, 'estatisticas']);
});

// ================================================
// ROTAS DE BUSCA E FILTROS
// ================================================
Route::get('/cidades', function () {
    return response()->json([
        'success' => true,
        'data' => [
            'São Paulo',
            'Rio de Janeiro', 
            'Belo Horizonte',
            'Brasília',
            'Salvador',
            'Fortaleza',
            'Recife',
            'Porto Alegre',
            'Caxias do Sul'
        ]
    ]);
});

Route::post('/buscar', function (Request $request) {
    // Usar o ImovelController com filtros
    $imovelController = new ImovelController();
    return $imovelController->index($request);
});

// ================================================
// ROTAS DE CONSTRUTORAS (/api/construtoras/*)
// ================================================
Route::prefix('construtoras')->group(function () {
    Route::get('/', function () {
        return response()->json([
            'success' => true,
            'data' => [
                [
                    'id' => 1,
                    'nome' => 'Vale Incorp',
                    'logo' => 'https://via.placeholder.com/200x100',
                    'descricao' => 'Construtora especializada em empreendimentos residenciais de alto padrão',
                    'totalEmpreendimentos' => 25,
                    'empreendimentosAtivos' => 8,
                    'createdAt' => '2020-01-15T10:00:00Z'
                ]
            ]
        ]);
    });
    
    Route::get('/{id}', function ($id) {
        return response()->json([
            'success' => true,
            'data' => [
                'id' => 1,
                'nome' => 'Vale Incorp',
                'logo' => 'https://via.placeholder.com/200x100',
                'descricao' => 'Construtora especializada em empreendimentos residenciais de alto padrão',
                'totalEmpreendimentos' => 25,
                'empreendimentosAtivos' => 8,
                'endereco' => [
                    'logradouro' => 'Rua das Construtoras, 123',
                    'cidade' => 'São Paulo',
                    'estado' => 'SP',
                    'cep' => '01234-567'
                ],
                'contato' => [
                    'telefone' => '(11) 3333-4444',
                    'email' => 'contato@valeincorp.com.br',
                    'website' => 'https://valeincorp.com.br'
                ],
                'createdAt' => '2020-01-15T10:00:00Z'
            ]
        ]);
    });
    
    Route::get('/{id}/empreendimentos', function ($id, Request $request) {
        $page = $request->get('page', 1);
        $limit = min($request->get('limit', 10), 100);
        
        return response()->json([
            'success' => true,
            'data' => [],
            'pagination' => [
                'currentPage' => 1,
                'totalPages' => 1,
                'totalItems' => 0,
                'itemsPerPage' => 10
            ]
        ]);
    });
});

// ================================================
// ROTAS DE UPLOAD E MÍDIAS
// ================================================
Route::middleware('auth:sanctum')->group(function () {
    Route::post('/upload', [FileUploadController::class, 'upload']);
    
    Route::get('/media/{type}/{id}', function ($type, $id) {
        return response()->json([
            'success' => true,
            'data' => []
        ]);
    });
});

// ================================================
// ROTAS DE NOTIFICAÇÕES - REQUER AUTH
// ================================================
Route::middleware('auth:sanctum')->prefix('notifications')->group(function () {
    Route::get('/', function (Request $request) {
        return response()->json([
            'success' => true,
            'data' => [],
            'pagination' => [
                'currentPage' => 1,
                'totalPages' => 1,
                'totalItems' => 0,
                'itemsPerPage' => 10
            ],
            'totalUnread' => 0
        ]);
    });
    
    Route::put('/{id}/read', function ($id) {
        return response()->json([
            'success' => true,
            'message' => 'Notificação marcada como lida'
        ]);
    });
    
    Route::put('/read-all', function () {
        return response()->json([
            'success' => true,
            'message' => 'Todas as notificações foram marcadas como lidas'
        ]);
    });
});

// ================================================
// ROTAS DE SISTEMA
// ================================================
Route::get('/health', function () {
    return response()->json([
        'success' => true,
        'status' => 'ok',
        'timestamp' => now()->toISOString(),
        'version' => '1.0.0'
    ]);
});

Route::get('/config', function () {
    return response()->json([
        'success' => true,
        'data' => [
            'app' => [
                'name' => 'Vale Incorp',
                'version' => '1.0.0',
                'environment' => app()->environment()
            ],
            'features' => [
                'favoritos' => true,
                'notifications' => true,
                'stories' => true,
                'videos' => true
            ],
            'limits' => [
                'maxFavorites' => 100,
                'maxUploadSize' => 10485760,
                'itemsPerPage' => 20
            ]
        ]
    ]);
});