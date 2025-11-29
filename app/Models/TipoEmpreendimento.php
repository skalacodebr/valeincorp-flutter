<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class TipoEmpreendimento extends Model
{
    protected $table = 'tipo_empreendimento';

    protected $fillable = ['nome'];
}
