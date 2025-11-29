<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Helpers\StorageHelper;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;
use Illuminate\Support\Facades\Validator;

class FileUploadController extends Controller
{
    /**
     * Upload de arquivo para storage local
     */
    public function upload(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'file' => 'required|file|max:10240', // 10MB max
            'folder' => 'nullable|string|max:100', // pasta onde salvar (ex: diplomas, fotos, etc)
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Erro de validação',
                'errors' => $validator->errors()
            ], 422);
        }

        try {
            $file = $request->file('file');
            $folder = $request->input('folder', 'uploads');
            
            // Gera um nome único para o arquivo
            $fileName = Str::random(40) . '.' . $file->getClientOriginalExtension();
            
            // Cria o caminho completo
            $filePath = $folder . '/' . $fileName;
            
            // Salva o arquivo no storage apropriado
            $disk = StorageHelper::getStorageDisk();
            $path = Storage::disk($disk)->putFileAs($folder, $file, $fileName);
            
            if (!$path) {
                return response()->json([
                    'success' => false,
                    'message' => 'Erro ao salvar arquivo'
                ], 500);
            }
            
            // Retorna a URL pública do arquivo
            $url = StorageHelper::getPublicUrl($filePath);
            
            return response()->json([
                'success' => true,
                'message' => 'Arquivo enviado com sucesso',
                'data' => [
                    'file_path' => $filePath,
                    'file_url' => $url,
                    'original_name' => $file->getClientOriginalName(),
                    'file_size' => $file->getSize(),
                    'mime_type' => $file->getMimeType()
                ]
            ], 201);
            
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erro interno do servidor',
                'error' => $e->getMessage()
            ], 500);
        }
    }
    
    /**
     * Upload múltiplo de arquivos
     */
    public function uploadMultiple(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'files.*' => 'required|file|max:10240', // 10MB max por arquivo
            'folder' => 'nullable|string|max:100',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Erro de validação',
                'errors' => $validator->errors()
            ], 422);
        }

        try {
            $files = $request->file('files');
            $folder = $request->input('folder', 'uploads');
            $uploadedFiles = [];
            
            foreach ($files as $file) {
                // Gera um nome único para o arquivo
                $fileName = Str::random(40) . '.' . $file->getClientOriginalExtension();
                
                // Cria o caminho completo
                $filePath = $folder . '/' . $fileName;
                
                // Salva o arquivo no storage apropriado
                $disk = StorageHelper::getStorageDisk();
                $path = Storage::disk($disk)->putFileAs($folder, $file, $fileName);
                
                if ($path) {
                    $uploadedFiles[] = [
                        'file_path' => $filePath,
                        'file_url' => StorageHelper::getPublicUrl($filePath),
                        'original_name' => $file->getClientOriginalName(),
                        'file_size' => $file->getSize(),
                        'mime_type' => $file->getMimeType()
                    ];
                }
            }
            
            return response()->json([
                'success' => true,
                'message' => count($uploadedFiles) . ' arquivo(s) enviado(s) com sucesso',
                'data' => $uploadedFiles
            ], 201);
            
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erro interno do servidor',
                'error' => $e->getMessage()
            ], 500);
        }
    }
    
    /**
     * Deletar arquivo
     */
    public function delete(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'file_path' => 'required|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Erro de validação',
                'errors' => $validator->errors()
            ], 422);
        }

        try {
            $filePath = $request->input('file_path');
            
            if (Storage::disk('public')->exists($filePath)) {
                Storage::disk('public')->delete($filePath);
                
                return response()->json([
                    'success' => true,
                    'message' => 'Arquivo deletado com sucesso'
                ]);
            } else {
                return response()->json([
                    'success' => false,
                    'message' => 'Arquivo não encontrado'
                ], 404);
            }
            
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erro interno do servidor',
                'error' => $e->getMessage()
            ], 500);
        }
    }
} 