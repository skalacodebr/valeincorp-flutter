<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\Empreendimento;
use App\Models\EvolucaoObra;
use App\Traits\FileUploadTrait;
use Illuminate\Http\Request;

class EmpreendimentoController extends Controller
{
    use FileUploadTrait;

    public function store(Request $request)
    {
        $validated = $request->validate([
            'nome' => 'required|string|max:255',
            'tipo_empreendimento_id' => 'nullable|integer',
            'tipo_unidades_id' => 'nullable|integer',
            'numero_total_unidade' => 'nullable|integer',
            'tamanho_total_comum_unidade_metros_quadrados' => 'nullable|numeric',
            'area_lazer' => 'boolean',
            'area_total' => 'nullable|numeric',
            'observacoes' => 'nullable|string',
            'empreendimentos_status_id' => 'nullable|integer',
            'data_entrega' => ['nullable', 'string', 'size:5', 'regex:/^(0[1-9]|1[0-2])-[0-9]{2}$/'],
            'equipe_usuarios_id' => 'nullable|integer',
            'evolucoes' => 'nullable|string',
            'imagem_empreendimento' => 'nullable|image|mimes:jpeg,png,jpg,gif,svg|max:40240',
        ]);

        // Processar evoluções
        $evolucoes = [];
        if ($request->has('evolucoes') && !empty($request->evolucoes)) {
            $evolucoesParsed = json_decode($request->evolucoes, true);
            
            if (json_last_error() === JSON_ERROR_NONE && is_array($evolucoesParsed)) {
                $evolucoes = $this->validateEvolucoes($evolucoesParsed);
            }
        }

        // Upload de imagem do empreendimento
        if ($request->hasFile('imagem_empreendimento')) {
            $file = $request->file('imagem_empreendimento');
            $fileName = 'empreendimento_' . uniqid() . '.' . $file->getClientOriginalExtension();
            $filePath = 'empreendimentos/' . $fileName;
            $disk = \App\Helpers\StorageHelper::getStorageDisk();
            $file->storeAs('empreendimentos', $fileName, $disk);
            $validated['imagem_empreendimento'] = \App\Helpers\StorageHelper::getPublicUrl($filePath);
        }

        // Upload tradicional de memorial descritivo (PDF)
        if ($request->hasFile('memorial_descritivo')) {
            $file = $request->file('memorial_descritivo');
            $fileName = 'memorial_' . uniqid() . '.' . $file->getClientOriginalExtension();
            $filePath = 'documentos/' . $fileName;
            $disk = \App\Helpers\StorageHelper::getStorageDisk();
            $file->storeAs('documentos', $fileName, $disk);
            $validated['memorial_descritivo_url'] = \App\Helpers\StorageHelper::getPublicUrl($filePath);
        } else if ($request->filled('memorial_descritivo_base64') && preg_match('/^data:([^;]+);base64,/', $request->memorial_descritivo_base64)) {
            // Compatibilidade: ainda aceita base64
            $uploadResult = $this->processBase64Upload(
                $request->memorial_descritivo_base64,
                'documentos',
                'memorial_'
            );
            if ($uploadResult) {
                $validated['memorial_descritivo_url'] = $uploadResult['file_url'];
            }
        }

        // Upload tradicional de catálogo (PDF)
        if ($request->hasFile('catalogo_pdf')) {
            $file = $request->file('catalogo_pdf');
            $fileName = 'catalogo_' . uniqid() . '.' . $file->getClientOriginalExtension();
            $filePath = 'documentos/' . $fileName;
            $disk = \App\Helpers\StorageHelper::getStorageDisk();
            $file->storeAs('documentos', $fileName, $disk);
            $validated['catalogo_pdf_url'] = \App\Helpers\StorageHelper::getPublicUrl($filePath);
        } else if ($request->filled('catalogo_pdf_base64') && preg_match('/^data:([^;]+);base64,/', $request->catalogo_pdf_base64)) {
            // Compatibilidade: ainda aceita base64
            $uploadResult = $this->processBase64Upload(
                $request->catalogo_pdf_base64,
                'documentos',
                'catalogo_'
            );
            if ($uploadResult) {
                $validated['catalogo_pdf_url'] = $uploadResult['file_url'];
            }
        }

        $validated['evolucao'] = $evolucoes;
        
        $empreendimento = Empreendimento::create($validated);

        return response()->json([
            'message' => 'Empreendimento criado com sucesso',
            'data' => $empreendimento->load('endereco'),
            'evolucoes' => $empreendimento->evolucaoCompleta,
        ], 201);
    }

