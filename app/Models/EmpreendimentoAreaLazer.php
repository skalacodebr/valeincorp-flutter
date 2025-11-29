<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class EmpreendimentoAreaLazer extends Model
{
    protected $table = 'empreendimentos_area_lazer';

    protected $fillable = [
        'empreendimentos_id',
        'tipo_area_lazer_id',
    ];

    public function empreendimento()
    {
        return $this->belongsTo(Empreendimento::class, 'empreendimentos_id');
    }
}
