<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ConformidadeVenda extends Model
{
    protected $table = 'conformidades_vendas';

    protected $fillable = ['nome'];
}
