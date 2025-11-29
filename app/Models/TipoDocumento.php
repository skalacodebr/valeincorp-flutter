<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class TipoDocumento extends Model
{
    use HasFactory;

    protected $table = 'tipos_documentos';

    protected $fillable = [
        'nome',
        'descricao',
        'tipo_arquivo',
        'obrigatorio',
        'ordem',
        'ativo',
    ];

    protected $casts = [
        'obrigatorio' => 'boolean',
        'ativo' => 'boolean',
        'ordem' => 'integer',
    ];
}
