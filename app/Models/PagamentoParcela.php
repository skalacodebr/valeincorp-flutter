<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class PagamentoParcela extends Model
{
    protected $table = 'pagamentos_parcelas';

    protected $fillable = [
        'negociacoes_id',
        'valor_parcela',
        'data_limite_pagamento',
        'status_pagamentos_parcelas_id',
    ];

    public function negociacao()
    {
        return $this->belongsTo(Negociacao::class, 'negociacoes_id');
    }
}
