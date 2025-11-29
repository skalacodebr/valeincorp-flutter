<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ImobiliariaEndereco extends Model
{
    use HasFactory;

    protected $table = 'imobiliarias_endereco';

    protected $fillable = [
        'imobiliarias_id',
        'cep',
        'estado',
        'cidade',
        'bairro',
        'rua',
        'numero',
        'complemento',
    ];

    public function imobiliaria()
    {
        return $this->belongsTo(Imobiliaria::class, 'imobiliarias_id');
    }
}
