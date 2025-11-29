<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ClickTracking extends Model
{
    use HasFactory;

    protected $table = 'click_tracking';

    protected $fillable = [
        'user_id',
        'entity_type',
        'entity_id',
        'action_type',
        'share_platform',
        'ip_address',
        'user_agent',
        'click_date',
        'clicked_at',
    ];

    protected $casts = [
        'click_date' => 'date',
        'clicked_at' => 'datetime',
    ];

    /**
     * Relacionamento com o corretor (opcional)
     */
    public function corretor()
    {
        return $this->belongsTo(Corretor::class, 'user_id');
    }

    /**
     * Relacionamento com empreendimento
     */
    public function empreendimento()
    {
        return $this->belongsTo(Empreendimento::class, 'entity_id')
            ->where('entity_type', 'empreendimento');
    }

    /**
     * Relacionamento com unidade
     */
    public function unidade()
    {
        return $this->belongsTo(EmpreendimentoUnidade::class, 'entity_id')
            ->where('entity_type', 'unidade');
    }

    /**
     * Scope para filtrar por tipo de entidade
     */
    public function scopeByEntityType($query, $entityType)
    {
        return $query->where('entity_type', $entityType);
    }

    /**
     * Scope para filtrar por tipo de ação
     */
    public function scopeByActionType($query, $actionType)
    {
        return $query->where('action_type', $actionType);
    }

    /**
     * Scope para filtrar por data
     */
    public function scopeByDate($query, $date)
    {
        return $query->where('click_date', $date);
    }

    /**
     * Scope para filtrar por período
     */
    public function scopeByDateRange($query, $startDate, $endDate)
    {
        return $query->whereBetween('click_date', [$startDate, $endDate]);
    }

    /**
     * Scope para filtrar por usuário
     */
    public function scopeByUser($query, $userId)
    {
        return $query->where('user_id', $userId);
    }
}
