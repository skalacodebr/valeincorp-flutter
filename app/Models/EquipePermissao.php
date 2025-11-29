<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class EquipePermissao extends Model
{
    protected $table = 'equipe_permissoes';

    protected $fillable = [
        'equipe_usuarios_id',
        'permissoes_id',
    ];

    public $timestamps = true;
}
