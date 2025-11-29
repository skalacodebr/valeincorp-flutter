<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class EmpreendimentoUnidadeVagaGaragem extends Model
{
    protected $table = 'empreendimentos_unidades_vagas_garem';

    protected $fillable = [
        'empreendimentos_tores_id',
        'numero_vaga',
        'cobertura',
        'tipo_vaga',
        'area_total',
        'pavimento',
        'observacoes',
        'status',
    ];

    protected $casts = [
        'area_total' => 'decimal:2',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    public function torre()
    {
        return $this->belongsTo(EmpreendimentoTorre::class, 'empreendimentos_tores_id');
    }
    
    public function unidade()
    {
        return $this->belongsTo(EmpreendimentoUnidade::class, 'unidade_id');
    }

}
