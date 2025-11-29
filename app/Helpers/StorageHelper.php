<?php

namespace App\Helpers;

use Illuminate\Support\Facades\Storage;

class StorageHelper
{
    /**
     * Gera a URL pública para um arquivo no storage
     */
    public static function getPublicUrl($filePath)
    {
        // Se estiver em produção e S3 estiver configurado, usar S3
        if (app()->environment('production') && self::isS3Configured()) {
            return Storage::disk('s3')->url($filePath);
        }
        
        // URL base da aplicação
        $baseUrl = env('APP_URL', 'https://backend.valeincorp.com.br');
        
        // Se estiver em produção, usar a URL da produção
        if (app()->environment('production')) {
            $baseUrl = 'https://backend.valeincorp.com.br';
        } else {
            // Em desenvolvimento, usar a URL do .env ou localhost padrão
            $baseUrl = env('APP_URL', 'http://127.0.0.1:8000');
        }
        
        // Remove a barra final se existir
        $baseUrl = rtrim($baseUrl, '/');
        
        // Retorna a URL completa
        return $baseUrl . '/storage/' . $filePath;
    }
    
    /**
     * Salva um arquivo no storage apropriado
     */
    public static function saveFile($filePath, $fileData)
    {
        // Se estiver em produção e S3 estiver configurado, usar S3
        if (app()->environment('production') && self::isS3Configured()) {
            return Storage::disk('s3')->put($filePath, $fileData);
        }
        
        // Caso contrário, usar storage local
        return Storage::disk('public')->put($filePath, $fileData);
    }
    
    /**
     * Verifica se uma URL é do storage local
     */
    public static function isStorageUrl($url)
    {
        return strpos($url, '/storage/') !== false;
    }
    
    /**
     * Extrai o caminho do arquivo de uma URL do storage
     */
    public static function getFilePathFromUrl($url)
    {
        if (preg_match('/\/storage\/(.+)$/', $url, $matches)) {
            return $matches[1];
        }
        return null;
    }
    
    /**
     * Verifica se S3 está configurado
     */
    private static function isS3Configured()
    {
        return !empty(env('AWS_ACCESS_KEY_ID')) && 
               !empty(env('AWS_SECRET_ACCESS_KEY')) && 
               !empty(env('AWS_BUCKET'));
    }
    
    /**
     * Obtém o disk apropriado para o ambiente atual
     */
    public static function getStorageDisk()
    {
        if (app()->environment('production') && self::isS3Configured()) {
            return 's3';
        }
        return 'public';
    }
} 