    public function update(Request $request, $id)
    {
        $empreendimento = Empreendimento::findOrFail($id);

        $validated = $request->validate([
            'nome' => 'nullable|string|max:255',
            'tipo_empreendimento_id' => 'nullable|integer',
            'tipo_unidades_id' => 'nullable|integer',
            'numero_total_unidade' => 'nullable|integer',
            'tamanho_total_comum_unidade_metros_quadrados' => 'nullable|numeric',
            'area_lazer' => 'boolean',
            'area_total' => 'nullable|numeric',
            'observacoes' => 'nullable|string',
            'empreendimentos_status_id' => 'nullable|integer',
            'data_entrega' => ['nullable', 'string', 'size:5', 'regex:/^(0[1-9]|1[0-2])-[0-9]{2}$/'],
            'equipe_usuarios_id' => 'nullable|integer',
            'evolucoes' => 'nullable|string',
            'imagem_empreendimento' => 'nullable|image|mimes:jpeg,png,jpg,gif,svg|max:40240',
        ]);

        // Processar evoluções se fornecidas
        if ($request->has('evolucoes')) {
            if (empty($request->evolucoes)) {
                $validated['evolucao'] = [];
            } else {
                $evolucoesParsed = json_decode($request->evolucoes, true);
                if (json_last_error() === JSON_ERROR_NONE && is_array($evolucoesParsed)) {
                    $validated['evolucao'] = $this->validateEvolucoes($evolucoesParsed);
                }
            }
        }

        // Upload de imagem do empreendimento
        if ($request->hasFile('imagem_empreendimento')) {
            // Deletar imagem anterior se existir
            if ($empreendimento->imagem_empreendimento) {
                $oldFilePath = \App\Helpers\StorageHelper::getFilePathFromUrl($empreendimento->imagem_empreendimento);
                if ($oldFilePath) {
                    $this->deleteFile($oldFilePath);
                }
            }
            
            $file = $request->file('imagem_empreendimento');
            $fileName = 'empreendimento_' . uniqid() . '.' . $file->getClientOriginalExtension();
            $filePath = 'empreendimentos/' . $fileName;
            $disk = \App\Helpers\StorageHelper::getStorageDisk();
            $file->storeAs('empreendimentos', $fileName, $disk);
            $validated['imagem_empreendimento'] = \App\Helpers\StorageHelper::getPublicUrl($filePath);
        }

        // Upload tradicional de memorial descritivo (PDF)
        if ($request->hasFile('memorial_descritivo')) {
            $file = $request->file('memorial_descritivo');
            $fileName = 'memorial_' . uniqid() . '.' . $file->getClientOriginalExtension();
            $filePath = 'documentos/' . $fileName;
            $disk = \App\Helpers\StorageHelper::getStorageDisk();
            $file->storeAs('documentos', $fileName, $disk);
            $validated['memorial_descritivo_url'] = \App\Helpers\StorageHelper::getPublicUrl($filePath);
        } else if ($request->filled('memorial_descritivo_base64') && preg_match('/^data:([^;]+);base64,/', $request->memorial_descritivo_base64)) {
            // Compatibilidade: ainda aceita base64
            $uploadResult = $this->processBase64Upload(
                $request->memorial_descritivo_base64,
                'documentos',
                'memorial_'
            );
            if ($uploadResult) {
                $validated['memorial_descritivo_url'] = $uploadResult['file_url'];
            }
        }

        // Upload tradicional de catálogo (PDF)
        if ($request->hasFile('catalogo_pdf')) {
            $file = $request->file('catalogo_pdf');
            $fileName = 'catalogo_' . uniqid() . '.' . $file->getClientOriginalExtension();
            $filePath = 'documentos/' . $fileName;
            $disk = \App\Helpers\StorageHelper::getStorageDisk();
            $file->storeAs('documentos', $fileName, $disk);
            $validated['catalogo_pdf_url'] = \App\Helpers\StorageHelper::getPublicUrl($filePath);
        } else if ($request->filled('catalogo_pdf_base64') && preg_match('/^data:([^;]+);base64,/', $request->catalogo_pdf_base64)) {
            // Compatibilidade: ainda aceita base64
            $uploadResult = $this->processBase64Upload(
                $request->catalogo_pdf_base64,
                'documentos',
                'catalogo_'
            );
            if ($uploadResult) {
                $validated['catalogo_pdf_url'] = $uploadResult['file_url'];
            }
        }

        $empreendimento->update($validated);

        return response()->json([
            'message' => 'Empreendimento atualizado com sucesso',
            'data' => $empreendimento->fresh()->load('endereco'),
            'evolucoes' => $empreendimento->fresh()->evolucaoCompleta,
        ]);
    }

