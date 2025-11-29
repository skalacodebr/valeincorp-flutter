<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class TipoMedidaUnidade extends Model
{
    use HasFactory;

    protected $table = 'tipos_medida_unidades';

    protected $fillable = [
        'nome',
        'unidade',
        'ativo',
    ];

    protected $casts = [
        'ativo' => 'boolean',
    ];

    /**
     * Relacionamento com medidas das unidades
     */
    public function medidasUnidades()
    {
        return $this->hasMany(MedidaUnidade::class, 'tipo_medida_id');
    }

    /**
     * Scope para tipos ativos
     */
    public function scopeAtivos($query)
    {
        return $query->where('ativo', true);
    }

    /**
     * Scope para ordenar por nome
     */
    public function scopeOrdenados($query)
    {
        return $query->orderBy('nome');
    }
}
