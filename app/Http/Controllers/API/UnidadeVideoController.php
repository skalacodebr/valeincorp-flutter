<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\EmpreendimentoUnidadeVideo;
use App\Helpers\StorageHelper;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Str;

class UnidadeVideoController extends Controller
{
    public function index($torre_id)
    {
        $videos = EmpreendimentoUnidadeVideo::where('empreendimentos_tores_id', $torre_id)
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json($videos);
    }

    public function store(Request $request, $torre_id)
    {
        $validator = Validator::make($request->all(), [
            'video_file' => 'required_without:videos_url|file|mimetypes:video/mp4,video/mpeg,video/x-msvideo,video/webm|max:102400',
            'videos_url' => 'required_without:video_file|string|max:255',
            'categoria' => 'required|string|max:100',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $videoData = [
            'empreendimentos_tores_id' => $torre_id,
            'categoria' => $request->categoria,
        ];

        if ($request->hasFile('video_file')) {
            $file = $request->file('video_file');
            
            // Bloquear arquivos .MOV explicitamente
            $extension = strtolower($file->getClientOriginalExtension());
            if ($extension === 'mov') {
                return response()->json([
                    'error' => 'Arquivos .MOV não são suportados. Por favor, use formatos MP4, AVI ou WebM para melhor compatibilidade.'
                ], 422);
            }
            
            $folder = 'videos/unidades';
            
            $fileName = Str::random(40) . '.' . $file->getClientOriginalExtension();
            $filePath = $folder . '/' . $fileName;
            
            $disk = StorageHelper::getStorageDisk();
            $path = Storage::disk($disk)->putFileAs($folder, $file, $fileName);
            
            if (!$path) {
                return response()->json(['error' => 'Erro ao salvar o arquivo de vídeo'], 500);
            }
            
            $videoData['video_path'] = $filePath;
            $videoData['video_url'] = StorageHelper::getPublicUrl($filePath);
            $videoData['original_name'] = $file->getClientOriginalName();
            $videoData['file_size'] = $file->getSize();
            $videoData['mime_type'] = $file->getMimeType();
            
        } else {
            $videoUrl = $request->videos_url;
            
            if (!$this->validateVideoUrl($videoUrl)) {
                return response()->json(['error' => 'URL de vídeo inválida. Use URLs do YouTube ou Vimeo.'], 400);
            }
            
            $videoData['videos_url'] = $this->normalizeVideoUrl($videoUrl);
        }

        $video = EmpreendimentoUnidadeVideo::create($videoData);

        return response()->json($video, 201);
    }

    public function update(Request $request, $torre_id, $id)
    {
        $video = EmpreendimentoUnidadeVideo::where('empreendimentos_tores_id', $torre_id)
            ->findOrFail($id);

        $validator = Validator::make($request->all(), [
            'video_file' => 'sometimes|file|mimetypes:video/mp4,video/mpeg,video/x-msvideo,video/webm|max:102400',
            'videos_url' => 'sometimes|string|max:255',
            'categoria' => 'sometimes|string|max:100',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        if ($request->hasFile('video_file')) {
            $file = $request->file('video_file');
            
            // Bloquear arquivos .MOV explicitamente
            $extension = strtolower($file->getClientOriginalExtension());
            if ($extension === 'mov') {
                return response()->json([
                    'error' => 'Arquivos .MOV não são suportados. Por favor, use formatos MP4, AVI ou WebM para melhor compatibilidade.'
                ], 422);
            }
            
            if ($video->video_path) {
                $disk = StorageHelper::getStorageDisk();
                Storage::disk($disk)->delete($video->video_path);
            }
            
            $folder = 'videos/unidades';
            
            $fileName = Str::random(40) . '.' . $file->getClientOriginalExtension();
            $filePath = $folder . '/' . $fileName;
            
            $disk = StorageHelper::getStorageDisk();
            $path = Storage::disk($disk)->putFileAs($folder, $file, $fileName);
            
            if (!$path) {
                return response()->json(['error' => 'Erro ao salvar o arquivo de vídeo'], 500);
            }
            
            $video->video_path = $filePath;
            $video->video_url = StorageHelper::getPublicUrl($filePath);
            $video->original_name = $file->getClientOriginalName();
            $video->file_size = $file->getSize();
            $video->mime_type = $file->getMimeType();
            
            // $video->videos_url = null; // Comentado temporariamente até migration ser executada
        } elseif ($request->has('videos_url')) {
            $videoUrl = $request->videos_url;
            
            if (!$this->validateVideoUrl($videoUrl)) {
                return response()->json(['error' => 'URL de vídeo inválida. Use URLs do YouTube ou Vimeo.'], 400);
            }
            
            if ($video->video_path) {
                $disk = StorageHelper::getStorageDisk();
                Storage::disk($disk)->delete($video->video_path);
            }
            
            $video->videos_url = $this->normalizeVideoUrl($videoUrl);
            $video->video_path = null;
            $video->video_url = null;
            $video->original_name = null;
            $video->file_size = null;
            $video->mime_type = null;
        }

        if ($request->has('categoria')) {
            $video->categoria = $request->categoria;
        }

        $video->save();

        return response()->json($video);
    }

    public function destroy($torre_id, $id)
    {
        $video = EmpreendimentoUnidadeVideo::where('empreendimentos_tores_id', $torre_id)
            ->findOrFail($id);
        
        if ($video->video_path) {
            $disk = StorageHelper::getStorageDisk();
            Storage::disk($disk)->delete($video->video_path);
        }
        
        $video->delete();

        return response()->json(['message' => 'Vídeo removido com sucesso.']);
    }

    private function validateVideoUrl($url)
    {
        $youtubePattern = '/^(https?:\/\/)?(www\.)?(youtube\.com\/(watch\?v=|embed\/)|youtu\.be\/)[\w-]+/';
        $vimeoPattern = '/^(https?:\/\/)?(www\.)?(vimeo\.com\/)[\d]+/';
        
        return preg_match($youtubePattern, $url) || preg_match($vimeoPattern, $url);
    }

    private function normalizeVideoUrl($url)
    {
        if (preg_match('/(?:youtube\.com\/watch\?v=|youtu\.be\/|youtube\.com\/embed\/)([\w-]+)/', $url, $matches)) {
            return 'https://www.youtube.com/embed/' . $matches[1];
        }
        
        if (preg_match('/vimeo\.com\/(\d+)/', $url, $matches)) {
            return 'https://player.vimeo.com/video/' . $matches[1];
        }
        
        return $url;
    }

    public function getByCategoria($torre_id, $categoria)
    {
        $videos = EmpreendimentoUnidadeVideo::where('empreendimentos_tores_id', $torre_id)
            ->where('categoria', $categoria)
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json($videos);
    }

    public function getCategorias($torre_id)
    {
        $categorias = EmpreendimentoUnidadeVideo::where('empreendimentos_tores_id', $torre_id)
            ->distinct()
            ->pluck('categoria');

        return response()->json($categorias);
    }

    public function serveVideo($videoId)
    {
        $video = EmpreendimentoUnidadeVideo::findOrFail($videoId);
        
        if (!$video->video_path) {
            abort(404, 'Vídeo não encontrado');
        }
        
        $disk = StorageHelper::getStorageDisk();
        $fullPath = Storage::disk($disk)->path($video->video_path);
        
        if (!file_exists($fullPath)) {
            abort(404, 'Arquivo não encontrado');
        }
        
        return $this->streamVideo($fullPath);
    }

    private function streamVideo($filePath)
    {
        $size = filesize($filePath);
        $mimeType = mime_content_type($filePath);
        
        $headers = [
            'Content-Type' => $mimeType,
            'Access-Control-Allow-Origin' => '*',
            'Access-Control-Allow-Methods' => 'GET, OPTIONS',
            'Access-Control-Allow-Headers' => 'Range',
            'Accept-Ranges' => 'bytes',
            'Content-Length' => $size,
        ];
        
        if (request()->hasHeader('Range')) {
            return $this->handleRangeRequest($filePath, $size, $headers);
        }
        
        return response()->file($filePath, $headers);
    }

    private function handleRangeRequest($filePath, $size, $headers)
    {
        $range = request()->header('Range');
        if (preg_match('/bytes=(\d+)-(\d*)/', $range, $matches)) {
            $start = intval($matches[1]);
            $end = $matches[2] ? intval($matches[2]) : $size - 1;
            
            $headers['Content-Range'] = "bytes $start-$end/$size";
            $headers['Content-Length'] = $end - $start + 1;
            
            $file = fopen($filePath, 'r');
            fseek($file, $start);
            $data = fread($file, $end - $start + 1);
            fclose($file);
            
            return response($data, 206, $headers);
        }
        
        return response()->file($filePath, $headers);
    }
}