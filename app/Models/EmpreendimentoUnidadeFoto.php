<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class EmpreendimentoUnidadeFoto extends Model
{
    protected $table = 'empreendimentos_unidades_fotos';

    protected $fillable = [
        'empreendimentos_tores_id',
        'fotos_url',
        'categorias',
        'legenda',
        'categoria_foto_id',
    ];

    public function torre()
    {
        return $this->belongsTo(EmpreendimentoTorre::class, 'empreendimentos_tores_id');
    }

    public function categoriaFoto()
    {
        return $this->belongsTo(CategoriaFoto::class, 'categoria_foto_id');
    }
}
