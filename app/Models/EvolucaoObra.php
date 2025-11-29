<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class EvolucaoObra extends Model
{
    use HasFactory, SoftDeletes;

    protected $table = 'evolucao_obras';

    protected $fillable = [
        'nome',
        'data_criacao',
        'empreendimento_id',
        'descricao',
        'percentual_conclusao',
        'created_by',
        'updated_by'
    ];

    protected $casts = [
        'data_criacao' => 'date',
        'percentual_conclusao' => 'integer',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
        'deleted_at' => 'datetime'
    ];

    protected $hidden = [
        'deleted_at',
        'created_by',
        'updated_by'
    ];

    public function empreendimento()
    {
        return $this->belongsTo(Empreendimento::class);
    }

    public function createdBy()
    {
        return $this->belongsTo(User::class, 'created_by');
    }

    public function updatedBy()
    {
        return $this->belongsTo(User::class, 'updated_by');
    }

    public function scopeByEmpreendimento($query, $empreendimentoId)
    {
        return $query->where('empreendimento_id', $empreendimentoId);
    }

    public function scopeOrderByDataCriacao($query, $direction = 'desc')
    {
        return $query->orderBy('data_criacao', $direction);
    }
}