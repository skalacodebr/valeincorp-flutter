<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class EmpreendimentoUnidadeVideo extends Model
{
    protected $table = 'empreendimentos_unidades_videos';

    protected $fillable = [
        'empreendimentos_tores_id',
        'videos_url',
        'video_path',
        'video_url',
        'original_name',
        'file_size',
        'mime_type',
        'categoria',
    ];

    public function torre()
    {
        return $this->belongsTo(EmpreendimentoTorre::class, 'empreendimentos_tores_id');
    }
}