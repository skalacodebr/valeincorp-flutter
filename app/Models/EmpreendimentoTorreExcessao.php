<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class EmpreendimentoTorreExcessao extends Model
{
    protected $table = 'empreendimentos_tores_excessao';

    protected $fillable = [
        'empreendimentos_tores_id',
        'numero_andar',
        'quantidade_unidades_andar',
    ];

    public function torre()
    {
        return $this->belongsTo(EmpreendimentoTorre::class, 'empreendimentos_tores_id');
    }
}
