<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class NegociacaoStatus extends Model
{
    use HasFactory;

    protected $table = 'negociacoes_status';

    protected $fillable = [
        'nome',
        'cor',
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

    public function negociacoes()
    {
        return $this->hasMany(Negociacao::class, 'negociacoes_status_id');
    }
}
