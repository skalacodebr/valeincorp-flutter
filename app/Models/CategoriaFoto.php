<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class CategoriaFoto extends Model
{
    use HasFactory;

    protected $table = 'categorias_fotos';

    protected $fillable = [
        'nome',
        'codigo',
        'descricao',
        'ordem',
        'ativo'
    ];

    protected $casts = [
        'ativo' => 'boolean',
        'ordem' => 'integer'
    ];

    protected $hidden = [
        'created_at',
        'updated_at'
    ];

    public function fotos()
    {
        return $this->hasMany(EmpreendimentoUnidadeFoto::class, 'categoria_foto_id');
    }

    public function scopeAtivo($query)
    {
        return $query->where('ativo', true);
    }

    public function scopeOrdenado($query)
    {
        return $query->orderBy('ordem', 'asc')->orderBy('nome', 'asc');
    }
}