    public function destroy($id)
    {
        $empreendimento = Empreendimento::findOrFail($id);
        
        // Deleta os arquivos do storage se existirem
        if ($empreendimento->memorial_descritivo_url) {
            $filePath = \App\Helpers\StorageHelper::getFilePathFromUrl($empreendimento->memorial_descritivo_url);
            if ($filePath) {
                $this->deleteFile($filePath);
            }
        }
        
        if ($empreendimento->catalogo_pdf_url) {
            $filePath = \App\Helpers\StorageHelper::getFilePathFromUrl($empreendimento->catalogo_pdf_url);
            if ($filePath) {
                $this->deleteFile($filePath);
            }
        }
        
        // Deletar imagem do empreendimento se existir
        if ($empreendimento->imagem_empreendimento) {
            $filePath = \App\Helpers\StorageHelper::getFilePathFromUrl($empreendimento->imagem_empreendimento);
            if ($filePath) {
                $this->deleteFile($filePath);
            }
        }
        
        $empreendimento->delete();

        return response()->json(['message' => 'Empreendimento removido com sucesso.']);
    }

    public function getEvolucoes($id)
    {
        $empreendimento = Empreendimento::findOrFail($id);
        
        if (!$empreendimento->evolucao) {
            return response()->json(['data' => []]);
        }
        
        $evolucoes = $empreendimento->evolucaoCompleta;
        
        return response()->json([
            'data' => $evolucoes->map(function ($item) use ($id) {
                return [
                    'id' => $item['id'],
                    'nome' => $item['nome'],
                    'data_criacao' => $item['data_criacao'],
                    'percentual_conclusao' => $item['percentual_conclusao'],
                    'empreendimento_id' => $id,
                ];
            })
        ]);
    }

    private function validateEvolucoes(array $evolucoes): array
    {
        $validated = [];
        
        foreach ($evolucoes as $evolucao) {
            // Validar estrutura
            if (!isset($evolucao['id']) || !isset($evolucao['percentual_conclusao'])) {
                continue;
            }
            
            $id = (int) $evolucao['id'];
            $percentual = (float) $evolucao['percentual_conclusao'];
            
            // Validar se a evolução existe
            if (!EvolucaoObra::find($id)) {
                continue;
            }
            
            // Validar percentual (0-100)
            if ($percentual < 0 || $percentual > 100) {
                $percentual = max(0, min(100, $percentual));
            }
            
            $validated[] = [
                'id' => $id,
                'percentual_conclusao' => $percentual,
            ];
        }
        
        return $validated;
    }

    /**
     * Análise completa de exclusão - mostra tudo que será excluído
     */
    public function analyzeDelete($id)
    {
        $empreendimento = Empreendimento::findOrFail($id);
        
        // Coletar dados que serão excluídos
        $torres = $empreendimento->torres()->get();
        $totalTorres = $torres->count();
        
        $totalUnidades = 0;
        $totalFotosUnidades = 0;
        $totalVideosUnidades = 0;
        $totalVagasGaragem = 0;
        $unidadesDetalhes = [];
        
        foreach ($torres as $torre) {
            $unidades = $torre->unidades()->count();
            $fotos = $torre->fotosUnidades()->count();
            $videos = $torre->videosUnidades()->count();
            $vagas = $torre->vagasGaragem()->count();
            
            $totalUnidades += $unidades;
            $totalFotosUnidades += $fotos;
            $totalVideosUnidades += $videos;
            $totalVagasGaragem += $vagas;
            
            if ($unidades > 0 || $fotos > 0 || $videos > 0 || $vagas > 0) {
                $unidadesDetalhes[] = [
                    'torre' => $torre->nome,
                    'unidades' => $unidades,
                    'fotos' => $fotos,
                    'videos' => $videos,
                    'vagas_garagem' => $vagas
                ];
            }
        }
        
        // Verificar negociações vinculadas
        $negociacoes = \App\Models\Negociacao::where('empreendimentos_id', $id)->get();
        $negociacoesAtivas = $negociacoes->filter(function ($n) {
            return !$n->distratado && $n->negociacoes_status_id != 4; // 4 = Cancelada
        });
        
        $analise = [
            'empreendimento' => [
                'id' => $empreendimento->id,
                'nome' => $empreendimento->nome,
                'status' => $empreendimento->empreendimentos_status_id
            ],
            'itens_para_exclusao' => [
                'torres' => $totalTorres,
                'unidades' => $totalUnidades,
                'fotos_unidades' => $totalFotosUnidades,
                'videos_unidades' => $totalVideosUnidades,
                'vagas_garagem' => $totalVagasGaragem,
                'areas_lazer' => $empreendimento->areasLazer()->count(),
                'enderecos' => $empreendimento->endereco()->count(),
                'imagens_arquivos' => $empreendimento->imagensArquivos()->count(),
                'evolucoes_obra' => $empreendimento->evolucaoObras()->count(),
            ],
            'detalhes_por_torre' => $unidadesDetalhes,
            'arquivos_storage' => [
                'memorial_descritivo' => !empty($empreendimento->memorial_descritivo_url),
                'catalogo_pdf' => !empty($empreendimento->catalogo_pdf_url),
                'imagem_empreendimento' => !empty($empreendimento->imagem_empreendimento)
            ],
            'avisos' => [],
            'negociacoes' => [
                'total' => $negociacoes->count(),
                'ativas' => $negociacoesAtivas->count(),
                'distratadas' => $negociacoes->where('distratado', true)->count()
            ],
            'favoritos_info' => [
                'nota' => 'Favoritos NÃO serão excluídos conforme solicitado',
                'total' => \App\Models\Favorito::where('empreendimento_id', $id)->count()
            ],
            'pode_excluir' => $negociacoesAtivas->count() === 0
        ];
        
        // Adicionar avisos
        if ($negociacoesAtivas->count() > 0) {
            $analise['avisos'][] = "ATENÇÃO: Existem {$negociacoesAtivas->count()} negociações ativas vinculadas a este empreendimento";
        }
        
        if ($totalUnidades > 0) {
            $analise['avisos'][] = "Serão excluídas {$totalUnidades} unidades permanentemente";
        }
        
        return response()->json([
            'message' => 'Análise de exclusão completa',
            'analise' => $analise
        ]);
    }

