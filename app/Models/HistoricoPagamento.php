<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class HistoricoPagamento extends Model
{
    protected $table = 'historico_pagamentos';

    protected $fillable = [
        'negociacoes_id',
        'valor_pago',
        'data',
    ];

    public function negociacao()
    {
        return $this->belongsTo(Negociacao::class, 'negociacoes_id');
    }
}
