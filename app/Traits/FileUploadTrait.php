<?php

namespace App\Traits;

use App\Helpers\StorageHelper;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

trait FileUploadTrait
{
    /**
     * Processa upload de arquivo base64 e salva no storage
     */
    protected function processBase64Upload($base64Data, $folder = 'uploads', $prefix = '')
    {
        if (empty($base64Data)) {
            return null;
        }

        try {
            // Verifica se é um base64 válido
            if (!preg_match('/^data:([^;]+);base64,/', $base64Data, $matches)) {
                return null;
            }

            $mimeType = $matches[1];
            $base64String = substr($base64Data, strpos($base64Data, ',') + 1);
            $fileData = base64_decode($base64String);

            if ($fileData === false) {
                return null;
            }

            // Determina a extensão baseada no mime type
            $extension = $this->getExtensionFromMimeType($mimeType);
            
            // Gera nome único para o arquivo
            $fileName = $prefix . Str::random(40) . '.' . $extension;
            $filePath = $folder . '/' . $fileName;

            // Salva o arquivo no storage apropriado
            $saved = StorageHelper::saveFile($filePath, $fileData);

            if ($saved) {
                return [
                    'file_path' => $filePath,
                    'file_url' => StorageHelper::getPublicUrl($filePath),
                    'mime_type' => $mimeType,
                    'file_size' => strlen($fileData)
                ];
            }

            return null;
        } catch (\Exception $e) {
            \Log::error('Erro ao processar upload base64: ' . $e->getMessage());
            return null;
        }
    }

    /**
     * Processa múltiplos uploads base64
     */
    protected function processMultipleBase64Uploads($base64Array, $folder = 'uploads', $prefix = '')
    {
        $results = [];
        
        foreach ($base64Array as $key => $base64Data) {
            if (!empty($base64Data)) {
                $result = $this->processBase64Upload($base64Data, $folder, $prefix);
                if ($result) {
                    $results[$key] = $result;
                }
            }
        }

        return $results;
    }

    /**
     * Deleta arquivo do storage
     */
    protected function deleteFile($filePath)
    {
        if (!empty($filePath) && Storage::disk('public')->exists($filePath)) {
            return Storage::disk('public')->delete($filePath);
        }
        return false;
    }

    /**
     * Obtém extensão do arquivo baseado no mime type
     */
    private function getExtensionFromMimeType($mimeType)
    {
        $mimeToExtension = [
            'image/jpeg' => 'jpg',
            'image/jpg' => 'jpg',
            'image/png' => 'png',
            'image/gif' => 'gif',
            'image/webp' => 'webp',
            'image/svg+xml' => 'svg',
            'application/pdf' => 'pdf',
            'application/msword' => 'doc',
            'application/vnd.openxmlformats-officedocument.wordprocessingml.document' => 'docx',
            'application/vnd.ms-excel' => 'xls',
            'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' => 'xlsx',
            'text/plain' => 'txt',
            'text/csv' => 'csv',
            'video/mp4' => 'mp4',
            'video/mpeg' => 'mpeg',
            'video/quicktime' => 'mov',
            'video/x-msvideo' => 'avi',
            'video/x-ms-wmv' => 'wmv',
            'video/webm' => 'webm',
            'video/ogg' => 'ogv'
        ];

        return $mimeToExtension[$mimeType] ?? 'bin';
    }

    /**
     * Valida se o arquivo base64 é válido
     */
    protected function validateBase64File($base64Data, $maxSize = 10485760) // 10MB default
    {
        if (empty($base64Data)) {
            return true; // Campo opcional
        }

        // Verifica formato base64
        if (!preg_match('/^data:([^;]+);base64,/', $base64Data)) {
            return false;
        }

        // Verifica tamanho
        $base64String = substr($base64Data, strpos($base64Data, ',') + 1);
        $fileSize = strlen(base64_decode($base64String));
        
        if ($fileSize > $maxSize) {
            return false;
        }

        return true;
    }

    protected function validateBase64ImageFile($base64Data)
    {
        if (empty($base64Data)) {
            return true;
        }

        // Verifica formato base64
        if (!preg_match('/^data:([^;]+);base64,/', $base64Data)) {
            return false;
        }

        // Verifica se é uma imagem
        $mimeType = explode(';', explode(':', $base64Data)[1])[0];
        if (!str_starts_with($mimeType, 'image/')) {
            return false;
        }

        return true;
    }

    protected function validateBase64VideoFile($base64Data, $maxSize = 104857600) // 100MB default
    {
        if (empty($base64Data)) {
            return true;
        }

        // Verifica formato base64
        if (!preg_match('/^data:([^;]+);base64,/', $base64Data, $matches)) {
            return false;
        }

        // Verifica se é um vídeo
        $mimeType = $matches[1];
        if (!str_starts_with($mimeType, 'video/')) {
            return false;
        }

        // Verifica tamanho
        $base64String = substr($base64Data, strpos($base64Data, ',') + 1);
        $fileSize = strlen(base64_decode($base64String));
        
        if ($fileSize > $maxSize) {
            return false;
        }

        return true;
    }
}
