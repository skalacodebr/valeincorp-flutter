<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\Empreendimento;
use App\Models\EmpreendimentoUnidade;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class ImovelController extends Controller
{
    public function index(Request $request)
    {
        $page = $request->get('page', 1);
        $limit = min($request->get('limit', 20), 100);

        $query = Empreendimento::with(['endereco', 'status', 'imagensArquivos', 'fotosUnidades', 'torres.excessoes', 'unidades'])
            ->orderBy('id', 'desc');

        // Aplicar filtros
        if ($request->has('cidade')) {
            $query->whereHas('endereco', function ($q) use ($request) {
                $q->where('cidade', 'like', '%' . $request->cidade . '%');
            });
        }

        if ($request->has('search') && !empty(trim($request->search))) {
            $search = trim($request->search);
            $query->where(function ($q) use ($search) {
                // Busca principalmente no nome (mais restritiva)
                $q->where('nome', 'like', '%' . $search . '%');

                // Também busca no código se for informado
                if (strlen($search) <= 10) { // Códigos geralmente são curtos
                    $q->orWhere('codigo', 'like', '%' . $search . '%');
                }
            });
        }

        $imoveis = $query->paginate($limit, ['*'], 'page', $page);

        return response()->json([
            'success' => true,
            'data' => $imoveis->map(function ($item) {
                return $this->formatImovelBasic($item);
            }),
            'pagination' => [
                'currentPage' => $imoveis->currentPage(),
                'totalPages' => $imoveis->lastPage(),
                'totalItems' => $imoveis->total(),
                'itemsPerPage' => $imoveis->perPage(),
                'hasNextPage' => $imoveis->hasMorePages(),
                'hasPreviousPage' => $imoveis->currentPage() > 1,
            ]
        ]);
    }

    public function show($id)
    {
        $imovel = Empreendimento::with(['endereco', 'status', 'imagensArquivos', 'fotosUnidades', 'torres.excessoes', 'torres.fotosUnidades.categoriaFoto', 'torres.videosUnidades', 'areasLazer', 'unidades', 'torres.unidades', 'documentos.tipoDocumento'])
            ->findOrFail($id);

        return response()->json([
            'success' => true,
            'data' => $this->formatImovelDetailed($imovel)
        ]);
    }

    public function getImages($id, $storyType)
    {
        $imovel = Empreendimento::with(['imagensArquivos', 'fotosUnidades'])->findOrFail($id);

        $imagens = collect();

        // Filtra por categoria das fotos de unidades
        if ($storyType && $imovel->fotosUnidades) {
            $fotosFiltradas = $imovel->fotosUnidades->where('categorias', $storyType);
            $imagens = $imagens->concat($fotosFiltradas->pluck('fotos_url'));
        }

        // Fallback para imagens gerais se não encontrou por categoria
        if ($imagens->isEmpty()) {
            if ($imovel->imagensArquivos) {
                $imagens = $imagens->concat($imovel->imagensArquivos->pluck('foto_url'));
            }
            if ($imovel->fotosUnidades) {
                $imagens = $imagens->concat($imovel->fotosUnidades->pluck('fotos_url'));
            }
        }

        return response()->json([
            'success' => true,
            'data' => [
                'id' => 1,
                'titulo' => ucfirst($storyType),
                'tipo' => $storyType,
                'imagens' => $imagens->filter()->unique()->values()->toArray()
            ]
        ]);
    }

    private function formatImovelBasic($item)
    {
        // Pega primeira imagem: prioriza imagem_empreendimento, depois fotos das unidades ou imagens arquivo
        $primeiraImagem = $item->imagem_empreendimento ??
            $item->fotosUnidades->first()->fotos_url ??
            $item->imagensArquivos->first()->foto_url ??
            'https://via.placeholder.com/400x300';

        // Obter estatísticas das unidades
        $stats = $item->statistics;

        // Calcular valores reais das unidades
        $unidades = $item->unidades;
        $unidadesDisponiveis = $unidades->where('status_unidades_id', 1);
        $colecaoParaMedias = $unidadesDisponiveis->isNotEmpty() ? $unidadesDisponiveis : $unidades;

        $avgDormitorios = $colecaoParaMedias->avg('numero_quartos') ?: 0;
        $avgBanheiros = $colecaoParaMedias->avg('numero_banheiros') ?: 0;
        $avgSuites = $colecaoParaMedias->avg('numero_suites') ?: 0;
        $avgArea = $colecaoParaMedias->avg('tamanho_unidade_metros_quadrados') ?: 0;
        $avgAreaComum = $colecaoParaMedias->avg('tamanho_total_comum_unidade_metros_quadrados') ?: 0;

        $areaComumValor = $this->resolveAreaValue(
            $item->tamanho_total_comum_unidade_metros_quadrados,
            $avgAreaComum
        );

        $areaTotalValor = $this->resolveAreaValue(
            $item->area_total,
            $avgArea
        );

        $avgValorM2 = $avgArea > 0 && $stats['valorMedio'] > 0 ? $stats['valorMedio'] / $avgArea : 0;

        return [
            'id' => $item->id,
            'codigo' => $item->codigo ?? 'EMO' . str_pad($item->id, 3, '0', STR_PAD_LEFT),
            'nome' => $item->nome,
            'imagem' => $primeiraImagem,
            'localizacao' => $this->formatLocalizacao($item->endereco),
            'data' => $item->created_at->format('Y-m-d'),
            'corretor' => 'Valeincorp',
            'cidade' => $item->endereco->cidade ?? 'N/A',
            'endereco' => $this->formatEnderecoCompleto($item->endereco),
            'status' => $item->status->nome ?? 'N/A',
            'preco' => $stats['valorMedio'],
            'precoFormatado' => 'R$ ' . number_format($stats['valorMedio'], 2, ',', '.'),
            'dormitorios' => round($avgDormitorios),
            'banheiros' => round($avgBanheiros),
            'suites' => round($avgSuites),
            'suitesMaster' => 0,
            'vagas' => 0, // TODO: calcular das vagas de garagem
            'area' => round($avgArea, 2),
            'areaComum' => $areaComumValor,
            'areaTotal' => $areaTotalValor,
            'unidadesDisponiveis' => $stats['unidadesDisponiveis'],
            'totalUnidades' => $stats['totalUnidades'],
            'unidadesVendidas' => $stats['unidadesVendidas'],
            'percentualVendido' => $stats['percentualVendido'],
            'statusVenda' => $this->getStatusVenda($stats['percentualVendido']),
            'valorM2' => round($avgValorM2, 2),
            'coordenadas' => [
                'latitude' => $item->endereco->latitude ?? -23.5505,
                'longitude' => $item->endereco->longitude ?? -46.6333
            ],
            'dataEntrega' => $item->data_entrega,
            'area_lazer' => (bool) $item->area_lazer,
            'createdAt' => $item->created_at->toISOString(),
            'updatedAt' => $item->updated_at->toISOString(),
        ];
    }

    private function formatImovelDetailed($item)
    {
        $basic = $this->formatImovelBasic($item);

        // Combina todas as imagens (imagem_empreendimento + arquivo + unidades)
        $todasImagens = collect();

        // Adiciona imagem_empreendimento como primeira imagem se existir
        if ($item->imagem_empreendimento) {
            $todasImagens->push($item->imagem_empreendimento);
        }

        // Adiciona imagens dos arquivos
        if ($item->imagensArquivos) {
            $todasImagens = $todasImagens->concat($item->imagensArquivos->pluck('foto_url'));
        }

        // Adiciona fotos das unidades
        if ($item->fotosUnidades) {
            $todasImagens = $todasImagens->concat($item->fotosUnidades->pluck('fotos_url'));
        }

        // Adiciona fotos das torres (fotos adicionadas diretamente nas torres)
        if ($item->torres) {
            foreach ($item->torres as $torre) {
                if ($torre->fotosUnidades) {
                    $todasImagens = $todasImagens->concat($torre->fotosUnidades->pluck('fotos_url'));
                }
            }
        }

        // Busca vídeos das torres
        $videos = collect();
        if ($item->torres) {
            foreach ($item->torres as $torre) {
                if ($torre->videosUnidades) {
                    $videos = $videos->concat($torre->videosUnidades);
                }
            }
        }

        // Pega o primeiro vídeo (prioriza video_url, depois video_path)
        $primeiroVideo = null;
        if ($videos->isNotEmpty()) {
            $video = $videos->first();
            $primeiroVideo = $video->video_url ?? $video->video_path ?? $video->videos_url ?? null;
        }

        return array_merge($basic, [
            'descricao' => $item->observacoes ?? 'Excelente empreendimento com infraestrutura completa.',
            'imagens' => $todasImagens->filter()->unique()->values()->toArray(),
            'endereco' => $this->formatEnderecoCompleto($item->endereco),
            'videoUrl' => $primeiroVideo,
            'videos' => $videos->map(function($video) {
                return [
                    'id' => $video->id,
                    'url' => $video->video_url ?? $video->video_path ?? $video->videos_url ?? null,
                    'categoria' => $video->categoria ?? 'geral',
                    'original_name' => $video->original_name ?? null,
                ];
            })->filter(function($video) {
                return !empty($video['url']);
            })->values()->toArray(),
            'documentos' => $this->formatDocumentos($item->documentos),
            'diferenciais' => $this->getDiferenciais($item),
            'andamentoObra' => $this->getAndamentoObra($item),
            'stories' => $this->getStories($item),
            'pontosReferencia' => $this->getPontosReferencia(),
            'transporte' => $this->getTransporte(),
            'espelhoVendas' => $this->getEspelhoVendas($item),
        ]);
    }

    private function formatLocalizacao($endereco)
    {
        if (!$endereco) return 'N/A';
        return ($endereco->bairro ?? 'Centro') . ' - ' . ($endereco->cidade ?? 'N/A');
    }

    private function formatEnderecoCompleto($endereco)
    {
        if (!$endereco) {
            return [
                'logradouro' => null,
                'rua' => null,
                'numero' => null,
                'bairro' => null,
                'cidade' => null,
                'estado' => null,
                'cep' => null,
                'complemento' => null,
            ];
        }

        return [
            'logradouro' => trim(($endereco->rua ?? '') . ', ' . ($endereco->numero ?? '')),
            'rua' => $endereco->rua,
            'numero' => $endereco->numero,
            'bairro' => $endereco->bairro,
            'cidade' => $endereco->cidade,
            'estado' => $endereco->estado,
            'cep' => $endereco->cep,
            'complemento' => $endereco->complemento,
        ];
    }

    private function getStatusEmpreendimento($item)
    {
        $stats = $item->statistics;
        return $this->getStatusEmpreendimentoFromStats($stats);
    }

    private function resolveAreaValue($value, float $fallback): float
    {
        if ($value === null) {
            return round($fallback, 2);
        }

        if (is_numeric($value)) {
            return round((float) $value, 2);
        }

        $stringValue = (string) $value;
        $stringValue = str_ireplace('m²', '', $stringValue);
        $stringValue = trim($stringValue);
        $stringValue = preg_replace('/[^0-9.,-]/', '', $stringValue);

        if ($stringValue === '' || $stringValue === null) {
            return round($fallback, 2);
        }

        if (str_contains($stringValue, ',')) {
            $stringValue = str_replace('.', '', $stringValue);
            $stringValue = str_replace(',', '.', $stringValue);
        } else {
            $parts = explode('.', $stringValue);
            if (count($parts) > 2) {
                $decimal = array_pop($parts);
                $stringValue = implode('', $parts) . '.' . $decimal;
            }
        }

        if (!is_numeric($stringValue)) {
            return round($fallback, 2);
        }

        return round((float) $stringValue, 2);
    }

    private function getDiferenciais($item)
    {
        return $item->areasLazer->map(function ($area) {
            return [
                'id' => $area->id,
                'nome' => $area->tipo->nome ?? 'Área de Lazer',
                'icone' => 'star'
            ];
        })->toArray();
    }

    private function getAndamentoObra($item)
    {
        // Mock - usar os dados reais de EvolucaoObra
        if ($item->evolucao) {
            return collect($item->evolucao)->map(function ($evolucao) {
                $evolucaoObj = \App\Models\EvolucaoObra::find($evolucao['id']);
                return [
                    'nome' => $evolucaoObj->nome ?? 'Etapa',
                    'progresso' => $evolucao['percentual_conclusao']
                ];
            })->toArray();
        }

        return [];
    }

    private function getStories($item)
    {
        $stories = [];

        // Coleta todas as fotos (do empreendimento + das torres)
        $todasFotos = collect($item->fotosUnidades);

        if ($item->torres) {
            foreach ($item->torres as $torre) {
                if ($torre->fotosUnidades) {
                    $todasFotos = $todasFotos->concat($torre->fotosUnidades);
                }
            }
        }

        // Evitar duplicidades quando a relação hasManyThrough já inclui fotos das torres
        $todasFotos = $todasFotos->unique('id')->values();

        // Agrupa por categoriaFoto (novo sistema)
        $fotosPorCategoria = $todasFotos->filter(function($foto) {
            return $foto->categoriaFoto !== null;
        })->groupBy('categoria_foto_id');

        $index = 1;
        foreach ($fotosPorCategoria as $categoriaId => $fotos) {
            $categoria = $fotos->first()->categoriaFoto;
            if ($categoria) {
                $imagensDaCategoria = $fotos->map(function($foto) {
                    return [
                        'fotos_url' => $foto->fotos_url,
                        'legenda' => $foto->legenda
                    ];
                })->filter(function($foto) {
                    return !empty($foto['fotos_url']);
                })->values()->toArray();

                if (!empty($imagensDaCategoria)) {
                    $stories[] = [
                        'id' => $index++,
                        'titulo' => $categoria->nome,
                        'tipo' => $categoria->codigo,
                        'imagens' => $imagensDaCategoria
                    ];
                }
            }
        }

        // Adiciona fotos antigas sem categoria (campo 'categorias' preenchido mas sem categoria_foto_id)
        $categoriasAntigas = $todasFotos
            ->filter(function($foto) {
                return $foto->categorias !== null && $foto->categoria_foto_id === null;
            })
            ->pluck('categorias')
            ->unique()
            ->filter();

        foreach ($categoriasAntigas as $categoriaAntiga) {
            $imagensDaCategoria = $todasFotos
                ->where('categorias', $categoriaAntiga)
                ->whereNull('categoria_foto_id')
                ->map(function($foto) {
                    return [
                        'fotos_url' => $foto->fotos_url,
                        'legenda' => $foto->legenda
                    ];
                })
                ->filter(function($foto) {
                    return !empty($foto['fotos_url']);
                })
                ->values()
                ->toArray();

            if (!empty($imagensDaCategoria)) {
                $stories[] = [
                    'id' => $index++,
                    'titulo' => ucfirst($categoriaAntiga),
                    'tipo' => $categoriaAntiga,
                    'imagens' => $imagensDaCategoria
                ];
            }
        }

        // Fallback se não tiver stories por categoria - mostra todas as fotos
        if (empty($stories)) {
            $todasImagens = $todasFotos->map(function($foto) {
                return [
                    'fotos_url' => $foto->fotos_url,
                    'legenda' => $foto->legenda
                ];
            })->filter(function($foto) {
                return !empty($foto['fotos_url']);
            })->values()->toArray();

            if (!empty($todasImagens)) {
                $stories[] = [
                    'id' => 1,
                    'titulo' => 'Fotos',
                    'tipo' => 'geral',
                    'imagens' => $todasImagens
                ];
            }
        }

        return $stories;
    }

    private function getPontosReferencia()
    {
        return [
            ['nome' => 'Shopping Center', 'distancia' => '2,5 km'],
            ['nome' => 'Hospital Regional', 'distancia' => '3,2 km'],
            ['nome' => 'Universidade', 'distancia' => '4,1 km'],
            ['nome' => 'Aeroporto', 'distancia' => '15 km'],
        ];
    }

    private function getTransporte()
    {
        return [
            ['nome' => 'Ponto de ônibus', 'distancia' => '200m'],
            ['nome' => 'Estação de trem', 'distancia' => '5 km'],
            ['nome' => 'Acesso à BR-116', 'distancia' => '8 km'],
            ['nome' => 'Centro da cidade', 'distancia' => '12 km'],
        ];
    }

    private function getStatusEmpreendimentoFromStats($stats)
    {
        $percentual = $stats['percentualVendido'];

        if ($percentual >= 100) {
            return '100% Vendido';
        } elseif ($percentual >= 90) {
            return 'Últimas Unidades';
        } elseif ($percentual >= 50) {
            return 'Em Comercialização';
        } elseif ($percentual > 0) {
            return 'Lançamento';
        } else {
            return 'Em Breve';
        }
    }

    private function getStatusVenda($percentual)
    {
        if ($percentual >= 100) {
            return 'esgotado';
        } elseif ($percentual >= 90) {
            return 'ultimas_unidades';
        } elseif ($percentual >= 70) {
            return 'alta_procura';
        } elseif ($percentual >= 30) {
            return 'vendendo_bem';
        } elseif ($percentual > 0) {
            return 'lancamento';
        } else {
            return 'disponivel';
        }
    }

    private function getEspelhoVendas($item)
    {
        $espelho = [
            'resumo' => [
                'totalUnidades' => 0,
                'unidadesVendidas' => 0,
                'unidadesReservadas' => 0,
                'unidadesDisponiveis' => 0,
                'percentualVendido' => 0,
                'percentualReservado' => 0,
                'percentualDisponivel' => 0,
                'valorTotalVendido' => 0,
                'valorMedioVenda' => 0,
                'ticketMedio' => 0
            ],
            'torres' => []
        ];

        $totalUnidadesGeral = 0;
        $unidadesVendidasGeral = 0;
        $unidadesReservadasGeral = 0;
        $unidadesDisponiveisGeral = 0;
        $valorTotalVendido = 0;

        foreach ($item->torres as $torre) {
            $unidadesTorre = $torre->unidades;

            $totalUnidades = $unidadesTorre->count();
            $unidadesVendidas = $unidadesTorre->where('status_unidades_id', 3)->count(); // Vendida
            $unidadesReservadas = $unidadesTorre->where('status_unidades_id', 2)->count(); // Reservada
            $unidadesDisponiveis = $unidadesTorre->where('status_unidades_id', 1)->count(); // Disponível

            $valorVendidoTorre = $unidadesTorre->where('status_unidades_id', 3)->sum('valor');
            $valorMedioTorre = $unidadesTorre->where('status_unidades_id', 3)->avg('valor') ?: 0;

            $totalUnidadesGeral += $totalUnidades;
            $unidadesVendidasGeral += $unidadesVendidas;
            $unidadesReservadasGeral += $unidadesReservadas;
            $unidadesDisponiveisGeral += $unidadesDisponiveis;
            $valorTotalVendido += $valorVendidoTorre;

            $andares = [];
            $unidadesPorAndar = $unidadesTorre->groupBy('numero_andar_apartamento');

            foreach ($unidadesPorAndar as $andar => $unidadesAndar) {
                $unidadesAndarArray = [];

                foreach ($unidadesAndar as $unidade) {
                    $statusNome = 'disponivel';
                    $statusLabel = 'Disponível';

                    if ($unidade->status_unidades_id == 3) {
                        $statusNome = 'vendida';
                        $statusLabel = 'Vendida';
                    } elseif ($unidade->status_unidades_id == 2) {
                        $statusNome = 'reservada';
                        $statusLabel = 'Reservada';
                    }

                    $unidadesAndarArray[] = [
                        'id' => $unidade->id,
                        'numero' => $unidade->numero_apartamento,
                        'andar' => $unidade->numero_andar_apartamento,
                        'area' => $unidade->tamanho_unidade_metros_quadrados,
                        'quartos' => $unidade->numero_quartos,
                        'suites' => $unidade->numero_suites,
                        'banheiros' => $unidade->numero_banheiros,
                        'valor' => $unidade->valor,
                        'valorFormatado' => 'R$ ' . number_format($unidade->valor, 2, ',', '.'),
                        'valorM2' => $unidade->tamanho_unidade_metros_quadrados > 0 ?
                            round($unidade->valor / $unidade->tamanho_unidade_metros_quadrados, 2) : 0,
                        'status' => $statusNome,
                        'statusLabel' => $statusLabel,
                        'statusId' => $unidade->status_unidades_id,
                        'observacao' => $unidade->observacao,
                        'posicao' => $this->getPosicaoUnidade($unidade->numero_apartamento),
                        'vistaEspecial' => $this->hasVistaEspecial($unidade),
                        'solManha' => $this->getSolManha($unidade->numero_apartamento),
                        'solTarde' => $this->getSolTarde($unidade->numero_apartamento)
                    ];
                }

                $andares[] = [
                    'andar' => $andar,
                    'totalUnidades' => count($unidadesAndar),
                    'unidadesVendidas' => $unidadesAndar->where('status_unidades_id', 3)->count(),
                    'unidadesReservadas' => $unidadesAndar->where('status_unidades_id', 2)->count(),
                    'unidadesDisponiveis' => $unidadesAndar->where('status_unidades_id', 1)->count(),
                    'unidades' => $unidadesAndarArray
                ];
            }

            $espelho['torres'][] = [
                'id' => $torre->id,
                'nome' => $torre->nome ?? 'Torre ' . ($torre->id),
                'totalAndares' => $torre->numero_andares ?? $unidadesPorAndar->keys()->max(),
                'unidadesPorAndar' => $torre->numero_apartamento_andar ?? 4,
                'resumo' => [
                    'totalUnidades' => $totalUnidades,
                    'unidadesVendidas' => $unidadesVendidas,
                    'unidadesReservadas' => $unidadesReservadas,
                    'unidadesDisponiveis' => $unidadesDisponiveis,
                    'percentualVendido' => $totalUnidades > 0 ? round(($unidadesVendidas / $totalUnidades) * 100, 1) : 0,
                    'percentualReservado' => $totalUnidades > 0 ? round(($unidadesReservadas / $totalUnidades) * 100, 1) : 0,
                    'percentualDisponivel' => $totalUnidades > 0 ? round(($unidadesDisponiveis / $totalUnidades) * 100, 1) : 0,
                    'valorTotalVendido' => $valorVendidoTorre,
                    'valorMedioVenda' => round($valorMedioTorre, 2)
                ],
                'andares' => $andares
            ];
        }

        // Atualiza resumo geral
        $espelho['resumo'] = [
            'totalUnidades' => $totalUnidadesGeral,
            'unidadesVendidas' => $unidadesVendidasGeral,
            'unidadesReservadas' => $unidadesReservadasGeral,
            'unidadesDisponiveis' => $unidadesDisponiveisGeral,
            'percentualVendido' => $totalUnidadesGeral > 0 ? round(($unidadesVendidasGeral / $totalUnidadesGeral) * 100, 1) : 0,
            'percentualReservado' => $totalUnidadesGeral > 0 ? round(($unidadesReservadasGeral / $totalUnidadesGeral) * 100, 1) : 0,
            'percentualDisponivel' => $totalUnidadesGeral > 0 ? round(($unidadesDisponiveisGeral / $totalUnidadesGeral) * 100, 1) : 0,
            'valorTotalVendido' => $valorTotalVendido,
            'valorMedioVenda' => $unidadesVendidasGeral > 0 ? round($valorTotalVendido / $unidadesVendidasGeral, 2) : 0,
            'ticketMedio' => $unidadesVendidasGeral > 0 ? round($valorTotalVendido / $unidadesVendidasGeral, 2) : 0
        ];

        // Adiciona informações de evolução de vendas
        $espelho['evolucaoVendas'] = $this->getEvolucaoVendas($item);

        return $espelho;
    }

    private function getPosicaoUnidade($numeroApartamento)
    {
        // Determina posição baseada no número do apartamento (01-04 tipicamente)
        $finalApto = substr($numeroApartamento, -2);
        $numero = intval($finalApto);

        if ($numero <= 2) {
            return 'frente';
        } else {
            return 'fundos';
        }
    }

    private function hasVistaEspecial($unidade)
    {
        // Lógica para determinar se tem vista especial
        // Andares mais altos geralmente têm vista melhor
        return $unidade->numero_andar_apartamento >= 10;
    }

    private function getSolManha($numeroApartamento)
    {
        // Determina se pega sol da manhã baseado na posição
        $finalApto = substr($numeroApartamento, -2);
        $numero = intval($finalApto);

        return in_array($numero, [1, 2]);
    }

    private function getSolTarde($numeroApartamento)
    {
        // Determina se pega sol da tarde baseado na posição
        $finalApto = substr($numeroApartamento, -2);
        $numero = intval($finalApto);

        return in_array($numero, [3, 4]);
    }

    private function getEvolucaoVendas($item)
    {
        // Mock de evolução de vendas mensal
        // Em produção, isso viria de uma tabela de histórico de vendas
        return [
            'ultimosMeses' => [
                ['mes' => 'Janeiro', 'vendas' => 5, 'valor' => 2500000],
                ['mes' => 'Fevereiro', 'vendas' => 8, 'valor' => 4000000],
                ['mes' => 'Março', 'vendas' => 12, 'valor' => 6000000],
                ['mes' => 'Abril', 'vendas' => 7, 'valor' => 3500000],
                ['mes' => 'Maio', 'vendas' => 10, 'valor' => 5000000],
                ['mes' => 'Junho', 'vendas' => 15, 'valor' => 7500000]
            ],
            'velocidadeVenda' => [
                'mediaUltimos3Meses' => 10.67,
                'mediaUltimos6Meses' => 9.5,
                'tendencia' => 'crescente'
            ],
            'previsaoEsgotamento' => [
                'mesesRestantes' => 8,
                'dataEstimada' => '2025-04-30'
            ]
        ];
    }

    private function formatDocumentos($documentos)
    {
        if (!$documentos || $documentos->isEmpty()) {
            return [];
        }

        return $documentos->map(function($documento) {
            return [
                'id' => $documento->id,
                'arquivo_url' => $documento->arquivo_url,
                'nome_original' => $documento->nome_original,
                'tipo_mime' => $documento->tipo_mime,
                'tamanho_bytes' => $documento->tamanho_bytes,
                'tipo_documento' => $documento->tipoDocumento ? [
                    'id' => $documento->tipoDocumento->id,
                    'nome' => $documento->tipoDocumento->nome,
                    'tipo_arquivo' => $documento->tipoDocumento->tipo_arquivo,
                    'obrigatorio' => $documento->tipoDocumento->obrigatorio,
                    'ordem' => $documento->tipoDocumento->ordem ?? 999,
                ] : null,
            ];
        })->sortBy(function($doc) {
            return $doc['tipo_documento']['ordem'] ?? 999;
        })->values()->toArray();
    }
}
