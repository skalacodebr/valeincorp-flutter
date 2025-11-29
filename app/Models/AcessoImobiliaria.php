<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class AcessoImobiliaria extends Model
{
    use HasFactory;

    protected $table = 'acessos_imobiliarias';

    protected $fillable = [
        'imobiliaria_id',
        'user_id',
        'tipo_acesso',
        'ip_address',
        'user_agent',
        'acessado_at',
        'detalhes',
    ];

    protected $casts = [
        'acessado_at' => 'datetime',
        'detalhes' => 'array',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    /**
     * Relacionamento com imobiliária
     */
    public function imobiliaria()
    {
        return $this->belongsTo(Imobiliaria::class);
    }

    /**
     * Relacionamento com usuário (corretor)
     */
    public function user()
    {
        return $this->belongsTo(Corretor::class, 'user_id');
    }

    /**
     * Scope para filtrar por imobiliária
     */
    public function scopePorImobiliaria($query, $imobiliariaId)
    {
        return $query->where('imobiliaria_id', $imobiliariaId);
    }

    /**
     * Scope para filtrar por tipo de acesso
     */
    public function scopePorTipoAcesso($query, $tipoAcesso)
    {
        return $query->where('tipo_acesso', $tipoAcesso);
    }

    /**
     * Scope para filtrar por data
     */
    public function scopePorData($query, $date)
    {
        return $query->whereDate('acessado_at', $date);
    }

    /**
     * Scope para filtrar por período
     */
    public function scopePorPeriodo($query, $startDate, $endDate)
    {
        return $query->whereBetween('acessado_at', [$startDate, $endDate]);
    }
}
