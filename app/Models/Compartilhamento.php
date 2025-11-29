<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Str;

class Compartilhamento extends Model
{
    use HasFactory;

    protected $table = 'compartilhamentos';

    protected $fillable = [
        'corretor_id',
        'entity_type',
        'entity_id',
        'link_unico',
        'nome_cliente',
        'anotacao',
        'receber_notificacao',
        'mostrar_espelho_vendas',
        'mostrar_endereco',
        'compartilhar_descricao',
        'total_visualizacoes',
        'ultima_visualizacao_at',
        'ativo',
        'expira_em',
    ];

    protected $casts = [
        'receber_notificacao' => 'boolean',
        'mostrar_espelho_vendas' => 'boolean',
        'mostrar_endereco' => 'boolean',
        'compartilhar_descricao' => 'boolean',
        'total_visualizacoes' => 'integer',
        'ativo' => 'boolean',
        'ultima_visualizacao_at' => 'datetime',
        'expira_em' => 'datetime',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    /**
     * Relacionamento com corretor
     */
    public function corretor()
    {
        return $this->belongsTo(Corretor::class);
    }

    /**
     * Relacionamento com empreendimento (polimórfico)
     */
    public function entity()
    {
        return $this->morphTo('entity', 'entity_type', 'entity_id');
    }

    /**
     * Relacionamento com empreendimento
     */
    public function empreendimento()
    {
        return $this->belongsTo(Empreendimento::class, 'entity_id');
    }

    /**
     * Relacionamento com unidade
     */
    public function unidade()
    {
        return $this->belongsTo(EmpreendimentoUnidade::class, 'entity_id');
    }

    /**
     * Relacionamento com acessos
     */
    public function acessos()
    {
        return $this->hasMany(AcessoCompartilhamento::class);
    }

    /**
     * Relacionamento com click tracking
     */
    public function clickTrackings()
    {
        return $this->hasMany(ClickTracking::class);
    }

    /**
     * Gera um link único para o compartilhamento
     */
    public function gerarLinkUnico(): string
    {
        do {
            $linkUnico = Str::random(32);
        } while (self::where('link_unico', $linkUnico)->exists());

        return $linkUnico;
    }

    /**
     * Incrementa o contador de visualizações
     */
    public function incrementarVisualizacao(): void
    {
        $this->increment('total_visualizacoes');
        $this->update(['ultima_visualizacao_at' => now()]);
    }

    /**
     * Retorna a URL completa do compartilhamento
     */
    public function getUrlCompletaAttribute(): string
    {
        $baseUrl = config('app.url', 'https://backend.valeincorp.com.br');
        return "{$baseUrl}/share/{$this->link_unico}";
    }

    /**
     * Verifica se o link está expirado
     */
    public function isExpirado(): bool
    {
        if (!$this->expira_em) {
            return false;
        }

        return now()->isAfter($this->expira_em);
    }

    /**
     * Verifica se o link está ativo e não expirado
     */
    public function isAtivo(): bool
    {
        return $this->ativo && !$this->isExpirado();
    }

    /**
     * Scope para filtrar compartilhamentos ativos
     */
    public function scopeAtivos($query)
    {
        return $query->where('ativo', true)
            ->where(function ($q) {
                $q->whereNull('expira_em')
                  ->orWhere('expira_em', '>', now());
            });
    }

    /**
     * Scope para filtrar por corretor
     */
    public function scopePorCorretor($query, $corretorId)
    {
        return $query->where('corretor_id', $corretorId);
    }

    /**
     * Scope para filtrar por tipo de entidade
     */
    public function scopePorTipoEntidade($query, $entityType)
    {
        return $query->where('entity_type', $entityType);
    }

    /**
     * Boot method para gerar link único automaticamente
     */
    protected static function boot()
    {
        parent::boot();

        static::creating(function ($compartilhamento) {
            if (empty($compartilhamento->link_unico)) {
                $compartilhamento->link_unico = $compartilhamento->gerarLinkUnico();
            }
        });
    }
}
