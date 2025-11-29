<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Support\Facades\Storage;

class EmpreendimentoDocumento extends Model
{
    use HasFactory;

    protected $table = 'empreendimentos_documentos';

    protected $fillable = [
        'empreendimentos_id',
        'tipos_documentos_id',
        'arquivo_url',
        'nome_original',
        'nome_salvo',
        'tipo_mime',
        'tamanho_bytes',
    ];

    protected $casts = [
        'tamanho_bytes' => 'integer',
    ];

    // Accessor para retornar URL completa do arquivo
    public function getArquivoUrlAttribute($value)
    {
        if (!$value) {
            return null;
        }

        // Se já for uma URL completa, retorna como está
        if (filter_var($value, FILTER_VALIDATE_URL)) {
            return $value;
        }

        // Remove barra inicial se existir
        $path = ltrim($value, '/');

        // Retorna URL completa - usar URL do backend em produção
        $baseUrl = config('app.url');
        if (str_contains($baseUrl, 'localhost')) {
            $baseUrl = 'https://backend.valeincorp.com.br';
        }
        return $baseUrl . '/' . $path;
    }

    // Relacionamentos
    public function empreendimento()
    {
        return $this->belongsTo(Empreendimento::class, 'empreendimentos_id');
    }

    public function tipoDocumento()
    {
        return $this->belongsTo(TipoDocumento::class, 'tipos_documentos_id');
    }

    // Evento para deletar arquivo físico quando deletar registro
    protected static function booted()
    {
        static::deleting(function ($documento) {
            // Extrair caminho do storage da URL
            $path = str_replace('/storage/', '', parse_url($documento->arquivo_url, PHP_URL_PATH));

            if (Storage::disk('public')->exists($path)) {
                Storage::disk('public')->delete($path);
            }
        });
    }
}
