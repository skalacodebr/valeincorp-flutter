<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\Favorito;
use App\Models\Empreendimento;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Auth;
use Illuminate\Validation\ValidationException;

class FavoritoController extends Controller
{
    /**
     * Listar favoritos do usuário autenticado
     */
    public function index(Request $request): JsonResponse
    {
        $page = $request->get('page', 1);
        $limit = min($request->get('limit', 20), 100);

        $query = Favorito::doCorretor(Auth::id())
            ->with(['empreendimento.endereco', 'empreendimento.imagensArquivos', 'empreendimento.fotosUnidades', 'empreendimento.unidades', 'empreendimento.torres.excessoes', 'empreendimento.areasLazer'])
            ->orderBy('created_at', 'desc');

        $favoritos = $query->paginate($limit, ['*'], 'page', $page);

        return response()->json([
            'success' => true,
            'data' => $favoritos->map(function ($favorito) {
                return [
                    'id' => $favorito->id,
                    'imovelId' => $favorito->empreendimento->id,
                    'imovel' => $this->formatImovelForFavoritos($favorito->empreendimento),
                    'favoritadoEm' => $favorito->created_at->toISOString()
                ];
            }),
            'pagination' => [
                'currentPage' => $favoritos->currentPage(),
                'totalPages' => $favoritos->lastPage(),
                'totalItems' => $favoritos->total(),
                'itemsPerPage' => $favoritos->perPage(),
                'hasNextPage' => $favoritos->hasMorePages(),
                'hasPreviousPage' => $favoritos->currentPage() > 1,
            ]
        ]);
    }

    /**
     * Adicionar empreendimento aos favoritos
     */
    public function store(Request $request): JsonResponse
    {
        $request->validate([
            'imovelId' => 'required|integer|exists:empreendimentos,id'
        ]);

        $empreendimentoId = $request->imovelId;
        $corretorId = Auth::id();

        // Verificar se já é favorito
        if (Favorito::isFavorito($corretorId, $empreendimentoId)) {
            return response()->json([
                'success' => false,
                'message' => 'Este imóvel já está nos seus favoritos'
            ], 409);
        }

        // Adicionar aos favoritos
        $favorito = Favorito::adicionarFavorito($corretorId, $empreendimentoId);

        return response()->json([
            'success' => true,
            'message' => 'Imóvel adicionado aos favoritos com sucesso',
            'data' => [
                'id' => $favorito->id,
                'imovelId' => $empreendimentoId,
                'userId' => $corretorId,
                'favoritadoEm' => $favorito->created_at->toISOString()
            ]
        ], 201);
    }

    /**
     * Remover empreendimento dos favoritos
     */
    public function destroy($imovelId): JsonResponse
    {
        $corretorId = Auth::id();

        // Verificar se existe
        if (!Favorito::isFavorito($corretorId, $imovelId)) {
            return response()->json([
                'success' => false,
                'message' => 'Este imóvel não está nos seus favoritos'
            ], 404);
        }

        // Remover dos favoritos
        $removido = Favorito::removerFavorito($corretorId, $imovelId);

        if ($removido) {
            return response()->json([
                'success' => true,
                'message' => 'Imóvel removido dos favoritos com sucesso'
            ]);
        }

        return response()->json([
            'success' => false,
            'message' => 'Erro ao remover imóvel dos favoritos'
        ], 500);
    }

    /**
     * Verificar se um empreendimento é favorito
     */
    public function check($imovelId): JsonResponse
    {
        $isFavorito = Favorito::isFavorito(Auth::id(), $imovelId);

        return response()->json([
            'success' => true,
            'isFavorito' => $isFavorito,
            'data' => [
                'imovelId' => (int) $imovelId,
                'userId' => Auth::id(),
                'isFavorito' => $isFavorito
            ]
        ]);
    }

    /**
     * Contar total de favoritos
     */
    public function count(): JsonResponse
    {
        $total = Favorito::doCorretor(Auth::id())->count();

        return response()->json([
            'success' => true,
            'data' => [
                'totalFavoritos' => $total
            ]
        ]);
    }

    /**
     * Formatar localização
     */
    private function formatLocalizacao($endereco): string
    {
        if (!$endereco) return 'N/A';
        return ($endereco->bairro ?? 'Centro') . ' - ' . ($endereco->cidade ?? 'N/A');
    }

    /**
     * Formatar imóvel com todas as informações (igual ao ImovelController)
     */
    private function formatImovelForFavoritos($item)
    {
        // Pega primeira imagem das unidades ou imagens arquivo
        $primeiraImagem = $item->fotosUnidades->first()->fotos_url ?? 
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
        $avgValorM2 = $avgArea > 0 && $stats['valorMedio'] > 0 ? $stats['valorMedio'] / $avgArea : 0;

        return [
            'id' => $item->id,
            'codigo' => $item->codigo ?? 'EMO' . str_pad($item->id, 3, '0', STR_PAD_LEFT),
            'nome' => $item->nome,
            'imagem' => $primeiraImagem,
            'localizacao' => $this->formatLocalizacao($item->endereco),
            'data' => $item->created_at->format('Y-m-d'),
            'corretor' => 'Vale Incorp',
            'cidade' => $item->endereco->cidade ?? 'N/A',
            'status' => $this->getStatusEmpreendimentoFromStats($stats),
            'preco' => $stats['valorMedio'],
            'precoFormatado' => 'R$ ' . number_format($stats['valorMedio'], 2, ',', '.'),
            'dormitorios' => round($avgDormitorios),
            'banheiros' => round($avgBanheiros),
            'suites' => round($avgSuites),
            'suitesMaster' => 0,
            'vagas' => 0, // TODO: calcular das vagas de garagem
            'area' => round($avgArea, 2),
            'areaComum' => round($avgArea * 0.35, 2), // Estimativa: 35% da área total
            'areaTotal' => round($avgArea, 2),
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
            'createdAt' => $item->created_at->toISOString(),
            'updatedAt' => $item->updated_at->toISOString(),
        ];
    }

    /**
     * Status do empreendimento baseado nas estatísticas
     */
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

    /**
     * Status de venda baseado no percentual
     */
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
}
