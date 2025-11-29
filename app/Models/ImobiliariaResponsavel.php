<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ImobiliariaResponsavel extends Model
{
    use HasFactory;

    protected $table = 'imobiliarias_responsaveis';

    protected $fillable = [
        'imobiliarias_id',
        'nome',
        'cpf',
        'email',
        'senha',
    ];

    public function imobiliaria()
    {
        return $this->belongsTo(Imobiliaria::class, 'imobiliarias_id');
    }
}
