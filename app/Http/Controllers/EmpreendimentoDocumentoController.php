<?php

namespace App\Http\Controllers;

use App\Models\EmpreendimentoDocumento;
use App\Models\TipoDocumento;
use App\Models\Empreendimento;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Str;
use Exception;

class EmpreendimentoDocumentoController extends Controller
{
    /**
     * Listar documentos de um empreendimento
     */
    public function index($empreendimentoId)
    {
        try {
            $empreendimento = Empreendimento::findOrFail($empreendimentoId);

            $documentos = EmpreendimentoDocumento::where('empreendimentos_id', $empreendimentoId)
                ->with('tipoDocumento')
                ->orderBy('created_at', 'asc')
                ->get();

            return response()->json([
                'data' => $documentos,
                'total' => $documentos->count()
            ], 200);
        } catch (Exception $e) {
            return response()->json([
                'message' => 'Erro ao buscar documentos',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Upload de documento para empreendimento
     */
    public function store(Request $request, $empreendimentoId)
    {
        try {
            \Log::info('=== UPLOAD DOCUMENTO ===');
            \Log::info('Empreendimento ID: ' . $empreendimentoId);
            \Log::info('Request data:', $request->all());
            \Log::info('Has file:', ['has_file' => $request->hasFile('arquivo')]);

            $empreendimento = Empreendimento::findOrFail($empreendimentoId);

            // Validação básica
            $validator = Validator::make($request->all(), [
                'tipos_documentos_id' => 'required|exists:tipos_documentos,id',
                'arquivo' => 'required|file|max:51200', // 50MB
            ], [
                'tipos_documentos_id.required' => 'O tipo de documento é obrigatório',
                'tipos_documentos_id.exists' => 'Tipo de documento inválido',
                'arquivo.required' => 'O arquivo é obrigatório',
                'arquivo.max' => 'O arquivo não pode ser maior que 50MB',
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'message' => 'Erro de validação',
                    'errors' => $validator->errors()
                ], 422);
            }

            // Buscar tipo de documento
            $tipoDocumento = TipoDocumento::findOrFail($request->tipos_documentos_id);

            if (!$tipoDocumento->ativo) {
                return response()->json([
                    'message' => 'Este tipo de documento está inativo'
                ], 422);
            }

            // Validar tipo de arquivo baseado no tipo_arquivo do TipoDocumento
            $arquivo = $request->file('arquivo');

            if ($tipoDocumento->tipo_arquivo === 'pdf') {
                if (!in_array($arquivo->getMimeType(), ['application/pdf'])) {
                    return response()->json([
                        'message' => 'Este tipo de documento aceita apenas arquivos PDF',
                        'tipo_esperado' => 'pdf',
                        'tipo_enviado' => $arquivo->getMimeType()
                    ], 422);
                }
            } else if ($tipoDocumento->tipo_arquivo === 'imagem') {
                if (!in_array($arquivo->getMimeType(), ['image/png', 'image/jpeg', 'image/jpg', 'image/webp'])) {
                    return response()->json([
                        'message' => 'Este tipo de documento aceita apenas imagens (PNG, JPG, JPEG, WEBP)',
                        'tipo_esperado' => 'imagem',
                        'tipo_enviado' => $arquivo->getMimeType()
                    ], 422);
                }
            }

            // Verificar se já existe documento deste tipo (para substituir)
            $documentoExistente = EmpreendimentoDocumento::where([
                'empreendimentos_id' => $empreendimentoId,
                'tipos_documentos_id' => $request->tipos_documentos_id,
            ])->first();

            if ($documentoExistente) {
                // Deletar arquivo antigo do storage
                $pathAntigo = str_replace('/storage/', '', parse_url($documentoExistente->arquivo_url, PHP_URL_PATH));
                if (Storage::disk('public')->exists($pathAntigo)) {
                    Storage::disk('public')->delete($pathAntigo);
                }
                // Deletar registro
                $documentoExistente->delete();
            }

            // Gerar nome único para o arquivo
            $extensao = $arquivo->getClientOriginalExtension();
            $nomeSlug = Str::slug($tipoDocumento->nome);
            $nomeSalvo = $nomeSlug . '_' . uniqid() . '.' . $extensao;

            // Salvar arquivo no storage
            $path = $arquivo->storeAs('documentos', $nomeSalvo, 'public');
            $url = Storage::url($path); // Gera /storage/documentos/nome_arquivo.ext

            // Criar registro na tabela empreendimentos_documentos
            $documento = EmpreendimentoDocumento::create([
                'empreendimentos_id' => $empreendimentoId,
                'tipos_documentos_id' => $request->tipos_documentos_id,
                'arquivo_url' => $url,
                'nome_original' => $arquivo->getClientOriginalName(),
                'nome_salvo' => $nomeSalvo,
                'tipo_mime' => $arquivo->getMimeType(),
                'tamanho_bytes' => $arquivo->getSize(),
            ]);

            // Retornar com relacionamento
            $documento->load('tipoDocumento');

            return response()->json([
                'message' => 'Documento enviado com sucesso',
                'data' => $documento
            ], 201);
        } catch (Exception $e) {
            return response()->json([
                'message' => 'Erro ao enviar documento',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Deletar documento específico
     */
    public function destroy($empreendimentoId, $documentoId)
    {
        try {
            $documento = EmpreendimentoDocumento::where([
                'id' => $documentoId,
                'empreendimentos_id' => $empreendimentoId,
            ])->firstOrFail();

            // Deletar arquivo do storage
            $path = str_replace('/storage/', '', parse_url($documento->arquivo_url, PHP_URL_PATH));
            if (Storage::disk('public')->exists($path)) {
                Storage::disk('public')->delete($path);
            }

            // Deletar registro
            $documento->delete();

            return response()->json([
                'message' => 'Documento removido com sucesso'
            ], 200);
        } catch (Exception $e) {
            return response()->json([
                'message' => 'Erro ao remover documento',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Download de documento
     */
    public function download($empreendimentoId, $documentoId)
    {
        try {
            $documento = EmpreendimentoDocumento::where([
                'id' => $documentoId,
                'empreendimentos_id' => $empreendimentoId,
            ])->firstOrFail();

            $path = str_replace('/storage/', '', parse_url($documento->arquivo_url, PHP_URL_PATH));

            if (!Storage::disk('public')->exists($path)) {
                return response()->json([
                    'message' => 'Arquivo não encontrado no servidor'
                ], 404);
            }

            return Storage::disk('public')->download($path, $documento->nome_original);
        } catch (Exception $e) {
            return response()->json([
                'message' => 'Erro ao baixar documento',
                'error' => $e->getMessage()
            ], 500);
        }
    }
}
