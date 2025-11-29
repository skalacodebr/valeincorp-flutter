<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;
use Illuminate\Validation\Rule;
use Illuminate\Support\Facades\Auth;
use App\Http\Controllers\API\EmpreendimentoUnidadeController;

// MODELS
use App\Models\EquipeUsuario;
use App\Models\EquipePermissao;
use App\Models\Permissao;
use App\Models\Cargo;

use App\Models\Cliente;
use App\Models\ClienteContato;
use App\Models\ClienteReferencia;
use App\Models\ClienteTributacao;
use App\Models\ClienteEndereco;
use App\Models\ClienteRepresentante;

use App\Models\Empreendimento;
use App\Models\EmpreendimentoTorre;
use App\Models\EmpreendimentoTorreExcessao;
use App\Models\EmpreendimentoAreaLazer;
use App\Models\EmpreendimentoEndereco;
use App\Models\EmpreendimentoImagemArquivo;
use App\Models\EvolucaoObra;

use App\Models\EmpreendimentoUnidade;
use App\Models\EmpreendimentoUnidadeVagaGaragem;
use App\Models\EmpreendimentoUnidadeFoto;
use App\Models\EmpreendimentoUnidadeVideo;

use App\Models\Negociacao;
use App\Models\NegociacaoStatus;

use App\Models\Pagamento;
use App\Models\PagamentoParcela;
use App\Models\HistoricoPagamento;

use App\Models\Lead;
use App\Models\OrigemLead;

use App\Models\Corretor;
use App\Models\Imobiliaria;
use App\Models\ImobiliariaEndereco;
use App\Models\ImobiliariaResponsavel;

use App\Http\Controllers\CorretorEquipeController;
use App\Http\Controllers\API\FileUploadController;
use App\Http\Controllers\API\UnidadeFotoController;
use App\Http\Controllers\API\UnidadeVideoController;
use App\Http\Controllers\API\CompartilhamentoController;
use App\Http\Controllers\ClickTrackingController;

// TODOS OS CORRETORES - Sempre retorna todos sem paginação - com busca
Route::get('/corretores-todos', function (Request $request) {
    $search = $request->query('search');

    $corretoresQuery = Corretor::select('id', 'nome', 'email', 'creci')
        ->with('imobiliaria:id,nome');

    $equipeQuery = EquipeUsuario::select('id', 'nome', 'email');

    // Aplicar busca se fornecida
    if ($search) {
        $corretoresQuery->where(function($q) use ($search) {
            $q->where('nome', 'ILIKE', "%{$search}%")
              ->orWhere('email', 'ILIKE', "%{$search}%")
              ->orWhere('creci', 'ILIKE', "%{$search}%")
              ->orWhereHas('imobiliaria', function($subQuery) use ($search) {
                  $subQuery->where('nome', 'ILIKE', "%{$search}%");
              });
        });

        $equipeQuery->where(function($q) use ($search) {
            $q->where('nome', 'ILIKE', "%{$search}%")
              ->orWhere('email', 'ILIKE', "%{$search}%");
        });
    }

    $corretores = $corretoresQuery->orderBy('nome')->get()
        ->map(function ($item) {
            return [
                'id' => $item->id,
                'nome' => $item->nome,
                'tipo' => 'corretor',
                'extra' => $item->imobiliaria ? " - {$item->imobiliaria->nome}" : '',
                'text' => $item->nome . ($item->imobiliaria ? " - {$item->imobiliaria->nome}" : ''),
            ];
        });

    $equipeUsuarios = $equipeQuery->orderBy('nome')->get()
        ->map(function ($item) {
            return [
                'id' => $item->id,
                'nome' => $item->nome,
                'tipo' => 'corretor interno',
                'extra' => ' - Corretor Interno',
                'text' => $item->nome . ' - Corretor Interno',
            ];
        });

    // Retorna array direto sem paginação
    return response()->json($corretores->merge($equipeUsuarios)->values());
});

// TODOS OS CLIENTES - para selects com busca
Route::get('/clientes-todos', function (Request $request) {
    $search = $request->query('search');

    $query = Cliente::select('id', 'profissao', 'estado_civil')
        ->with(['pessoa:clientes_id,nome,email,telefone,cpf_cnpj', 'status:id,nome']);

    if ($search) {
        $query->where(function($q) use ($search) {
            $q->whereHas('pessoa', function ($subQuery) use ($search) {
                $subQuery->where('nome', 'ILIKE', "%{$search}%")
                         ->orWhere('cpf_cnpj', 'ILIKE', "%{$search}%")
                         ->orWhere('email', 'ILIKE', "%{$search}%")
                         ->orWhere('telefone', 'ILIKE', "%{$search}%");
            })
            ->orWhere('profissao', 'ILIKE', "%{$search}%")
            ->orWhereHas('status', function($subQuery) use ($search) {
                $subQuery->where('nome', 'ILIKE', "%{$search}%");
            });
        });
    }

    $clientes = $query->orderBy('id', 'desc')->get()
        ->map(function ($item) {
            $nome = $item->pessoa ? $item->pessoa->nome : 'N/A';
            $cpf = $item->pessoa && $item->pessoa->cpf_cnpj ? " - {$item->pessoa->cpf_cnpj}" : '';

            return [
                'id' => $item->id,
                'nome' => $nome,
                'text' => $nome . $cpf,
                'cpf_cnpj' => $item->pessoa ? $item->pessoa->cpf_cnpj : null,
                'email' => $item->pessoa ? $item->pessoa->email : null,
            ];
        });

    return response()->json($clientes);
});

// TODAS AS IMOBILIÁRIAS - para selects com busca
Route::get('/imobiliarias-todos', function (Request $request) {
    $search = $request->query('search');

    $query = Imobiliaria::select('id', 'nome', 'cnpj', 'email', 'telefone');

    if ($search) {
        $query->where(function ($q) use ($search) {
            $q->where('nome', 'ILIKE', "%{$search}%")
              ->orWhere('email', 'ILIKE', "%{$search}%")
              ->orWhere('cnpj', 'ILIKE', "%{$search}%")
              ->orWhere('telefone', 'ILIKE', "%{$search}%");
        });
    }

    $imobiliarias = $query->orderBy('nome')->get()
        ->map(function ($item) {
            $cnpj = $item->cnpj ? " - {$item->cnpj}" : '';
            return [
                'id' => $item->id,
                'nome' => $item->nome,
                'text' => $item->nome . $cnpj,
                'cnpj' => $item->cnpj,
                'email' => $item->email,
                'telefone' => $item->telefone,
            ];
        });

    return response()->json($imobiliarias);
});

// TODOS OS EMPREENDIMENTOS - para selects com busca
Route::get('/empreendimentos-todos', function (Request $request) {
    $search = $request->query('search');

    $query = Empreendimento::select('id', 'nome', 'observacoes')
        ->with('endereco:empreendimentos_id,cidade,bairro');

    if ($search) {
        $query->where(function($q) use ($search) {
            $q->where('nome', 'ILIKE', "%{$search}%")
              ->orWhere('observacoes', 'ILIKE', "%{$search}%")
              ->orWhereHas('endereco', function($subQuery) use ($search) {
                  $subQuery->where('cidade', 'ILIKE', "%{$search}%")
                           ->orWhere('bairro', 'ILIKE', "%{$search}%");
              });
        });
    }

    $empreendimentos = $query->orderBy('nome')->get()
        ->map(function ($item) {
            $endereco = '';
            if ($item->endereco) {
                $endereco = " - {$item->endereco->bairro}, {$item->endereco->cidade}";
            }

            return [
                'id' => $item->id,
                'nome' => $item->nome,
                'text' => $item->nome . $endereco,
                'observacoes' => $item->observacoes,
                'cidade' => $item->endereco ? $item->endereco->cidade : null,
                'bairro' => $item->endereco ? $item->endereco->bairro : null,
            ];
        });

    return response()->json($empreendimentos);
});

// TODOS OS USUÁRIOS DA EQUIPE - para selects com busca
Route::get('/equipe-usuarios-todos', function (Request $request) {
    $search = $request->query('search');

    $query = EquipeUsuario::select('id', 'nome', 'email', 'telefone')
        ->with('cargo:id,nome');

    if ($search) {
        $query->where(function ($q) use ($search) {
            $q->where('nome', 'ILIKE', "%{$search}%")
              ->orWhere('email', 'ILIKE', "%{$search}%")
              ->orWhere('telefone', 'ILIKE', "%{$search}%")
              ->orWhereHas('cargo', function($subQuery) use ($search) {
                  $subQuery->where('nome', 'ILIKE', "%{$search}%");
              });
        });
    }

    $usuarios = $query->orderBy('nome')->get()
        ->map(function ($item) {
            $cargo = $item->cargo ? " - {$item->cargo->nome}" : '';

            return [
                'id' => $item->id,
                'nome' => $item->nome,
                'text' => $item->nome . $cargo,
                'email' => $item->email,
                'telefone' => $item->telefone,
                'cargo' => $item->cargo ? $item->cargo->nome : null,
            ];
        });

    return response()->json($usuarios);
});

// LOGIN
Route::post('/login', function (Request $request) {
    $request->validate([
        'email' => 'required|email',
        'senha' => 'required|string',
    ]);

    $usuario = EquipeUsuario::where('email', $request->email)->first();

    if (! $usuario || ! Hash::check($request->senha, $usuario->senha)) {
        throw ValidationException::withMessages([
            'email' => ['Credenciais inválidas.'],
        ]);
    }

    $token = $usuario->createToken('auth_token')->plainTextToken;

    return response()->json([
        'access_token' => $token,
        'token_type' => 'Bearer',
        'usuario' => $usuario->load(['cargo', 'permissoes']),
    ]);
});

Route::post('/leads/anuncio', function (Request $request) {
    
    $validated = $request->validate([
        'nome' => 'required|string|max:255',
        'telefone' => 'nullable|string|max:20',
        'email' => 'nullable|email|max:255',
        'profissao' => 'nullable|string|max:255',
        'status_leads' => 'nullable|integer',
        'origens_leads_id' => 'nullable|integer|exists:origens_leads,id',
        'observacoes' => 'nullable|string',
    ]);
    
    $validated['data_entrada'] = now()->format('Y-m-d');
    $lead = Lead::create($validated);

    return response()->json($lead->load('origem'), 201);
});

Route::get('/relatorio-leads', function (Request $request) {
    $origemId  = $request->query('origem_id');
    $statusId  = $request->query('status_id');
    $startDate = $request->query('start_date');
    $endDate   = $request->query('end_date');

    // Função auxiliar para aplicar os filtros
    $aplicarFiltros = function ($query) use ($origemId, $statusId, $startDate, $endDate) {
        if ($origemId) {
            $query->where('leads.origens_leads_id', $origemId);
        }
        if ($statusId) {
            $query->where('leads.status_leads', $statusId);
        }
        if ($startDate) {
            $query->whereDate('leads.data_entrada', '>=', $startDate);
        }
        if ($endDate) {
            $query->whereDate('leads.data_entrada', '<=', $endDate);
        }
    };

    // Agrega por data
    $porDatas = Lead::select('data_entrada', DB::raw('count(*) as total'))
        ->when(true, $aplicarFiltros)
        ->groupBy('data_entrada')
        ->orderBy('data_entrada')
        ->get();

    // Se o filtro de status for "perdidos" (ID 5), adicionar motivos
    if ($statusId == 5) {
        $porDatas = $porDatas->map(function ($item) use ($origemId, $startDate, $endDate) {
            // Buscar motivos dos leads perdidos para esta data
            $motivos = Lead::select('motivo')
                ->where('data_entrada', $item->data_entrada)
                ->where('status_leads', 5)
                ->when($origemId, function ($query) use ($origemId) {
                    return $query->where('origens_leads_id', $origemId);
                })
                ->when($startDate, function ($query) use ($startDate) {
                    return $query->whereDate('data_entrada', '>=', $startDate);
                })
                ->when($endDate, function ($query) use ($endDate) {
                    return $query->whereDate('data_entrada', '<=', $endDate);
                })
                ->whereNotNull('motivo')
                ->where('motivo', '!=', '')
                ->pluck('motivo')
                ->unique()
                ->values()
                ->toArray();
            
            $item->motivos = $motivos;
            return $item;
        });
    }

    // Agrega por origem
    $porOrigens = Lead::from('leads')
        ->leftJoin('origens_leads as o', 'o.id', '=', 'leads.origens_leads_id')
        ->select(
            'leads.origens_leads_id as id',
            DB::raw('COALESCE(o.nome, "Sem origem") as nome'),
            DB::raw('COUNT(*) as total')
        )
        ->when(true, $aplicarFiltros)
        ->groupBy('leads.origens_leads_id', 'o.nome')
        ->orderBy('total', 'desc')
        ->get();

    // Agrega por status
    $porStatus = Lead::from('leads')
        ->leftJoin('status_leads as s', 's.id', '=', 'leads.status_leads')
        ->select(
            'leads.status_leads as id',
            DB::raw('COALESCE(s.nome, "Sem status") as nome'),
            DB::raw('COUNT(*) as total')
        )
        ->when(true, $aplicarFiltros)
        ->groupBy('leads.status_leads', 's.nome')
        ->orderBy('total', 'desc')
        ->get();

    return response()->json([
        'por_datas'   => $porDatas,
        'por_origens' => $porOrigens,
        'por_status'  => $porStatus,
    ]);
});

