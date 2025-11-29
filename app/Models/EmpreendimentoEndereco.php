<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class EmpreendimentoEndereco extends Model
{
    protected $table = 'empreendimentos_endereco';

    protected $fillable = [
        'empreendimentos_id',
        'cep',
        'estado',
        'cidade',
        'bairro',
        'rua',
        'numero',
        'complemento',
    ];

    public function empreendimento()
    {
        return $this->belongsTo(Empreendimento::class, 'empreendimentos_id');
    }
}