    /**
     * Exclusão completa do empreendimento e todos os dados vinculados (exceto favoritos)
     */
    public function destroyComplete(Request $request, $id)
    {
        $empreendimento = Empreendimento::findOrFail($id);
        
        // Verificar se há negociações ativas
        $negociacoesAtivas = \App\Models\Negociacao::where('empreendimentos_id', $id)
            ->where('distratado', '!=', true)
            ->where('negociacoes_status_id', '!=', 4) // 4 = Cancelada
            ->count();
            
        if ($negociacoesAtivas > 0 && !$request->has('force')) {
            return response()->json([
                'error' => 'Não é possível excluir o empreendimento',
                'message' => "Existem {$negociacoesAtivas} negociações ativas. Use o parâmetro 'force=true' para forçar a exclusão.",
                'negociacoes_ativas' => $negociacoesAtivas
            ], 422);
        }
        
        // Iniciar transação para garantir consistência
        \DB::beginTransaction();
        
        try {
            $deletedItems = [
                'empreendimento' => $empreendimento->nome,
                'itens_excluidos' => []
            ];
            
            // 1. Deletar todas as torres e seus relacionamentos
            $torres = $empreendimento->torres()->get();
            foreach ($torres as $torre) {
                // Deletar fotos das unidades
                $fotosCount = $torre->fotosUnidades()->count();
                if ($fotosCount > 0) {
                    // Deletar arquivos físicos das fotos
                    $fotos = $torre->fotosUnidades()->get();
                    foreach ($fotos as $foto) {
                        if ($foto->foto_url) {
                            $filePath = \App\Helpers\StorageHelper::getFilePathFromUrl($foto->foto_url);
                            if ($filePath) {
                                $this->deleteFile($filePath);
                            }
                        }
                    }
                    $torre->fotosUnidades()->delete();
                    $deletedItems['itens_excluidos']['fotos_unidades'] = ($deletedItems['itens_excluidos']['fotos_unidades'] ?? 0) + $fotosCount;
                }
                
                // Deletar vídeos das unidades
                $videosCount = $torre->videosUnidades()->count();
                if ($videosCount > 0) {
                    // Deletar arquivos físicos dos vídeos
                    $videos = $torre->videosUnidades()->get();
                    foreach ($videos as $video) {
                        if ($video->video_url) {
                            $filePath = \App\Helpers\StorageHelper::getFilePathFromUrl($video->video_url);
                            if ($filePath) {
                                $this->deleteFile($filePath);
                            }
                        }
                    }
                    $torre->videosUnidades()->delete();
                    $deletedItems['itens_excluidos']['videos_unidades'] = ($deletedItems['itens_excluidos']['videos_unidades'] ?? 0) + $videosCount;
                }
                
                // Deletar vagas de garagem
                $vagasCount = $torre->vagasGaragem()->count();
                if ($vagasCount > 0) {
                    $torre->vagasGaragem()->delete();
                    $deletedItems['itens_excluidos']['vagas_garagem'] = ($deletedItems['itens_excluidos']['vagas_garagem'] ?? 0) + $vagasCount;
                }
                
                // Deletar unidades
                $unidadesCount = $torre->unidades()->count();
                if ($unidadesCount > 0) {
                    $torre->unidades()->delete();
                    $deletedItems['itens_excluidos']['unidades'] = ($deletedItems['itens_excluidos']['unidades'] ?? 0) + $unidadesCount;
                }
                
                // Deletar exceções da torre
                $torre->excessoes()->delete();
            }
            
            // Deletar as torres
            $torresCount = $torres->count();
            if ($torresCount > 0) {
                $empreendimento->torres()->delete();
                $deletedItems['itens_excluidos']['torres'] = $torresCount;
            }
            
            // 2. Deletar áreas de lazer
            $areasLazerCount = $empreendimento->areasLazer()->count();
            if ($areasLazerCount > 0) {
                $empreendimento->areasLazer()->delete();
                $deletedItems['itens_excluidos']['areas_lazer'] = $areasLazerCount;
            }
            
            // 3. Deletar endereço
            if ($empreendimento->endereco()->exists()) {
                $empreendimento->endereco()->delete();
                $deletedItems['itens_excluidos']['endereco'] = 1;
            }
            
            // 4. Deletar imagens e arquivos
            $imagensArquivos = $empreendimento->imagensArquivos()->get();
            foreach ($imagensArquivos as $item) {
                if ($item->foto_url) {
                    $filePath = \App\Helpers\StorageHelper::getFilePathFromUrl($item->foto_url);
                    if ($filePath) {
                        $this->deleteFile($filePath);
                    }
                }
                if ($item->arquivo_url) {
                    $filePath = \App\Helpers\StorageHelper::getFilePathFromUrl($item->arquivo_url);
                    if ($filePath) {
                        $this->deleteFile($filePath);
                    }
                }
            }
            if ($imagensArquivos->count() > 0) {
                $empreendimento->imagensArquivos()->delete();
                $deletedItems['itens_excluidos']['imagens_arquivos'] = $imagensArquivos->count();
            }
            
            // 5. Deletar evoluções da obra
            $evolucoesCount = $empreendimento->evolucaoObras()->count();
            if ($evolucoesCount > 0) {
                $empreendimento->evolucaoObras()->delete();
                $deletedItems['itens_excluidos']['evolucoes_obra'] = $evolucoesCount;
            }
            
            // 6. Deletar/atualizar negociações
            $negociacoes = \App\Models\Negociacao::where('empreendimentos_id', $id)->get();
            if ($negociacoes->count() > 0) {
                if ($request->has('force')) {
                    // Se forçar, marcar como distratadas
                    \App\Models\Negociacao::where('empreendimentos_id', $id)->update([
                        'distratado' => true,
                        'observacoes' => \DB::raw("CONCAT(COALESCE(observacoes, ''), ' | Empreendimento excluído em " . now()->format('d/m/Y H:i') . "')")
                    ]);
                    $deletedItems['itens_excluidos']['negociacoes_distratadas'] = $negociacoes->count();
                }
            }
            
            // 7. Deletar arquivos do storage principal
            if ($empreendimento->memorial_descritivo_url) {
                $filePath = \App\Helpers\StorageHelper::getFilePathFromUrl($empreendimento->memorial_descritivo_url);
                if ($filePath) {
                    $this->deleteFile($filePath);
                }
            }
            
            if ($empreendimento->catalogo_pdf_url) {
                $filePath = \App\Helpers\StorageHelper::getFilePathFromUrl($empreendimento->catalogo_pdf_url);
                if ($filePath) {
                    $this->deleteFile($filePath);
                }
            }
            
            if ($empreendimento->imagem_empreendimento) {
                $filePath = \App\Helpers\StorageHelper::getFilePathFromUrl($empreendimento->imagem_empreendimento);
                if ($filePath) {
                    $this->deleteFile($filePath);
                }
            }
            
            // 8. Finalmente, deletar o empreendimento
            $empreendimento->delete();
            
            // Commit da transação
            \DB::commit();
            
            return response()->json([
                'message' => 'Empreendimento e todos os dados vinculados foram excluídos com sucesso',
                'resultado' => $deletedItems,
                'nota_favoritos' => 'Favoritos NÃO foram excluídos conforme solicitado'
            ]);
            
        } catch (\Exception $e) {
            // Rollback em caso de erro
            \DB::rollback();
            
            return response()->json([
                'error' => 'Erro ao excluir empreendimento',
                'message' => $e->getMessage()
            ], 500);
        }
    }
} 