// PERMISSÕES DA EQUIPE
Route::get('/equipe-permissoes', function (Request $request) {
    $query = EquipePermissao::query();

    if ($request->has('equipe_usuarios_id')) {
        $query->where('equipe_usuarios_id', $request->equipe_usuarios_id);
    }

    if ($request->has('permissoes_id')) {
        $query->where('permissoes_id', $request->permissoes_id);
    }

    return response()->json($query->paginate(10));
});

Route::post('/equipe-permissoes', function (Request $request) {
    $request->validate([
        'equipe_usuarios_id' => 'required|integer|exists:equipe_usuarios,id',
        'permissoes_id' => 'required|integer|exists:permissoes,id',
    ]);

    try {
        // Verifica se já existe
        $existe = EquipePermissao::where('equipe_usuarios_id', $request->equipe_usuarios_id)
            ->where('permissoes_id', $request->permissoes_id)
            ->exists();

        if ($existe) {
            return response()->json([
                'message' => 'Permissão já existe para este usuário.'
            ], 409);
        }

        $permissao = EquipePermissao::create([
            'equipe_usuarios_id' => $request->equipe_usuarios_id,
            'permissoes_id' => $request->permissoes_id,
        ]);

        return response()->json([
            'message' => 'Permissão adicionada com sucesso.',
            'data' => $permissao
        ], 201);

    } catch (\Exception $e) {
        return response()->json([
            'error' => 'Erro ao adicionar permissão',
            'message' => $e->getMessage()
        ], 500);
    }
});

Route::delete('/equipe-permissoes', function (Request $request) {
    $request->validate([
        'equipe_usuarios_id' => 'required|integer',
        'permissoes_id' => 'required|integer',
    ]);

    $deleted = EquipePermissao::where('equipe_usuarios_id', $request->equipe_usuarios_id)
        ->where('permissoes_id', $request->permissoes_id)
        ->delete();

    if ($deleted) {
        return response()->json(['message' => 'Registro deletado com sucesso.']);
    }

    return response()->json(['message' => 'Registro não encontrado.'], 404);
});

// CORRETORES
Route::prefix('corretores')->group(function () {
    Route::get('/', function(Request $request) {
        $query = Corretor::with('imobiliaria');
        $paginate = $request->boolean('paginate') || $request->boolean('use_pagination');
        $search = $request->query('search');

        // Filtro por status ativo/inativo
        if ($request->has('ativo')) {
            $ativo = $request->boolean('ativo');
            $query->where('ativo', $ativo);
        }

        // Funcionalidade de busca
        if ($search) {
            $query->where(function($q) use ($search) {
                $q->where('nome', 'ILIKE', "%{$search}%")
                  ->orWhere('email', 'ILIKE', "%{$search}%")
                  ->orWhere('cpf', 'ILIKE', "%{$search}%")
                  ->orWhere('creci', 'ILIKE', "%{$search}%")
                  ->orWhereHas('imobiliaria', function($subQuery) use ($search) {
                      $subQuery->where('nome', 'ILIKE', "%{$search}%");
                  });
            });
        }

        // Por padrão retorna todos sem paginação, a menos que explicitamente solicitado
        if ($paginate) {
            $perPage = $request->get('per_page', 15);
            return $query->orderBy('nome')->paginate($perPage);
        }

        return $query->orderBy('nome')->get();
    });

    Route::post('/', function(Request $request) {
        $data = $request->validate([
            'imobiliarias_id' => 'nullable|exists:imobiliarias,id',
            'nome'            => 'required|string|max:255',
            'cpf'             => 'nullable|string|max:18',
            'email'           => 'nullable|email|max:255',
            'telefone'        => 'nullable|string|max:20',
            'senha'           => 'required|string|min:6',
            'creci'           => 'nullable|string|max:255',
            'ativo'           => 'required|boolean',
            'mostrar_venda'   => 'sometimes|integer',
            'mostrar_espelho' => 'sometimes|integer',
        ]);

        $data['senha'] = bcrypt($data['senha']);
        return Corretor::create($data);
    });

    Route::get('/{corretor}', fn(Corretor $corretor) => $corretor->load('imobiliaria'));

    Route::put('/{corretor}', function(Request $request, Corretor $corretor) {
        $data = $request->validate([
            'imobiliarias_id' => 'nullable|exists:imobiliarias,id',
            'nome'            => 'sometimes|required|string|max:255',
            'cpf'             => 'nullable|string|max:18',
            'email'           => 'nullable|email|max:255',
            'telefone'        => 'nullable|string|max:20',
            'senha'           => 'nullable|string|min:6',
            'creci'           => 'nullable|string|max:255',
            'ativo'           => 'sometimes|boolean',
            'mostrar_venda'   => 'sometimes|integer',
            'mostrar_espelho' => 'sometimes|integer',
        ]);

        if (isset($data['senha']) && !empty($data['senha'])) {
            $data['senha'] = bcrypt($data['senha']);
        } else {
            unset($data['senha']); // Remove senha do update se estiver vazia
        }

        $corretor->update($data);
        return $corretor->load('imobiliaria');
    });

    Route::delete('/{corretor}', fn(Corretor $corretor) =>
        tap($corretor)->delete() && response()->json(['message' => 'Corretor excluído com sucesso'])
    );
});

// IMOBILIÁRIAS
Route::prefix('imobiliarias')->group(function () {
    Route::get('/', function (Request $request) {
        $search = $request->query('search');
        $paginate = $request->boolean('paginate') || $request->boolean('use_pagination');
        $perPage = $request->query('per_page', 15);

        $query = Imobiliaria::query();

        // Funcionalidade de busca expandida
        if ($search) {
            $query->where(function ($q) use ($search) {
                $q->where('nome', 'ILIKE', "%{$search}%")
                  ->orWhere('email', 'ILIKE', "%{$search}%")
                  ->orWhere('cnpj', 'ILIKE', "%{$search}%")
                  ->orWhere('telefone', 'ILIKE', "%{$search}%")
                  ->orWhere('creci', 'ILIKE', "%{$search}%");
            });
        }

        // Por padrão retorna todos sem paginação, a menos que explicitamente solicitado
        if ($paginate) {
            return $query->orderBy('nome')->paginate($perPage);
        }

        return $query->orderBy('nome')->get();
    });
    Route::post('/', fn(Request $request) => Imobiliaria::create(
        $request->validate([
            'nome'     => 'required|string|max:255',
            'cnpj'     => 'nullable|string|max:20',
            'email'    => 'nullable|email|max:255',
            'telefone' => 'nullable|string|max:20',
            'creci'    => 'nullable|string|max:255',
        ])
    ));
    Route::get('/{imobiliaria}', fn(Imobiliaria $imobiliaria) => $imobiliaria);
    Route::put('/{imobiliaria}', fn(Request $request, Imobiliaria $imobiliaria) =>
        tap($imobiliaria)->update($request->validate([
            'nome'     => 'sometimes|required|string|max:255',
            'cnpj'     => 'nullable|string|max:20',
            'email'    => 'nullable|email|max:255',
            'telefone' => 'nullable|string|max:20',
            'creci'    => 'nullable|string|max:255',
        ]))
    );
    Route::delete('/{imobiliaria}', fn(Imobiliaria $imobiliaria) =>
        tap($imobiliaria)->delete() && response()->json(['message' => 'Imobiliária excluída com sucesso'])
    );
});

// NEGOCIACOES
// LISTAR
Route::get('/negociacoes', function (Request $request) {
    try {
        $perPage = $request->query('per_page', 10000);
        $search = $request->query('search');
        $startDate = $request->query('start_date');
        $endDate = $request->query('end_date');

        // Validar datas se fornecidas
        if ($startDate && !preg_match('/^\d{4}-\d{2}-\d{2}$/', $startDate)) {
            return response()->json(['message' => 'Formato de start_date inválido. Use YYYY-MM-DD'], 422);
        }
        if ($endDate && !preg_match('/^\d{4}-\d{2}-\d{2}$/', $endDate)) {
            return response()->json(['message' => 'Formato de end_date inválido. Use YYYY-MM-DD'], 422);
        }
        if ($startDate && $endDate && $startDate > $endDate) {
            return response()->json(['message' => 'start_date deve ser menor ou igual a end_date'], 422);
        }

        \Log::info("=== LISTANDO NEGOCIAÇÕES ===");
        \Log::info("Per page:", ['per_page' => $perPage]);
        \Log::info("Search:", ['search' => $search]);
        \Log::info("Period:", ['start_date' => $startDate, 'end_date' => $endDate]);

        $query = Negociacao::with(['empreendimento', 'unidade', 'cliente.pessoa', 'corretor', 'equipeUsuario', 'status']);

        // Filtro de período (priorizar created_at, fallback para data)
        if ($startDate) {
            $query->where(function($q) use ($startDate) {
                $q->where('created_at', '>=', $startDate . ' 00:00:00')
                  ->orWhere(function($subQ) use ($startDate) {
                      $subQ->whereNull('created_at')
                           ->where('data', '>=', $startDate . ' 00:00:00');
                  });
            });
        }
        if ($endDate) {
            $query->where(function($q) use ($endDate) {
                $q->where('created_at', '<=', $endDate . ' 23:59:59')
                  ->orWhere(function($subQ) use ($endDate) {
                      $subQ->whereNull('created_at')
                           ->where('data', '<=', $endDate . ' 23:59:59');
                  });
            });
        }

        if ($search) {
            $query->where(function($q) use ($search) {
                $q->where('numero_contrato', 'ILIKE', "%{$search}%")
                  ->orWhereHas('cliente.pessoa', function($subQuery) use ($search) {
                      $subQuery->where('nome', 'ILIKE', "%{$search}%");
                  })
                  ->orWhereHas('empreendimento', function($subQuery) use ($search) {
                      $subQuery->where('nome', 'ILIKE', "%{$search}%");
                  });
            });
        }

        $result = $query->orderBy('id', 'desc')->paginate($perPage);
        \Log::info("Negociações encontradas:", ['count' => $result->total()]);

        return response()->json($result);
    } catch (\Exception $e) {
        \Log::error("Erro ao listar negociações:", [
            'error' => $e->getMessage(),
            'trace' => $e->getTraceAsString()
        ]);

        return response()->json([
            'error' => 'Erro ao listar negociações',
            'message' => $e->getMessage()
        ], 500);
    }
});
// Detalhe
Route::get('/negociacoes/{id}', function ($id) {
    try {
        \Log::info("=== BUSCANDO NEGOCIAÇÃO POR ID ===");
        \Log::info("ID solicitado:", ['id' => $id]);
        
        $negociacao = Negociacao::with(['empreendimento', 'unidade', 'cliente.pessoa', 'corretor', 'equipeUsuario', 'status'])
            ->findOrFail($id);
            
        \Log::info("Negociação encontrada com relacionamentos:", $negociacao->toArray());
        
        return response()->json($negociacao);
    } catch (\Exception $e) {
        \Log::error("Erro ao buscar negociação:", [
            'id' => $id,
            'error' => $e->getMessage(),
            'trace' => $e->getTraceAsString()
        ]);
        
        return response()->json([
            'error' => 'Negociação não encontrada',
            'message' => $e->getMessage()
        ], 404);
    }
});

