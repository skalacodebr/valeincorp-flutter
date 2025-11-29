<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Imobiliaria extends Model
{
    use HasFactory;

    protected $table = 'imobiliarias';

    protected $fillable = [
        'nome',
        'cnpj',
        'email',
        'telefone',
        'creci',
    ];

    public function corretores()
    {
        return $this->hasMany(Corretor::class, 'imobiliarias_id');
    }

    public function endereco()
    {
        return $this->hasOne(ImobiliariaEndereco::class, 'imobiliarias_id');
    }

    public function responsaveis()
    {
        return $this->hasMany(ImobiliariaResponsavel::class, 'imobiliarias_id');
    }
}
