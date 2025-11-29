<?php

use Illuminate\Support\Facades\Route;

Route::view('/',            'login')->name('login');
Route::view('/register',    'register')->name('register');
Route::view('/dashboard',   'dashboard')->name('dashboard');

// Rota OPTIONS para preflight requests
Route::options('storage/{path}', function () {
    return response('', 200, [
        'Access-Control-Allow-Origin' => '*',
        'Access-Control-Allow-Methods' => 'GET, POST, PUT, DELETE, OPTIONS',
        'Access-Control-Allow-Headers' => 'Content-Type, Authorization, X-Requested-With, Origin, Accept',
        'Access-Control-Expose-Headers' => 'Content-Length, Content-Type',
    ]);
})->where('path', '.*');

// Rota para servir arquivos do storage
Route::get('storage/{path}', function ($path) {
    $fullPath = storage_path('app/public/' . $path);
    
    if (!file_exists($fullPath) || !is_readable($fullPath)) {
        abort(404);
    }
    
    $mimeType = mime_content_type($fullPath);
    $fileSize = filesize($fullPath);
    
    // Headers para vídeos e outros arquivos
    $headers = [
        'Content-Type' => $mimeType,
        'Access-Control-Allow-Origin' => '*',
        'Access-Control-Allow-Methods' => 'GET, OPTIONS',
        'Access-Control-Allow-Headers' => 'Range, Content-Type',
        'Accept-Ranges' => 'bytes',
        'Content-Length' => $fileSize,
        'Cache-Control' => 'public, max-age=31536000',
    ];
    
    // Suporte a Range Requests para streaming
    if (request()->hasHeader('Range')) {
        $range = request()->header('Range');
        if (preg_match('/bytes=(\d+)-(\d*)/', $range, $matches)) {
            $start = intval($matches[1]);
            $end = $matches[2] ? intval($matches[2]) : $fileSize - 1;
            
            $headers['Content-Range'] = "bytes $start-$end/$fileSize";
            $headers['Content-Length'] = $end - $start + 1;
            
            $file = fopen($fullPath, 'r');
            fseek($file, $start);
            $data = fread($file, $end - $start + 1);
            fclose($file);
            
            return response($data, 206, $headers);
        }
    }
    
    return response()->file($fullPath, $headers);
})->where('path', '.*');

// Rota pública para compartilhamentos
Route::get('/share/{linkUnico}', [App\Http\Controllers\ShareController::class, 'show'])
    ->name('share.show');