// ROTA PÚBLICA - Visualizar detalhes de uma unidade compartilhada
Route::get('/unidades/{id}', [\App\Http\Controllers\API\EmpreendimentoUnidadeController::class, 'show']);

// TODAS AS DEMAIS ROTAS PROTEGIDAS
Route::middleware('auth:sanctum')->group(function () {

    // LOGOUT
    Route::post('/logout', function (Request $request) {
        $request->user()->currentAccessToken()->delete();
        return response()->json(['message' => 'Logout realizado com sucesso']);
    });

    // ================================================
    // TIPOS DE MEDIDA DE UNIDADES (CONFIGURAÇÕES)
    // ================================================
    Route::prefix('tipos-medida-unidades')->group(function () {
        Route::get('/', [\App\Http\Controllers\TipoMedidaUnidadeController::class, 'index']);
        Route::get('/ativos', [\App\Http\Controllers\TipoMedidaUnidadeController::class, 'ativos']);
        Route::post('/', [\App\Http\Controllers\TipoMedidaUnidadeController::class, 'store']);
        Route::put('/{id}', [\App\Http\Controllers\TipoMedidaUnidadeController::class, 'update']);
        Route::delete('/{id}', [\App\Http\Controllers\TipoMedidaUnidadeController::class, 'destroy']);
    });

    // ================================================
    // MEDIDAS DE UNIDADES
    // ================================================
    Route::prefix('medidas-unidades')->group(function () {
        Route::post('/', [\App\Http\Controllers\MedidaUnidadeController::class, 'store']);
        Route::get('/{unidade_id}', [\App\Http\Controllers\MedidaUnidadeController::class, 'show']);
        Route::delete('/{unidade_id}', [\App\Http\Controllers\MedidaUnidadeController::class, 'destroy']);
    });

    // Rota de teste para debug
    Route::get('/debug-medidas/{unidade_id}', function ($unidade_id) {
        $unidade = \App\Models\EmpreendimentoUnidade::with(['medidas.tipoMedida'])->find($unidade_id);
        
        if (!$unidade) {
            return response()->json(['error' => 'Unidade não encontrada'], 404);
        }
        
        return response()->json([
            'unidade_id' => $unidade->id,
            'medidas_raw' => $unidade->medidas->toArray(),
            'tipos_medida' => \App\Models\TipoMedidaUnidade::all()->toArray()
        ]);
    });

    // Rota simples para verificar tipos de medida
    Route::get('/debug-tipos-medida', function () {
        return response()->json([
            'tipos_medida' => \App\Models\TipoMedidaUnidade::all()->toArray(),
            'count' => \App\Models\TipoMedidaUnidade::count()
        ]);
    });


    // USUÁRIO AUTENTICADO
    Route::get('/me', function (Request $request) {
        return $request->user()->load(['cargo', 'permissoes']);
    });

    /////////////////////////////////
    // EQUIPE USUÁRIOS PERFIL CRUD //
    ////////////////////////////////
    Route::put('/me/update', function (Request $request) {
        $usuario = $request->user();

        $validated = $request->validate([
            'nome' => 'required|string|max:255',
            'email' => [
                'required',
                'email',
                Rule::unique('equipe_usuarios')->ignore($usuario->id),
            ],
            'telefone' => 'nullable|string|max:20',
            'senha' => 'nullable|string|min:6|confirmed',
        ]);

        $usuario->nome = $validated['nome'];
        $usuario->email = $validated['email'];
        $usuario->telefone = $validated['telefone'] ?? null;

        // Atualiza a senha se for fornecida
        if (!empty($validated['senha'])) {
            $usuario->senha = Hash::make($validated['senha']);
        }

        $usuario->save();

        return response()->json([
            'message' => 'Perfil atualizado com sucesso',
            'usuario' => $usuario->fresh(['cargo', 'permissoes']),
        ]);
    });

    //////////////////////////
    // EQUIPE USUÁRIOS CRUD //
    //////////////////////////
    Route::get('/equipe-usuarios', function (Request $request) {
        $search = $request->query('search');
        $paginate = $request->boolean('paginate') || $request->boolean('use_pagination');
        $perPage = $request->query('per_page', 15);

        $query = EquipeUsuario::with(['cargo', 'permissoes']);

        // Funcionalidade de busca expandida
        if ($search) {
            $query->where(function ($q) use ($search) {
                $q->where('nome', 'ILIKE', "%{$search}%")
                  ->orWhere('email', 'ILIKE', "%{$search}%")
                  ->orWhere('telefone', 'ILIKE', "%{$search}%")
                  ->orWhereHas('cargo', function($subQuery) use ($search) {
                      $subQuery->where('nome', 'ILIKE', "%{$search}%");
                  });
            });
        }

        // Por padrão retorna todos sem paginação, a menos que explicitamente solicitado
        if ($paginate) {
            return $query->orderBy('nome')->paginate($perPage);
        }

        return $query->orderBy('nome')->get();
    });
    
    Route::get('/unidade-boxes', function (Request $request) {
        $validated = $request->validate([
            'torre_id'   => 'required|integer|exists:empreendimentos_tores,id',
            'unidade_id' => 'nullable|integer|exists:empreendimentos_unidades,id',
        ]);

        $torreId = $validated['torre_id'];
        $unidadeId = $validated['unidade_id'] ?? null;

        $query = EmpreendimentoUnidadeVagaGaragem::where('empreendimentos_tores_id', $torreId)
            ->select('id', 'numero_vaga', 'status', 'cobertura', 'tipo_vaga', 'area_total', 'pavimento', 'unidade_id')
            ->orderBy('numero_vaga');

        if ($unidadeId) {
            $query->where(function ($q) use ($unidadeId) {
                $q->where(function ($inner) {
                    $inner->whereNull('unidade_id')
                          ->where('status', 'Disponível');
                })->orWhere('unidade_id', $unidadeId);
            });
        } else {
            $query->whereNull('unidade_id')
                  ->where('status', 'Disponível');
        }

        return response()->json($query->get());
    });



    // OBTER MEMBRO ESPECÍFICO DA EQUIPE
    Route::get('/equipe-usuarios/{id}', function ($id) {
        try {
            $usuario = EquipeUsuario::with(['cargo', 'permissoes'])->findOrFail($id);
            return response()->json($usuario);
        } catch (\Exception $e) {
            return response()->json(['error' => 'Membro da equipe não encontrado'], 404);
        }
    });

Route::get('/equipe-usuarios/{id}/permissoes', function ($id) {
    try {
        \Log::info("Iniciando busca de permissões para o usuário ID: {$id}");
        
        // Verificar se o ID é válido
        if (!is_numeric($id)) {
            \Log::error("ID de usuário inválido: {$id}");
            return response()->json(['error' => 'ID de usuário inválido'], 400);
        }
        
        // Tenta encontrar o usuário
        $usuario = EquipeUsuario::with(['cargo', 'permissoes'])->find($id);
        
        if (!$usuario) {
            \Log::warning("Usuário não encontrado com ID: {$id}");
            return response()->json(['error' => 'Usuário não encontrado'], 404);
        }
        
        \Log::info("Usuário encontrado: " . $usuario->id . " com " . count($usuario->permissoes) . " permissões");
        
        return response()->json($usuario);
    } catch (\Exception $e) {
        \Log::error("Erro ao buscar permissões do usuário {$id}: " . $e->getMessage());
        \Log::error("Stack trace: " . $e->getTraceAsString());
        
        return response()->json([
            'error' => 'Erro interno do servidor', 
            'message' => $e->getMessage()
        ], 500);
    }
});

    Route::post('/equipe-usuarios', function (Request $request) {
        try {
            $validated = $request->validate([
                'nome' => 'required|string|max:255',
                'telefone' => 'nullable|string|max:20',
                'email' => 'required|email|unique:equipe_usuarios,email',
                'senha' => 'required|string|min:6|confirmed',
                'data_entrada' => 'nullable|date',
                'cargos_id' => 'nullable|exists:cargos,id',
                'status' => 'boolean',
                'permissoes' => 'array',
                'permissoes.*' => 'exists:permissoes,id',
            ]);

            $usuario = EquipeUsuario::create([
                'nome' => $validated['nome'],
                'telefone' => $validated['telefone'] ?? null,
                'email' => $validated['email'],
                'senha' => Hash::make($validated['senha']),
                'data_entrada' => $validated['data_entrada'] ?? null,
                'cargos_id' => $validated['cargos_id'] ?? null,
                'status' => $validated['status'] ?? true,
            ]);

            if (!empty($validated['permissoes'])) {
                $usuario->permissoes()->sync($validated['permissoes']);
            }

            return response()->json($usuario->load(['cargo', 'permissoes']), 201);

        } catch (\Exception $e) {
            return response()->json([
                'error' => 'Erro ao criar usuário',
                'message' => $e->getMessage()
            ], 500);
        }
    });

    Route::put('/equipe-usuarios/{id}', function (Request $request, $id) {
        try {
            $usuario = EquipeUsuario::findOrFail($id);

            $validated = $request->validate([
                'nome' => 'required|string|max:255',
                'telefone' => 'nullable|string|max:20',
                'email' => [
                    'required',
                    'email',
                    Rule::unique('equipe_usuarios')->ignore($usuario->id),
                ],
                'senha' => 'nullable|string|min:6|confirmed',
                'data_entrada' => 'nullable|date',
                'cargos_id' => 'nullable|exists:cargos,id',
                'status' => 'boolean',
                'permissoes' => 'array',
                'permissoes.*' => 'exists:permissoes,id',
            ]);

            $usuario->update([
                'nome' => $validated['nome'],
                'telefone' => $validated['telefone'] ?? null,
                'email' => $validated['email'],
                'senha' => !empty($validated['senha']) ? Hash::make($validated['senha']) : $usuario->senha,
                'data_entrada' => $validated['data_entrada'] ?? null,
                'cargos_id' => $validated['cargos_id'] ?? null,
                'status' => $validated['status'] ?? $usuario->status,
            ]);

            if (isset($validated['permissoes'])) {
                $usuario->permissoes()->sync($validated['permissoes']);
            }

            return response()->json($usuario->load(['cargo', 'permissoes']));
        } catch (\Exception $e) {
            return response()->json([
                'error' => 'Erro ao atualizar usuário',
                'message' => $e->getMessage()
            ], 500);
        }
    });

    Route::delete('/equipe-usuarios/{id}', function ($id) {
        try {
            $usuario = EquipeUsuario::findOrFail($id);
            $usuario->delete();
            return response()->json(['message' => 'Usuário removido com sucesso.']);
        } catch (\Exception $e) {
            return response()->json([
                'error' => 'Erro ao excluir usuário',
                'message' => $e->getMessage()
            ], 500);
        }
    });

    ////////////////////////////
    // TABELAS AUXILIARES
    ////////////////////////////
    Route::get('/cargos', function () {
        return response()->json(Cargo::orderBy('nome')->get());
    });

    Route::get('/permissoes', function () {
        return response()->json(Permissao::orderBy('nome')->get());
    });

    ////////////////////
    // CLIENTES CRUD //
    ////////////////////
    Route::get('/clientes', function (Request $request) {
        $search = $request->query('search');
        $paginate = $request->boolean('paginate') || $request->boolean('use_pagination');
        $perPage = $request->query('per_page', 15);
        $startDate = $request->query('start_date');
        $endDate = $request->query('end_date');

        // Validar datas se fornecidas
        if ($startDate && !preg_match('/^\d{4}-\d{2}-\d{2}$/', $startDate)) {
            return response()->json(['message' => 'Formato de start_date inválido. Use YYYY-MM-DD'], 422);
        }
        if ($endDate && !preg_match('/^\d{4}-\d{2}-\d{2}$/', $endDate)) {
            return response()->json(['message' => 'Formato de end_date inválido. Use YYYY-MM-DD'], 422);
        }
        if ($startDate && $endDate && $startDate > $endDate) {
            return response()->json(['message' => 'start_date deve ser menor ou igual a end_date'], 422);
        }

        $query = Cliente::with(['pessoa', 'endereco', 'foto', 'status', 'equipe']);

        // Filtro de período
        if ($startDate) {
            $query->where('created_at', '>=', $startDate . ' 00:00:00');
        }
        if ($endDate) {
            $query->where('created_at', '<=', $endDate . ' 23:59:59');
        }

        // Funcionalidade de busca expandida
        if ($search) {
            $query->where(function($q) use ($search) {
                $q->whereHas('pessoa', function ($subQuery) use ($search) {
                    $subQuery->where('nome', 'ILIKE', "%{$search}%")
                             ->orWhere('cpf_cnpj', 'ILIKE', "%{$search}%")
                             ->orWhere('email', 'ILIKE', "%{$search}%")
                             ->orWhere('telefone', 'ILIKE', "%{$search}%");
                })
                ->orWhere('profissao', 'ILIKE', "%{$search}%")
                ->orWhere('estado_civil', 'ILIKE', "%{$search}%")
                ->orWhereHas('status', function($subQuery) use ($search) {
                    $subQuery->where('nome', 'ILIKE', "%{$search}%");
                })
                ->orWhereHas('equipe', function($subQuery) use ($search) {
                    $subQuery->where('nome', 'ILIKE', "%{$search}%");
                });
            });
        }

        // Por padrão retorna todos sem paginação, a menos que explicitamente solicitado
        if ($paginate) {
            return $query->orderBy('id', 'desc')->paginate($perPage);
        }

        return $query->orderBy('id', 'desc')->get();
    });

    Route::get('/clientes/{id}', function ($id) {
        return Cliente::with(['pessoa', 'endereco', 'foto', 'status', 'equipe'])->findOrFail($id);
    });

    Route::post('/clientes', function (Request $request) {
        $validated = $request->validate([
            'observacoes' => 'nullable|string',
            'status_clientes_id' => 'nullable|integer',
            'equipe_usuarios_id' => 'nullable|integer',
            'imobiliarias_id' => 'nullable|integer',
            'corretores_id' => 'nullable|integer',
            'profissao' => 'nullable|string|max:255',
            'estado_civil' => 'nullable|string|max:20|in:Solteiro(a),Casado(a),Divorciado(a),Viúvo(a),União Estável,Separado(a)',

            'pessoa.nome' => 'required|string|max:255',
            'pessoa.cpf_cnpj' => 'nullable|string|max:20',
            'pessoa.email' => 'nullable|email|max:255',
            'pessoa.telefone' => 'nullable|string|max:20',
            'pessoa.documento_rg_base64' => 'nullable|string',
            'pessoa.documento_cpf_base64' => 'nullable|string',
            'pessoa.comprovante_endereco_base64' => 'nullable|string',
            'pessoa.carteira_trabalho_base64' => 'nullable|string',
            'pessoa.pis_base64' => 'nullable|string',
            'pessoa.comprovante_renda_base64' => 'nullable|string',
            'pessoa.declaracao_ir_base64' => 'nullable|string',
            'pessoa.extrato_fgts_base64' => 'nullable|string',
            'pessoa.certidao_casamento_base64' => 'nullable|string',

            'endereco.cep' => 'nullable|string|max:9',
            'endereco.estado' => 'nullable|string|max:2',
            'endereco.cidade' => 'nullable|string|max:100',
            'endereco.bairro' => 'nullable|string|max:100',
            'endereco.rua' => 'nullable|string|max:255',
            'endereco.numero' => 'nullable|string|max:20',
            'endereco.complemento' => 'nullable|string|max:255',

            'foto.foto_url' => 'nullable|string',
        ]);

        $cliente = Cliente::create($validated);

        if (isset($validated['pessoa'])) {
            $cliente->pessoa()->create($validated['pessoa']);
        }

        if (isset($validated['endereco'])) {
            $cliente->endereco()->create($validated['endereco']);
        }

        if (isset($validated['foto'])) {
            $cliente->foto()->create($validated['foto']);
        }

        return response()->json($cliente->load(['pessoa', 'endereco', 'foto', 'status', 'equipe']), 201);
    });

    Route::put('/clientes/{id}', function (Request $request, $id) {
        $cliente = Cliente::with(['pessoa', 'endereco', 'foto'])->findOrFail($id);

        $validated = $request->validate([
            'observacoes' => 'nullable|string',
            'status_clientes_id' => 'nullable|integer',
            'equipe_usuarios_id' => 'nullable|integer',
            'imobiliarias_id' => 'nullable|integer',
            'corretores_id' => 'nullable|integer',
            'profissao' => 'nullable|string|max:255',
            'estado_civil' => 'nullable|string|max:20|in:Solteiro(a),Casado(a),Divorciado(a),Viúvo(a),União Estável,Separado(a)',

            // Pessoa
            'pessoa.nome' => 'required|string|max:255',
            'pessoa.cpf_cnpj' => 'nullable|string|max:20',
            'pessoa.email' => 'nullable|email|max:255',
            'pessoa.telefone' => 'nullable|string|max:20',
            'pessoa.documento_rg_base64' => 'nullable|string',
            'pessoa.documento_cpf_base64' => 'nullable|string',
            'pessoa.comprovante_endereco_base64' => 'nullable|string',
            'pessoa.carteira_trabalho_base64' => 'nullable|string',
            'pessoa.pis_base64' => 'nullable|string',
            'pessoa.comprovante_renda_base64' => 'nullable|string',
            'pessoa.declaracao_ir_base64' => 'nullable|string',
            'pessoa.extrato_fgts_base64' => 'nullable|string',
            'pessoa.certidao_casamento_base64' => 'nullable|string',

            // Endereço
            'endereco.cep' => 'nullable|string|max:9',
            'endereco.estado' => 'nullable|string|max:2',
            'endereco.cidade' => 'nullable|string|max:100',
            'endereco.bairro' => 'nullable|string|max:100',
            'endereco.rua' => 'nullable|string|max:255',
            'endereco.numero' => 'nullable|string|max:20',
            'endereco.complemento' => 'nullable|string|max:255',

            // Foto
            'foto.foto_url' => 'nullable|string',
        ]);

        // Separar os dados aninhados
        $pessoaData = $validated['pessoa'] ?? [];
        $enderecoData = $validated['endereco'] ?? [];
        $fotoData = $validated['foto'] ?? [];

        // Remover dados aninhados do array principal antes de atualizar o cliente
        unset($validated['pessoa'], $validated['endereco'], $validated['foto']);

        // Atualiza dados do cliente
        $cliente->update($validated);

        // Atualiza os relacionamentos
        if (!empty($pessoaData)) {
            $cliente->pessoa()->updateOrCreate([], $pessoaData);
        }

        if (!empty($enderecoData)) {
            $cliente->endereco()->updateOrCreate([], $enderecoData);
        }

        if (!empty($fotoData)) {
            $cliente->foto()->updateOrCreate([], $fotoData);
        }

        return response()->json(
            $cliente->load(['pessoa', 'endereco', 'foto', 'status', 'equipe'])
        );
    });

    Route::delete('/clientes/{id}', function ($id) {
        $cliente = Cliente::with(['pessoa', 'endereco', 'foto'])->findOrFail($id);

        $cliente->foto()->delete();
        $cliente->endereco()->delete();
        $cliente->pessoa()->delete();
        $cliente->delete();

        return response()->json(['message' => 'Cliente excluído com sucesso.']);
    });

    /////////////////////////
    // EMPREENDIMETNO CRUD //
    /////////////////////////
    // EVOLUÇÃO DA OBRA (colocar antes das rotas com {id} genérico)
    Route::get('/empreendimentos/evolucao-obra', function (Request $request) {
        $perPage = $request->get('per_page', 10);
        $query = EvolucaoObra::with('empreendimento:id,nome')
            ->orderBy('data_criacao', 'desc');

        if ($request->has('empreendimento_id')) {
            $query->where('empreendimento_id', $request->empreendimento_id);
        }

        return $query->paginate($perPage);
    });

    Route::get('/empreendimentos/evolucao-obra/{id}', function ($id) {
        $evolucao = EvolucaoObra::with([
            'empreendimento' => function ($query) {
                $query->select('id', 'nome')
                    ->with('endereco');
            }
        ])->findOrFail($id);

        return response()->json($evolucao);
    });

    Route::post('/empreendimentos/evolucao-obra', function (Request $request) {
        $validated = $request->validate([
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

        if (!empty($validated['errors'])) {
            return response()->json([
                'message' => 'Os dados fornecidos são inválidos.',
                'errors' => $validated['errors']
            ], 422);
        }

        $data = $validated;
        $data['created_by'] = Auth::id() ?? 1; // Fallback para usuário ID 1 se não autenticado
        $data['updated_by'] = Auth::id() ?? 1;

        $evolucao = EvolucaoObra::create($data);

        return response()->json($evolucao->fresh(), 201);
    });

    Route::put('/empreendimentos/evolucao-obra/{id}', function (Request $request, $id) {
        $evolucao = EvolucaoObra::findOrFail($id);

        $validated = $request->validate([
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

        if (!empty($validated['errors'])) {
            return response()->json([
                'message' => 'Os dados fornecidos são inválidos.',
                'errors' => $validated['errors']
            ], 422);
        }

        $data = collect($validated)->only(['nome', 'data_criacao', 'descricao', 'percentual_conclusao'])->toArray();
        $data['updated_by'] = Auth::id() ?? 1; // Fallback para usuário ID 1 se não autenticado

        $evolucao->update($data);

        return response()->json($evolucao->fresh());
    });

    Route::delete('/empreendimentos/evolucao-obra/{id}', function ($id) {
        $evolucao = EvolucaoObra::findOrFail($id);
        $evolucao->delete();

        return response()->json(null, 204);
    });

    Route::get('/empreendimentos/{empreendimento_id}/evolucao-obra', function ($empreendimentoId) {
        $empreendimento = Empreendimento::findOrFail($empreendimentoId);
        
        $evolucoes = EvolucaoObra::where('empreendimento_id', $empreendimentoId)
            ->orderBy('data_criacao', 'desc')
            ->get();

        return response()->json([
            'data' => $evolucoes
        ]);
    });

    Route::get('/empreendimentos', function (Request $request) {
        $search = $request->query('search');
        $paginate = $request->boolean('paginate') || $request->boolean('use_pagination');
        $perPage = $request->query('per_page', 15);
        $startDate = $request->query('start_date');
        $endDate = $request->query('end_date');

        // Validar datas se fornecidas
        if ($startDate && !preg_match('/^\d{4}-\d{2}-\d{2}$/', $startDate)) {
            return response()->json(['message' => 'Formato de start_date inválido. Use YYYY-MM-DD'], 422);
        }
        if ($endDate && !preg_match('/^\d{4}-\d{2}-\d{2}$/', $endDate)) {
            return response()->json(['message' => 'Formato de end_date inválido. Use YYYY-MM-DD'], 422);
        }
        if ($startDate && $endDate && $startDate > $endDate) {
            return response()->json(['message' => 'start_date deve ser menor ou igual a end_date'], 422);
        }

        $query = Empreendimento::with(['torres.excessoes', 'areasLazer', 'endereco', 'imagensArquivos', 'videosUnidades', 'documentos.tipoDocumento']);

        // Filtro de período
        if ($startDate) {
            $query->where('created_at', '>=', $startDate . ' 00:00:00');
        }
        if ($endDate) {
            $query->where('created_at', '<=', $endDate . ' 23:59:59');
        }

        // Funcionalidade de busca expandida
        if ($search) {
            $query->where(function($q) use ($search) {
                $q->where('nome', 'ILIKE', "%{$search}%")
                  ->orWhere('observacoes', 'ILIKE', "%{$search}%")
                  ->orWhereHas('endereco', function($subQuery) use ($search) {
                      $subQuery->where('cidade', 'ILIKE', "%{$search}%")
                               ->orWhere('bairro', 'ILIKE', "%{$search}%")
                               ->orWhere('rua', 'ILIKE', "%{$search}%");
                  });
            });
        }

        // Por padrão retorna todos sem paginação, a menos que explicitamente solicitado
        if ($paginate) {
            return $query->orderBy('nome')->paginate($perPage);
        }

        return $query->orderBy('nome')->get();
    });

    Route::get('/empreendimentos/{id}', function ($id) {
        return Empreendimento::with(['torres.excessoes', 'areasLazer', 'endereco', 'imagensArquivos', 'videosUnidades', 'documentos.tipoDocumento'])->findOrFail($id);
    });

    Route::post('/empreendimentos', [App\Http\Controllers\API\EmpreendimentoController::class, 'store']);
    
    Route::post('/empreendimentos/{id}', [App\Http\Controllers\API\EmpreendimentoController::class, 'update']);
    Route::put('/empreendimentos/{id}', [App\Http\Controllers\API\EmpreendimentoController::class, 'update']);

    Route::delete('/empreendimentos/{id}', [App\Http\Controllers\API\EmpreendimentoController::class, 'destroy']);

    // NOVAS ROTAS DE EXCLUSÃO COMPLETA
    // Analisar o que será excluído antes de deletar
    Route::get('/empreendimentos/{id}/analyze-delete', [App\Http\Controllers\API\EmpreendimentoController::class, 'analyzeDelete']);
    // Exclusão completa de empreendimento e todos dados vinculados (exceto favoritos)
    Route::delete('/empreendimentos/{id}/complete', [App\Http\Controllers\API\EmpreendimentoController::class, 'destroyComplete']);

    // Buscar evoluções vinculadas a um empreendimento (nova funcionalidade)
    Route::get('/empreendimentos/{id}/evolucoes', [App\Http\Controllers\API\EmpreendimentoController::class, 'getEvolucoes']);
    Route::get('/empreendimentos/{id}/evolucao-obra', [App\Http\Controllers\API\EmpreendimentoController::class, 'getEvolucoes']); // Alias para compatibilidade com frontend

    // DOCUMENTOS DE EMPREENDIMENTOS
    Route::get('/empreendimentos/{empreendimentoId}/documentos', [App\Http\Controllers\EmpreendimentoDocumentoController::class, 'index']);
    Route::post('/empreendimentos/{empreendimentoId}/documentos', [App\Http\Controllers\EmpreendimentoDocumentoController::class, 'store']);
    Route::delete('/empreendimentos/{empreendimentoId}/documentos/{documentoId}', [App\Http\Controllers\EmpreendimentoDocumentoController::class, 'destroy']);
    Route::get('/empreendimentos/{empreendimentoId}/documentos/{documentoId}/download', [App\Http\Controllers\EmpreendimentoDocumentoController::class, 'download']);

    // TORRES
    Route::post('/empreendimentos/{id}/torres', function (Request $request, $id) {
        $validated = $request->validate([
            'nome' => 'required|string|max:255',
            'numero_andares' => 'required|integer',
            'quantidade_unidades_andar' => 'required|integer',
        ]);

        $torre = EmpreendimentoTorre::create([
            'empreendimentos_id' => $id,
            ...$validated,
        ]);

        return response()->json($torre, 201);
    });

    Route::put('/torres/{id}', function (Request $request, $id) {
        $torre = EmpreendimentoTorre::findOrFail($id);

        $validated = $request->validate([
            'nome' => 'required|string|max:255',
            'numero_andares' => 'required|integer',
            'quantidade_unidades_andar' => 'required|integer',
        ]);

        $torre->update($validated);

        return response()->json($torre);
    });

    Route::delete('/torres/{id}', function ($id) {
        $torre = EmpreendimentoTorre::findOrFail($id);
        $torre->delete();
        return response()->json(['message' => 'Torre removida com sucesso.']);
    });

    // EXCEÇÕES DE TORRES
    Route::post('/torres/{id}/excessoes', function (Request $request, $id) {
        $validated = $request->validate([
            'numero_andar' => 'required|integer',
            'quantidade_unidades_andar' => 'required|integer',
        ]);

        $excessao = EmpreendimentoTorreExcessao::create([
            'empreendimentos_tores_id' => $id,
            ...$validated,
        ]);

        return response()->json($excessao, 201);
    });

    Route::put('/excessoes/{id}', function (Request $request, $id) {
        $excessao = EmpreendimentoTorreExcessao::findOrFail($id);

        $validated = $request->validate([
            'numero_andar' => 'required|integer',
            'quantidade_unidades_andar' => 'required|integer',
        ]);

        $excessao->update($validated);

        return response()->json($excessao);
    });

    Route::delete('/excessoes/{id}', function ($id) {
        $excessao = EmpreendimentoTorreExcessao::findOrFail($id);
        $excessao->delete();
        return response()->json(['message' => 'Exceção removida com sucesso.']);
    });

    // ÁREAS DE LAZER
    Route::post('/empreendimentos/{id}/areas-lazer', function (Request $request, $id) {
        $validated = $request->validate([
            'tipo_area_lazer_id' => 'required|integer',
        ]);

        $area = EmpreendimentoAreaLazer::create([
            'empreendimentos_id' => $id,
            ...$validated,
        ]);

        return response()->json($area, 201);
    });

    Route::delete('/areas-lazer/{id}', function ($id) {
        $area = EmpreendimentoAreaLazer::findOrFail($id);
        $area->delete();
        return response()->json(['message' => 'Área de lazer removida com sucesso.']);
    });

    // ENDEREÇO
    Route::post('/empreendimentos/{id}/endereco', function (Request $request, $id) {
        $validated = $request->validate([
            'cep' => 'nullable|string|max:9',
            'estado' => 'nullable|string|max:2',
            'cidade' => 'nullable|string|max:100',
            'bairro' => 'nullable|string|max:100',
            'rua' => 'nullable|string|max:255',
            'numero' => 'nullable|string|max:20',
            'complemento' => 'nullable|string|max:255',
        ]);

        $endereco = EmpreendimentoEndereco::updateOrCreate(
            ['empreendimentos_id' => $id],
            $validated
        );

        return response()->json($endereco);
    });

    // IMAGENS E ARQUIVOS
    Route::post('/empreendimentos/{id}/imagens-arquivos', function (Request $request, $id) {
        $validated = $request->validate([
            'foto_url' => 'nullable|string',
            'arquivo_url' => 'nullable|string',
        ]);

        $item = EmpreendimentoImagemArquivo::create([
            'empreendimentos_id' => $id,
            ...$validated,
        ]);

        return response()->json($item, 201);
    });

    Route::delete('/imagens-arquivos/{id}', function ($id) {
        $item = EmpreendimentoImagemArquivo::findOrFail($id);
        $item->delete();
        return response()->json(['message' => 'Arquivo removido com sucesso.']);
    });

    ///////////////////
    // UNIDADES CRUD //
    ///////////////////
    // LISTAR
    Route::get('/torres/{torre_id}/unidades', function (Request $request, $torre_id) {
        $perPage = $request->query('per_page', 10000);
    
        $unidades = EmpreendimentoUnidade::with(['vagas:id,empreendimentos_tores_id,unidade_id,numero_vaga,status', 'medidas'])
            ->where('empreendimentos_tores_id', $torre_id)
            ->orderBy('id', 'desc')
            ->paginate($perPage);
    
        // Buscar todos os tipos de medida de uma vez para melhor performance
        $tiposMedida = \App\Models\TipoMedidaUnidade::all()->keyBy('id');
    
        // Formatar as medidas para o frontend
        $unidades->getCollection()->transform(function ($unidade) use ($tiposMedida) {
            if ($unidade->medidas && $unidade->medidas->count() > 0) {
                $unidade->medidas = $unidade->medidas->map(function ($medida) use ($tiposMedida) {
                    $tipo = $tiposMedida->get($medida->tipo_medida_id);
                    
                    return [
                        'tipo_medida_id' => $medida->tipo_medida_id,
                        'tipo_nome' => $tipo ? $tipo->nome : 'Tipo não encontrado',
                        'tipo_unidade' => $tipo ? $tipo->unidade : 'm²',
                        'valor' => $medida->valor,
                    ];
                });
            }

            $unidade->box_unidades_ids = $unidade->vagas
                ? $unidade->vagas
                    ->pluck('id')
                    ->filter()
                    ->values()
                    ->all()
                : [];

            return $unidade;
        });
    
        return response()->json($unidades);
    });


    // CRIAR
    Route::post('/torres/{torre_id}/unidades', [EmpreendimentoUnidadeController::class, 'store']);

    // ATUALIZAR
    Route::put('/unidades/{id}', [EmpreendimentoUnidadeController::class, 'update']);

    // EXCLUIR
    Route::delete('/unidades/{id}', function ($id) {
        EmpreendimentoUnidade::findOrFail($id)->delete();
        return response()->json(['message' => 'Unidade removida com sucesso.']);
    });

    // Listar vagas de garagem de uma torre
    Route::get('/torres/{torre_id}/vagas-garagem', function (Request $request, $torre_id) {
        $vagas = EmpreendimentoUnidadeVagaGaragem::where('empreendimentos_tores_id', $torre_id)
            ->orderBy('id', 'desc')
            ->get();

        return response()->json($vagas);
    });

    // VAGAS DE GARAGEM
    Route::post('/torres/{torre_id}/vagas-garagem', function (Request $request, $torre_id) {
        $validated = $request->validate([
            'numero_vaga' => 'required|string|max:20',
            'cobertura' => 'nullable|in:Coberto,Descoberto',
            'tipo_vaga' => 'nullable|in:Dupla,Simples,Dupla PCD,Simples PCD',
            'area_total' => 'nullable|numeric|min:0',
            'pavimento' => 'nullable|string|max:100',
            'observacoes' => 'nullable|string',
            'status' => 'nullable|in:Disponível,Reservado,Vendido,Bloqueado,Manutenção',
        ]);

        $vaga = EmpreendimentoUnidadeVagaGaragem::create([
            'empreendimentos_tores_id' => $torre_id,
            ...$validated,
        ]);

        return response()->json($vaga, 201);
    });

    Route::put('/vagas-garagem/{id}', function (Request $request, $id) {
        $vaga = EmpreendimentoUnidadeVagaGaragem::findOrFail($id);

        $validated = $request->validate([
            'numero_vaga' => 'sometimes|required|string|max:20',
            'cobertura' => 'nullable|in:Coberto,Descoberto',
            'tipo_vaga' => 'nullable|in:Dupla,Simples,Dupla PCD,Simples PCD',
            'area_total' => 'nullable|numeric|min:0',
            'pavimento' => 'nullable|string|max:100',
            'observacoes' => 'nullable|string',
            'status' => 'nullable|in:Disponível,Reservado,Vendido,Bloqueado,Manutenção',
        ]);

        $vaga->update($validated);

        return response()->json($vaga);
    });

    Route::delete('/vagas-garagem/{id}', function ($id) {
        $vaga = EmpreendimentoUnidadeVagaGaragem::findOrFail($id);
        $vaga->delete();

        return response()->json(['message' => 'Vaga de garagem removida com sucesso.']);
    });

    // FOTOS DAS UNIDADES
    Route::get('/torres/{torre_id}/fotos-unidade', function (Request $request, $torre_id) {
        $fotos = EmpreendimentoUnidadeFoto::where('empreendimentos_tores_id', $torre_id)
            ->with('categoriaFoto')
            ->orderBy('id', 'desc')
            ->get();

        return response()->json($fotos);
    });

    Route::post('/torres/{torre_id}/fotos-unidade', [UnidadeFotoController::class, 'store']);

    Route::delete('/fotos-unidade/{id}', [UnidadeFotoController::class, 'destroy']);

    // Estatísticas das categorias de fotos
    Route::get('/torres/{torre_id}/fotos-categorias-stats', function ($torre_id) {
        $stats = EmpreendimentoUnidadeFoto::where('empreendimentos_tores_id', $torre_id)
            ->selectRaw('categorias, COUNT(*) as total')
            ->whereNotNull('categorias')
            ->groupBy('categorias')
            ->orderBy('total', 'desc')
            ->get();

        return response()->json($stats);
    });

    // Rotas para vídeos de unidades
    Route::get('/torres/{torre_id}/videos-unidade', [UnidadeVideoController::class, 'index']);
    Route::post('/torres/{torre_id}/videos-unidade', [UnidadeVideoController::class, 'store']);
    Route::put('/torres/{torre_id}/videos-unidade/{id}', [UnidadeVideoController::class, 'update']);
    Route::delete('/torres/{torre_id}/videos-unidade/{id}', [UnidadeVideoController::class, 'destroy']);
    Route::get('/torres/{torre_id}/videos-unidade/categoria/{categoria}', [UnidadeVideoController::class, 'getByCategoria']);
    Route::get('/torres/{torre_id}/videos-categorias', [UnidadeVideoController::class, 'getCategorias']);
    
    // Rota para streaming de vídeos
    Route::get('/videos/{id}/stream', [UnidadeVideoController::class, 'serveVideo']);

    /////////////////////////
    // NEGOCIAÇÕES CRUD //
    /////////////////////////
    // Listagem

    // Criar
    Route::post('/negociacoes', function (Request $request) {
        try {
            // Log simples para acompanhamento

            \Log::info("=== CRIANDO NOVA NEGOCIAÇÃO API ===");
            \Log::info("Permuta recebida: " . json_encode($request->input('permuta')));
            
            $validated = $request->validate([
                'empreendimentos_id'                  => 'required|exists:empreendimentos,id',
                'empreendimentos_unidades_id'         => 'required|exists:empreendimentos_unidades,id',
                'empreendimentos_box_id'              => 'required|exists:empreendimentos_unidades_vagas_garem,id',
                'clientes_id'                         => 'required|exists:clientes,id',
                'imobiliarias_id'                     => 'required|exists:imobiliarias,id',
                'equipe_usuarios_id'                  => 'nullable|integer',
                'corretores_id'                       => 'nullable|integer',
                'valor_contrato'                      => 'nullable|numeric',
                'numero_contrato'                     => 'nullable|string|max:50',
                'data'                                => 'nullable|date',
                'modalidades_vendas_id'               => 'nullable|integer',
                'situacoes_vendas_id'                 => 'nullable|integer',
                'validade'                            => 'nullable|date',
                'conformidades_vendas_id'             => 'nullable|integer',
                'nome_correspondente'                 => 'nullable|string|max:255',
                'ibti_registro_vendas_id'             => 'nullable|integer',
                'valor_entrada_ato'                   => 'nullable|numeric',
                'quantidade_parcelas_disponiveis_id'  => 'nullable|integer',
                'valor_reforco'                       => 'nullable|numeric',
                'valor_financiamento'                 => 'nullable|numeric',
                'nome_banco'                          => 'nullable|string|max:255',
                'diferenca_valor'                     => 'nullable|numeric',
                'percentual_comissao'                 => 'nullable|numeric',
                'equipe_usuarios_id_corretor'         => 'nullable|integer',
                'negociacoes_status_id'               => 'nullable|integer',
                'registro_imoveis_cidade_cartorio'    => 'nullable|string|max:255',
                'observacoes'                         => 'nullable|string',
                'parcelas_atos_numero'                => 'nullable|integer',
                'parcelas_documentacao_construtora'   => 'nullable|integer',
                'valor_fgts'                          => 'nullable|numeric',
                'utilizar_fgts'                       => 'nullable|boolean',
                'distratado'                          => 'nullable|boolean',
                'itbi_responsavel'                    => 'nullable|in:cliente,construtora',
                'registro_responsavel'                => 'nullable|in:cliente,construtora',
                'data_vencimento_avaliacao_cca'       => 'nullable|date',
                'data_assinatura_contrato_construtora'=> 'nullable|date',
                'permuta'                             => 'nullable|numeric|min:0|max:9999999999.99',
            ]);

            
            \Log::info("Permuta após validação: " . json_encode($validated['permuta'] ?? 'null'));

            $negociacao = Negociacao::create($validated);

            // SOLUÇÃO DEFINITIVA: Atualizar permuta diretamente via SQL
            $permutaValue = $request->input('permuta');
            if ($permutaValue !== null) {
                \DB::table('negociacoes')
                    ->where('id', $negociacao->id)
                    ->update(['permuta' => $permutaValue]);

                // Recarregar modelo para ter o valor atualizado
                $negociacao->refresh();
            }

            \Log::info("Negociação criada ID: " . $negociacao->id . ", Permuta final: " . $negociacao->permuta);
            
            $negociacaoCriada = $negociacao->fresh(['empreendimento', 'unidade', 'cliente.pessoa', 'corretor', 'equipeUsuario', 'status']);

            // Garantir que permuta seja incluída na resposta
            $response = $negociacaoCriada->toArray();
            $response['permuta'] = $negociacaoCriada->permuta;

            return response()->json($response, 201);
        } catch (\Exception $e) {
            \Log::error("Erro ao criar negociação:", [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
                'request_data' => $request->all()
            ]);
            
            return response()->json([
                'error' => 'Erro ao criar negociação',
                'message' => $e->getMessage()
            ], 500);
        }
    });

    // Atualizar
    Route::put('/negociacoes/{id}', function (Request $request, $id) {
        try {
            \Log::info("=== ATUALIZANDO NEGOCIAÇÃO API ===");
            \Log::info("ID:", ['id' => $id]);
            \Log::info("Timestamp: " . now()->format('Y-m-d H:i:s.u'));
            \Log::info("Request ID: " . uniqid('REQ_'));
            \Log::info("Method: " . $request->method());
            \Log::info("Content-Type: " . $request->header('Content-Type'));
            \Log::info("Raw Content: " . $request->getContent());
            \Log::info("Dados recebidos (all):", $request->all());
            \Log::info("Permuta específica (input): " . json_encode($request->input('permuta')));
            \Log::info("Tipo da permuta recebida: " . gettype($request->input('permuta')));

            $negociacao = Negociacao::findOrFail($id);
            \Log::info("Negociação encontrada - ID: " . $negociacao->id);
            \Log::info("Permuta ATUAL no banco: " . $negociacao->permuta);
            \Log::info("Valor contrato ATUAL: " . $negociacao->valor_contrato);

            $validated = $request->validate([
                'empreendimentos_id'                  => 'required|exists:empreendimentos,id',
                'empreendimentos_unidades_id'         => 'required|exists:empreendimentos_unidades,id',
                'empreendimentos_box_id'              => 'required|exists:empreendimentos_unidades_vagas_garem,id',
                'clientes_id'                         => 'required|exists:clientes,id',
                'imobiliarias_id'                     => 'required|exists:imobiliarias,id',
                'equipe_usuarios_id'                  => 'nullable|integer',
                'corretores_id'                       => 'nullable|integer',
                'valor_contrato'                      => 'nullable|numeric',
                'numero_contrato'                     => 'nullable|string|max:50',
                'data'                                => 'nullable|date',
                'modalidades_vendas_id'               => 'nullable|integer',
                'situacoes_vendas_id'                 => 'nullable|integer',
                'validade'                            => 'nullable|date',
                'conformidades_vendas_id'             => 'nullable|integer',
                'nome_correspondente'                 => 'nullable|string|max:255',
                'ibti_registro_vendas_id'             => 'nullable|integer',
                'valor_entrada_ato'                   => 'nullable|numeric',
                'quantidade_parcelas_disponiveis_id'  => 'nullable|integer',
                'valor_reforco'                       => 'nullable|numeric',
                'valor_financiamento'                 => 'nullable|numeric',
                'nome_banco'                          => 'nullable|string|max:255',
                'diferenca_valor'                     => 'nullable|numeric',
                'percentual_comissao'                 => 'nullable|numeric',
                'equipe_usuarios_id_corretor'         => 'nullable|integer',
                'negociacoes_status_id'               => 'nullable|integer',
                'registro_imoveis_cidade_cartorio'    => 'nullable|string|max:255',
                'observacoes'                         => 'nullable|string',
                'parcelas_atos_numero'                => 'nullable|integer',
                'parcelas_documentacao_construtora'   => 'nullable|integer',
                'valor_fgts'                          => 'nullable|numeric',
                'utilizar_fgts'                       => 'nullable|boolean',
                'distratado'                          => 'nullable|boolean',
                'itbi_responsavel'                    => 'nullable|in:cliente,construtora',
                'registro_responsavel'                => 'nullable|in:cliente,construtora',
                'data_vencimento_avaliacao_cca'       => 'nullable|date',
                'data_assinatura_contrato_construtora'=> 'nullable|date',
                'permuta'                             => 'nullable|numeric|min:0|max:9999999999.99',
            ]);


            \Log::info("=== APÓS VALIDAÇÃO ===");
            \Log::info("Dados validados (array completo):", $validated);
            \Log::info("Permuta validada: " . json_encode($validated['permuta'] ?? null));
            \Log::info("Tipo da permuta validada: " . gettype($validated['permuta'] ?? null));
            \Log::info("Distratado validado: " . json_encode($validated['distratado'] ?? null));

            // Verificar se permuta está sendo modificada
            if (isset($validated['permuta'])) {
                \Log::info("🔄 PERMUTA SERÁ ALTERADA:");
                \Log::info("  De: " . $negociacao->permuta);
                \Log::info("  Para: " . $validated['permuta']);

                if ($validated['permuta'] != $request->input('permuta')) {
                    \Log::warning("⚠️ ATENÇÃO: Valor foi modificado na validação!");
                    \Log::warning("  Request: " . $request->input('permuta'));
                    \Log::warning("  Validado: " . $validated['permuta']);
                }
            }

            \Log::info("=== EXECUTANDO UPDATE ===");
            $negociacao->update($validated);

            // SOLUÇÃO DEFINITIVA: Atualizar permuta diretamente via SQL se foi enviada
            $permutaValue = $request->input('permuta');
            if ($permutaValue !== null) {
                \DB::table('negociacoes')
                    ->where('id', $id)
                    ->update(['permuta' => $permutaValue]);
            }

            \Log::info("=== APÓS UPDATE (sem recarregar) ===");
            \Log::info("Permuta no modelo: " . $negociacao->permuta);
            \Log::info("Distratado no modelo: " . $negociacao->distratado);

            // Verificar direto no banco
            $valorNoBanco = \DB::select("SELECT permuta FROM negociacoes WHERE id = ?", [$id])[0]->permuta ?? null;
            \Log::info("Permuta direto do BANCO (SQL): " . $valorNoBanco);

            if ($negociacao->permuta != $valorNoBanco) {
                \Log::error("❌ DISCREPÂNCIA DETECTADA!");
                \Log::error("  Modelo tem: " . $negociacao->permuta);
                \Log::error("  Banco tem: " . $valorNoBanco);
            }

            // Verificar se houve duplicação
            if (isset($validated['permuta']) && $negociacao->permuta == $validated['permuta'] * 2) {
                \Log::error("❌ VALOR FOI DUPLICADO!");
                \Log::error("  Enviado: " . $validated['permuta']);
                \Log::error("  Salvo: " . $negociacao->permuta);
                \Log::error("  Fator: 2x");
            }

            \Log::info("=== RECARREGANDO COM FRESH ===");
            $negociacaoAtualizada = $negociacao->fresh(['empreendimento', 'unidade', 'cliente', 'corretor', 'equipeUsuario', 'status']);
            \Log::info("Permuta após fresh(): " . $negociacaoAtualizada->permuta);
            \Log::info("valorPermuta calculado: " . $negociacaoAtualizada->valorPermuta);

            // Análise final
            \Log::info("=== ANÁLISE FINAL ===");
            if (isset($validated['permuta'])) {
                $valorEnviado = $request->input('permuta');
                $valorValidado = $validated['permuta'];
                $valorFinal = $negociacaoAtualizada->permuta;

                \Log::info("📊 RESUMO DA PERMUTA:");
                \Log::info("  1. Valor enviado (request): " . json_encode($valorEnviado));
                \Log::info("  2. Valor validado: " . json_encode($valorValidado));
                \Log::info("  3. Valor final (salvo): " . json_encode($valorFinal));

                if ($valorEnviado == $valorFinal) {
                    \Log::info("✅ SUCESSO: Valor salvo corretamente");
                } else {
                    \Log::error("❌ PROBLEMA DETECTADO:");
                    \Log::error("  Esperado: " . $valorEnviado);
                    \Log::error("  Recebido: " . $valorFinal);

                    if ($valorFinal == $valorEnviado * 2) {
                        \Log::error("  📍 Padrão: DUPLICAÇÃO (2x)");
                    } elseif ($valorFinal == $valorEnviado * 0.4) {
                        \Log::error("  📍 Padrão: MULTIPLICAÇÃO por 0.4");
                    }
                }
            }

            \Log::info("=== FIM DA ATUALIZAÇÃO ===");

            // Garantir que permuta seja incluída na resposta
            $response = $negociacaoAtualizada->toArray();
            $response['permuta'] = $negociacaoAtualizada->permuta;

            return response()->json($response);
        } catch (\Exception $e) {
            \Log::error("Erro ao atualizar negociação:", [
                'id' => $id,
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ]);
            
            return response()->json([
                'error' => 'Erro ao atualizar negociação',
                'message' => $e->getMessage()
            ], 500);
        }
    });

    // Deletar
    Route::delete('/negociacoes/{id}', function ($id) {
        $negociacao = Negociacao::findOrFail($id);
        $negociacao->delete();
        return response()->json(['message' => 'Negociação removida com sucesso.']);
    });

    /////////////////////
    // PAGAMENTOS CRUD //
    /////////////////////
    Route::get('/pagamentos', function (Request $request) {
        return Pagamento::with('negociacao')->orderBy('id', 'desc')->paginate(15);
    });

    // CRIAR PAGAMENTO
    Route::post('/pagamentos', function (Request $request) {
        $validated = $request->validate([
            'negociacoes_id' => 'required|integer',
            'valor_total_pago' => 'required|numeric',
            'formas_pagamento_id' => 'required|integer',
        ]);

        $pagamento = Pagamento::create($validated);

        return response()->json($pagamento, 201);
    });

    // ATUALIZAR PAGAMENTO
    Route::put('/pagamentos/{id}', function (Request $request, $id) {
        $pagamento = Pagamento::findOrFail($id);

        $validated = $request->validate([
            'valor_total_pago' => 'nullable|numeric',
            'formas_pagamento_id' => 'nullable|integer',
        ]);

        $pagamento->update($validated);

        return response()->json($pagamento);
    });

    // DELETAR PAGAMENTO
    Route::delete('/pagamentos/{id}', function ($id) {
        $pagamento = Pagamento::findOrFail($id);
        $pagamento->delete();

        return response()->json(['message' => 'Pagamento removido com sucesso.']);
    });

    ///////////////////
    // PARCELAS CRUD //
    ///////////////////
    Route::get('/parcelas', function () {
        return PagamentoParcela::with('negociacao')->orderBy('data_limite_pagamento')->get();
    });

    // CRIAR PARCELA
    Route::post('/parcelas', function (Request $request) {
        $validated = $request->validate([
            'negociacoes_id' => 'required|integer',
            'valor_parcela' => 'required|numeric',
            'data_limite_pagamento' => 'required|date',
            'status_pagamentos_parcelas_id' => 'required|integer',
        ]);

        $parcela = PagamentoParcela::create($validated);

        return response()->json($parcela, 201);
    });

    // ATUALIZAR PARCELA
    Route::put('/parcelas/{id}', function (Request $request, $id) {
        $parcela = PagamentoParcela::findOrFail($id);

        $validated = $request->validate([
            'valor_parcela' => 'nullable|numeric',
            'data_limite_pagamento' => 'nullable|date',
            'status_pagamentos_parcelas_id' => 'nullable|integer',
        ]);

        $parcela->update($validated);

        return response()->json($parcela);
    });

    // DELETAR PARCELA
    Route::delete('/parcelas/{id}', function ($id) {
        $parcela = PagamentoParcela::findOrFail($id);
        $parcela->delete();

        return response()->json(['message' => 'Parcela removida com sucesso.']);
    });

    ///////////////////////////////
    // HISTORICO PAGAMENTOS CRUD //
    ///////////////////////////////
    Route::get('/historico-pagamentos', function () {
        return HistoricoPagamento::with('negociacao')->orderBy('data', 'desc')->get();
    });

    // ADICIONAR REGISTRO AO HISTÓRICO
    Route::post('/historico-pagamentos', function (Request $request) {
        $validated = $request->validate([
            'negociacoes_id' => 'required|integer',
            'valor_pago' => 'required|numeric',
            'data' => 'required|date',
        ]);

        $historico = HistoricoPagamento::create($validated);

        return response()->json($historico, 201);
    });

    // DELETAR REGISTRO DO HISTÓRICO
    Route::delete('/historico-pagamentos/{id}', function ($id) {
        $historico = HistoricoPagamento::findOrFail($id);
        $historico->delete();

        return response()->json(['message' => 'Registro removido com sucesso.']);
    });

    ////////////////
    // LEADS CRUD //
    ////////////////
    Route::get('/leads/all', function() {
        return Lead::with('origem')->orderBy('id', 'desc')->get();
    });

    // DASHBOARD STATISTICS
    Route::get('/dashboard/stats', function() {
        try {
            // Contadores básicos
            $totalClientes = Cliente::count();
            $totalNegociacoes = Negociacao::count();
            $totalLeads = Lead::count();
            $totalEmpreendimentos = Empreendimento::count();
            $valorTotalNegociacoes = Negociacao::sum('valor_contrato') ?: 0;
            
            // Negociações por status
            $negociacoesStatus = NegociacaoStatus::withCount('negociacoes')
                ->get()
                ->map(function($status) {
                    return [
                        'nome' => $status->nome,
                        'count' => $status->negociacoes_count
                    ];
                });
            
            // Clientes por status
            $clientesStatus = \App\Models\StatusCliente::withCount('clientes')
                ->get()
                ->map(function($status) {
                    return [
                        'nome' => $status->nome,
                        'count' => $status->clientes_count
                    ];
                });
            
            // Evolução mensal (últimos 6 meses)
            $evolucaoMensal = [];
            $valorMensal = [];
            for ($i = 5; $i >= 0; $i--) {
                $data = now()->subMonths($i);
                $mesAno = $data->format('Y-m');
                
                $negociacoesMes = Negociacao::whereYear('created_at', $data->year)
                    ->whereMonth('created_at', $data->month)
                    ->count();
                    
                $clientesMes = Cliente::whereYear('created_at', $data->year)
                    ->whereMonth('created_at', $data->month)
                    ->count();

                $valorTotalMes = Negociacao::whereYear('created_at', $data->year)
                    ->whereMonth('created_at', $data->month)
                    ->sum('valor_contrato') ?: 0;
                
                $evolucaoMensal[] = [
                    'mes' => $data->format('M Y'),
                    'negociacoes' => $negociacoesMes,
                    'clientes' => $clientesMes
                ];

                $valorMensal[] = [
                    'mes' => $data->format('M Y'),
                    'valor' => (float) $valorTotalMes
                ];
            }

            // Top 5 Empreendimentos com mais negociações
            $topEmpreendimentos = Empreendimento::withCount('negociacoes')
                ->orderBy('negociacoes_count', 'desc')
                ->take(5)
                ->get()
                ->map(function($empreendimento) {
                    return [
                        'nome' => $empreendimento->nome,
                        'count' => $empreendimento->negociacoes_count
                    ];
                });
            
            return response()->json([
                'totals' => [
                    'clientes' => $totalClientes,
                    'negociacoes' => $totalNegociacoes,
                    'leads' => $totalLeads,
                    'empreendimentos' => $totalEmpreendimentos,
                    'valor_total' => (float) $valorTotalNegociacoes
                ],
                'negociacoes_status' => $negociacoesStatus,
                'clientes_status' => $clientesStatus,
                'evolucao_mensal' => $evolucaoMensal,
                'valor_mensal' => $valorMensal,
                'top_empreendimentos' => $topEmpreendimentos
            ]);
            
        } catch (\Exception $e) {
            return response()->json([
                'error' => 'Erro ao buscar estatísticas do dashboard',
                'message' => $e->getMessage()
            ], 500);
        }
    });

    Route::get('/leads', function (Request $request) {
        try {
            $perPage = $request->query('per_page', 10000);
            $search = $request->query('search');
            $startDate = $request->query('start_date');
            $endDate = $request->query('end_date');

            // Validar datas se fornecidas
            if ($startDate && !preg_match('/^\d{4}-\d{2}-\d{2}$/', $startDate)) {
                return response()->json(['message' => 'Formato de start_date inválido. Use YYYY-MM-DD'], 422);
            }
            if ($endDate && !preg_match('/^\d{4}-\d{2}-\d{2}$/', $endDate)) {
                return response()->json(['message' => 'Formato de end_date inválido. Use YYYY-MM-DD'], 422);
            }
            if ($startDate && $endDate && $startDate > $endDate) {
                return response()->json(['message' => 'start_date deve ser menor ou igual a end_date'], 422);
            }

            $query = Lead::with(['origem']);

            // Filtro de período
            if ($startDate) {
                $query->where('created_at', '>=', $startDate . ' 00:00:00');
            }
            if ($endDate) {
                $query->where('created_at', '<=', $endDate . ' 23:59:59');
            }

            if ($search) {
                $query->where(function ($q) use ($search) {
                    $q->where('nome', 'ILIKE', "%{$search}%")
                    ->orWhere('email', 'ILIKE', "%{$search}%")
                    ->orWhere('telefone', 'ILIKE', "%{$search}%");
                });
            }

            return $query->orderBy('id', 'desc')->paginate($perPage);

        } catch (\Exception $e) {
            return response()->json([
                'error' => 'Erro ao buscar leads',
                'message' => $e->getMessage(),
            ], 500);
        }
    });

    // DETALHAR LEAD
    Route::get('/leads/{id}', function ($id) {
        return Lead::with(['origem'])->findOrFail($id);
    });

    // CRIAR LEAD
    Route::post('/leads', function (Request $request) {
        $validated = $request->validate([
            'nome' => 'required|string|max:255',
            'telefone' => 'nullable|string|max:20',
            'email' => 'nullable|email|max:255',
            'profissao' => 'nullable|string|max:255',
            'status_leads' => 'nullable|integer',
            'origens_leads_id' => 'nullable|integer|exists:origens_leads,id',
            'observacoes' => 'nullable|string',
            'motivo' => 'nullable|string',
        ]);

        $validated['data_entrada'] = now()->format('Y-m-d');

        $lead = Lead::create($validated);

        return response()->json($lead->load('origem'), 201);
    });

    // ATUALIZAR LEAD
    Route::put('/leads/{id}', function (Request $request, $id) {
        $lead = Lead::findOrFail($id);

        $validated = $request->validate([
            'nome' => 'required|string|max:255',
            'telefone' => 'nullable|string|max:20',
            'email' => 'nullable|email|max:255',
            'profissao' => 'nullable|string|max:255',
            'status_leads' => 'nullable|integer',
            'origens_leads_id' => 'nullable|integer|exists:origens_leads,id',
            'observacoes' => 'nullable|string',
            'motivo' => 'nullable|string',
        ]);

        $lead->update($validated);

        return response()->json($lead->load('origem'));
    });

    // EXCLUIR LEAD
    Route::delete('/leads/{id}', function ($id) {
        $lead = Lead::findOrFail($id);
        $lead->delete();

        return response()->json(['message' => 'Lead removido com sucesso.']);
    });

    // ENDEREÇOS DE IMOBILIÁRIAS
    Route::prefix('imobiliarias-endereco')->group(function () {
        Route::get('/', fn() => ImobiliariaEndereco::with('imobiliaria')->paginate(10));
        Route::post('/', fn(Request $request) => ImobiliariaEndereco::create(
            $request->validate([
                'imobiliarias_id' => 'required|exists:imobiliarias,id',
                'cep'             => 'nullable|string|max:9',
                'estado'          => 'nullable|string|size:2',
                'cidade'          => 'nullable|string|max:100',
                'bairro'          => 'nullable|string|max:100',
                'rua'             => 'nullable|string|max:255',
                'numero'          => 'nullable|string|max:20',
                'complemento'     => 'nullable|string|max:255',
            ])
        ));
        Route::get('/{endereco}', fn(ImobiliariaEndereco $endereco) => $endereco->load('imobiliaria'));
        Route::put('/{endereco}', fn(Request $request, ImobiliariaEndereco $endereco) =>
            tap($endereco)->update($request->validate([
                'imobiliarias_id' => 'sometimes|required|exists:imobiliarias,id',
                'cep'             => 'nullable|string|max:9',
                'estado'          => 'nullable|string|size:2',
                'cidade'          => 'nullable|string|max:100',
                'bairro'          => 'nullable|string|max:100',
                'rua'             => 'nullable|string|max:255',
                'numero'          => 'nullable|string|max:20',
                'complemento'     => 'nullable|string|max:255',
            ]))
        );
        Route::delete('/{endereco}', fn(ImobiliariaEndereco $endereco) =>
            tap($endereco)->delete() && response()->json(['message' => 'Endereço excluído com sucesso'])
        );
    });

    // RESPONSÁVEIS PELA IMOBILIÁRIA
    Route::prefix('imobiliarias-responsaveis')->group(function () {
        Route::get('/', fn() => ImobiliariaResponsavel::with('imobiliaria')->paginate(10));
        Route::post('/', function(Request $request) {
            $data = $request->validate([
                'imobiliarias_id' => 'required|exists:imobiliarias,id',
                'nome'            => 'required|string|max:255',
                'cpf'             => 'nullable|string|max:18',
                'email'           => 'nullable|email|max:255',
                'senha'           => 'required|string|min:6',
            ]);
            $data['senha'] = bcrypt($data['senha']);
            return ImobiliariaResponsavel::create($data);
        });
        Route::get('/{responsavel}', fn(ImobiliariaResponsavel $responsavel) =>
            $responsavel->load('imobiliaria')
        );
        Route::put('/{responsavel}', function(Request $request, ImobiliariaResponsavel $responsavel) {
            $data = $request->validate([
                'imobiliarias_id' => 'sometimes|required|exists:imobiliarias,id',
                'nome'            => 'sometimes|required|string|max:255',
                'cpf'             => 'nullable|string|max:18',
                'email'           => 'nullable|email|max:255',
                'senha'           => 'nullable|string|min:6',
            ]);
            if (isset($data['senha'])) {
                $data['senha'] = bcrypt($data['senha']);
            }
            return tap($responsavel)->update($data);
        });
        Route::delete('/{responsavel}', fn(ImobiliariaResponsavel $responsavel) =>
            tap($responsavel)->delete() && response()->json(['message' => 'Responsável excluído com sucesso'])
        );
    });

    /////////////////////////////
    // TABELAS AUXILIARES CRUD //
    /////////////////////////////
    // TIPO EMPREENDIMENTO
    Route::get('/tipo-empreendimentos', fn() => \App\Models\TipoEmpreendimento::orderBy('nome')->get());

    // TIPO UNIDADES
    Route::get('/tipo-unidades', fn() => \App\Models\TipoUnidade::orderBy('nome')->get());

    // STATUS UNIDADES
    Route::get('/status-unidades', fn() => \App\Models\StatusUnidade::orderBy('nome')->get());

    // TIPO ÁREA DE LAZER
    Route::get('/tipo-areas-lazer', fn() => \App\Models\TipoAreaLazer::orderBy('nome')->get());

    // STATUS EMPREENDIMENTO
    Route::get('/empreendimentos-status', fn() => \App\Models\EmpreendimentoStatus::orderBy('nome')->get());

    // STATUS CLIENTES (com gerenciamento para usuários autorizados)
    Route::get('/status-clientes', [App\Http\Controllers\StatusClienteController::class, 'index']);
    Route::post('/status-clientes', [App\Http\Controllers\StatusClienteController::class, 'store']);
    Route::put('/status-clientes/{id}', [App\Http\Controllers\StatusClienteController::class, 'update']);
    Route::delete('/status-clientes/{id}', [App\Http\Controllers\StatusClienteController::class, 'destroy']);

    // TIPOS DE DOCUMENTOS
    Route::get('/tipos-documentos', [App\Http\Controllers\TipoDocumentoController::class, 'index']);
    Route::post('/tipos-documentos', [App\Http\Controllers\TipoDocumentoController::class, 'store']);
    Route::put('/tipos-documentos/{id}', [App\Http\Controllers\TipoDocumentoController::class, 'update']);
    Route::delete('/tipos-documentos/{id}', [App\Http\Controllers\TipoDocumentoController::class, 'destroy']);

    // MOTIVOS DE PERDA
    Route::get('/motivos-perdas', [App\Http\Controllers\MotivoPerdaController::class, 'index']);
    Route::post('/motivos-perdas', [App\Http\Controllers\MotivoPerdaController::class, 'store']);
    Route::put('/motivos-perdas/{id}', [App\Http\Controllers\MotivoPerdaController::class, 'update']);
    Route::delete('/motivos-perdas/{id}', [App\Http\Controllers\MotivoPerdaController::class, 'destroy']);

    // ORIGENS DE LEAD
    Route::get('/origens-leads', [App\Http\Controllers\OrigemLeadController::class, 'index']);
    Route::post('/origens-leads', [App\Http\Controllers\OrigemLeadController::class, 'store']);
    Route::put('/origens-leads/{id}', [App\Http\Controllers\OrigemLeadController::class, 'update']);
    Route::delete('/origens-leads/{id}', [App\Http\Controllers\OrigemLeadController::class, 'destroy']);

    // STATUS DE LEADS
    Route::get('/status-leads', [App\Http\Controllers\StatusLeadController::class, 'index']);
    Route::post('/status-leads', [App\Http\Controllers\StatusLeadController::class, 'store']);
    Route::put('/status-leads/{id}', [App\Http\Controllers\StatusLeadController::class, 'update']);
    Route::delete('/status-leads/{id}', [App\Http\Controllers\StatusLeadController::class, 'destroy']);

    // MODALIDADES DE VENDA
    Route::get('/modalidades-vendas', fn() => \App\Models\ModalidadeVenda::orderBy('nome')->get());

    // SITUAÇÕES DE VENDA
    Route::get('/situacoes-vendas', fn() => \App\Models\SituacaoVenda::orderBy('nome')->get());

    // CONFORMIDADES DE VENDA
    Route::get('/conformidades-vendas', fn() => \App\Models\ConformidadeVenda::orderBy('nome')->get());

    // REGISTROS IBTI
    Route::get('/ibti-registro-vendas', fn() => \App\Models\IbtiRegistroVenda::orderBy('nome')->get());

    // QUANTIDADE PARCELAS DISPONÍVEIS
    Route::get('/quantidade-parcelas-disponiveis', fn() => \App\Models\QuantidadeParcelasDisponivel::orderBy('quantidade')->get());

    // STATUS NEGOCIAÇÕES (público para dashboard)
    Route::get('/status-negociacoes', [App\Http\Controllers\Api\StatusNegociacoesController::class, 'index']);
    Route::post('/status-negociacoes', [App\Http\Controllers\Api\StatusNegociacoesController::class, 'store']);
    Route::get('/status-negociacoes/{id}', [App\Http\Controllers\Api\StatusNegociacoesController::class, 'show']);
    Route::put('/status-negociacoes/{id}', [App\Http\Controllers\Api\StatusNegociacoesController::class, 'update']);
    Route::delete('/status-negociacoes/{id}', [App\Http\Controllers\Api\StatusNegociacoesController::class, 'destroy']);

    // STATUS NEGOCIAÇÕES (alias para compatibilidade)
    Route::get('/negociacoes-status', fn() => \App\Models\NegociacaoStatus::where('ativo', true)->orderBy('ordem', 'asc')->orderBy('nome', 'asc')->get());

    // STATUS PAGAMENTOS PARCELAS
    Route::get('/status-pagamentos-parcelas', fn() => \App\Models\StatusPagamentoParcela::orderBy('nome')->get());
    
    // FORMAS DE PAGAMENTO
    Route::get('/formas-pagamento', fn() => \App\Models\FormaPagamento::orderBy('nome')->get());

    // STATUS LEADS
    Route::get('/status-leads', fn() => \App\Models\StatusLead::orderBy('nome')->get());

    // CATEGORIAS DE FOTOS
    Route::get('/categorias-fotos', [App\Http\Controllers\API\CategoriaFotoController::class, 'index']);
    Route::post('/categorias-fotos', [App\Http\Controllers\API\CategoriaFotoController::class, 'store']);
    Route::get('/categorias-fotos/{id}', [App\Http\Controllers\API\CategoriaFotoController::class, 'show']);
    Route::put('/categorias-fotos/{id}', [App\Http\Controllers\API\CategoriaFotoController::class, 'update']);
    Route::delete('/categorias-fotos/{id}', [App\Http\Controllers\API\CategoriaFotoController::class, 'destroy']);

    /////////////////////////////
    // UPLOAD DE ARQUIVOS //
    /////////////////////////////
    Route::prefix('upload')->group(function () {
        Route::post('/file', [FileUploadController::class, 'upload']);
        Route::post('/files', [FileUploadController::class, 'uploadMultiple']);
        Route::delete('/file', [FileUploadController::class, 'delete']);
    });

});

// ================================================
// ================================================
// CANAIS DE CONTATO ROUTES
// ================================================
use App\Http\Controllers\Api\CanaisContatoController;

// Rotas para o painel administrativo (sem autenticação, consistente com outras rotas)
Route::get('/canais-contato', [CanaisContatoController::class, 'index']);
Route::put('/canais-contato', [CanaisContatoController::class, 'update']);

// Rota pública para o app
Route::get('/app/canais-contato', [CanaisContatoController::class, 'appIndex']);

// ================================================
// TERMOS DE USO ROUTES
// ================================================
use App\Http\Controllers\Api\TermosUsoController;

// Rotas para o painel administrativo
Route::get('/termos-uso', [TermosUsoController::class, 'index']);
Route::put('/termos-uso', [TermosUsoController::class, 'update']);

// Rota pública para o app
Route::get('/app/termos-uso', [TermosUsoController::class, 'appIndex']);

// ================================================
// POLÍTICA DE PRIVACIDADE ROUTES
// ================================================
use App\Http\Controllers\Api\PoliticaPrivacidadeController;

// Rotas para o painel administrativo
Route::get('/politica-privacidade', [PoliticaPrivacidadeController::class, 'index']);
Route::put('/politica-privacidade', [PoliticaPrivacidadeController::class, 'update']);

// Rota pública para o app
Route::get('/app/politica-privacidade', [PoliticaPrivacidadeController::class, 'appIndex']);

// ================================================
// CLICK TRACKING API ROUTES
// ================================================
// Rotas protegidas para click tracking e estatísticas
Route::middleware('auth:sanctum')->prefix('click-tracking')->group(function () {
    Route::get('/test-auth', [ClickTrackingController::class, 'testAuth']);
    Route::post('/track', [ClickTrackingController::class, 'trackClick']);
    Route::get('/entity-stats', [ClickTrackingController::class, 'getEntityStats']);
    Route::get('/share-stats', [ClickTrackingController::class, 'getShareStats']);
    Route::get('/general-stats', [ClickTrackingController::class, 'getGeneralStats']);
    Route::get('/user-stats', [ClickTrackingController::class, 'getUserStats']);
    Route::get('/corretor-stats', [ClickTrackingController::class, 'getCorretorStats']);
    Route::get('/empreendimento-stats', [ClickTrackingController::class, 'getEmpreendimentoStats']);
    Route::get('/corretor-empreendimento-stats', [ClickTrackingController::class, 'getCorretorEmpreendimentoStats']);
    Route::get('/top-empreendimentos', [ClickTrackingController::class, 'getTopEmpreendimentos']);
    Route::get('/daily-stats', [ClickTrackingController::class, 'getDailyStats']);
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
// VALE INCORP MOBILE APP API ROUTES
// ================================================
// Incluir todas as rotas específicas do app mobile
require __DIR__ . '/vale_incorp_api.php';
