<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class AcessoCompartilhamento extends Model
{
    use HasFactory;

    protected $table = 'acessos_compartilhamentos';

    protected $fillable = [
        'compartilhamento_id',
        'ip_address',
        'user_agent',
        'acessado_at',
        'referer',
    ];

    protected $casts = [
        'acessado_at' => 'datetime',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    /**
     * Relacionamento com compartilhamento
     */
    public function compartilhamento()
    {
        return $this->belongsTo(Compartilhamento::class);
    }

    /**
     * Scope para filtrar por compartilhamento
     */
    public function scopePorCompartilhamento($query, $compartilhamentoId)
    {
        return $query->where('compartilhamento_id', $compartilhamentoId);
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
