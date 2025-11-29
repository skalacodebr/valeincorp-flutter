<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Permissao extends Model
{
    use HasFactory;

    protected $table = 'permissoes';

    protected $fillable = ['nome'];

    public function usuarios()
    {
        return $this->belongsToMany(EquipeUsuario::class, 'equipe_permissoes', 'permissoes_id', 'equipe_usuarios_id');
    }
}
