<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class IbtiRegistroVenda extends Model
{
    protected $table = 'ibti_registro_vendas';

    protected $fillable = ['nome'];
}
