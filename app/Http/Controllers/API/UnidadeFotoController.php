<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Helpers\StorageHelper;
use App\Models\EmpreendimentoUnidadeFoto;
use App\Models\CategoriaFoto;
use App\Traits\FileUploadTrait;
use Illuminate\Http\Request;

class UnidadeFotoController extends Controller
{
    use FileUploadTrait;

    public function store(Request $request, $torre_id)
    {
        $validated = $request->validate([
            'fotos_url' => 'required|string',
            'categorias' => 'nullable|string', // Manter compatibilidade com sistema antigo
            'categoria_foto_id' => 'nullable|exists:categorias_fotos,id',
            'legenda' => 'nullable|string|max:255',
        ]);

        // Valida se é uma imagem válida (sem limite de tamanho)
        if (!$this->validateBase64ImageFile($validated['fotos_url'])) {
            return response()->json(['error' => 'Arquivo não é uma imagem válida.'], 400);
        }

        // Processa o upload base64 se for uma imagem
        $fotosUrl = $validated['fotos_url'];
        
        // Verifica se é base64
        if (preg_match('/^data:([^;]+);base64,/', $fotosUrl)) {
            // Processa o upload
            $uploadResult = $this->processBase64Upload(
                $fotosUrl, 
                'unidades', 
                'foto_'
            );
            
            if ($uploadResult) {
                $fotosUrl = $uploadResult['file_url'];
            }
        }

        // Determinar categoria_foto_id se foi enviado 'categorias' como string
        $categoriaFotoId = $validated['categoria_foto_id'] ?? null;

        if (!$categoriaFotoId && !empty($validated['categorias'])) {
            // Tentar mapear categoria antiga para nova estrutura
            $categoriaMap = [
                'interna' => 'interna',
                'planta baixa' => 'planta_baixa',
                'fotos das areas' => 'fotos_das_areas',
                'uso comum' => 'uso_comum',
                'implantação' => 'implantacao'
            ];

            $categoriaAntiga = strtolower(trim($validated['categorias']));
            if (isset($categoriaMap[$categoriaAntiga])) {
                $categoria = CategoriaFoto::where('codigo', $categoriaMap[$categoriaAntiga])->first();
                if ($categoria) {
                    $categoriaFotoId = $categoria->id;
                }
            }
        }

        $foto = EmpreendimentoUnidadeFoto::create([
            'empreendimentos_tores_id' => $torre_id,
            'fotos_url' => $fotosUrl,
            'categorias' => $validated['categorias'] ?? null, // Manter compatibilidade
            'categoria_foto_id' => $categoriaFotoId,
            'legenda' => $validated['legenda'] ?? null,
        ]);

        return response()->json($foto, 201);
    }

    public function destroy($id)
    {
        $foto = EmpreendimentoUnidadeFoto::findOrFail($id);
        
        // Deleta o arquivo do storage se existir
        $filePath = StorageHelper::getFilePathFromUrl($foto->fotos_url);
        if ($filePath) {
            $this->deleteFile($filePath);
        }
        
        $foto->delete();

        return response()->json(['message' => 'Foto removida com sucesso.']);
    }
} 