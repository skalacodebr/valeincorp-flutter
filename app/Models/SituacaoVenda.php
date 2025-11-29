<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class SituacaoVenda extends Model
{
    protected $table = 'situacoes_vendas';

    protected $fillable = ['nome'];
}
