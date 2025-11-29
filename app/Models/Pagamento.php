<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Pagamento extends Model
{
    protected $table = 'pagamentos';

    protected $fillable = [
        'negociacoes_id',
        'valor_total_pago',
        'formas_pagamento_id',
    ];

    public function negociacao()
    {
        return $this->belongsTo(Negociacao::class, 'negociacoes_id');
    }
}
