<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class TipoUnidade extends Model
{
    protected $table = 'tipo_unidades';

    protected $fillable = ['nome'];
}
