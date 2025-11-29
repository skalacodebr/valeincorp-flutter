<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Favorito extends Model
{
    protected $fillable = [
        'corretor_id',
        'empreendimento_id'
    ];

    protected $casts = [
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    /**
     * Relacionamento com Corretor
     */
    public function corretor(): BelongsTo
    {
        return $this->belongsTo(Corretor::class);
    }

    /**
     * Relacionamento com Empreendimento
     */
    public function empreendimento(): BelongsTo
    {
        return $this->belongsTo(Empreendimento::class);
    }

    /**
     * Scope para favoritos de um corretor específico
     */
    public function scopeDoCorretor($query, $corretorId)
    {
        return $query->where('corretor_id', $corretorId);
    }

    /**
     * Verificar se um empreendimento é favorito de um corretor
     */
    public static function isFavorito($corretorId, $empreendimentoId): bool
    {
        return static::where('corretor_id', $corretorId)
            ->where('empreendimento_id', $empreendimentoId)
            ->exists();
    }

    /**
     * Adicionar aos favoritos (ou não fazer nada se já existir)
     */
    public static function adicionarFavorito($corretorId, $empreendimentoId): self
    {
        return static::firstOrCreate([
            'corretor_id' => $corretorId,
            'empreendimento_id' => $empreendimentoId
        ]);
    }

    /**
     * Remover dos favoritos
     */
    public static function removerFavorito($corretorId, $empreendimentoId): bool
    {
        return static::where('corretor_id', $corretorId)
            ->where('empreendimento_id', $empreendimentoId)
            ->delete() > 0;
    }
}
