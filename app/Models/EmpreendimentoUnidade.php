<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class EmpreendimentoUnidade extends Model
{
    protected $table = 'empreendimentos_unidades';

    protected $fillable = [
        'empreendimentos_tores_id',
        'numero_andar_apartamento',
        'numero_apartamento',
        'tamanho_unidade_metros_quadrados',
        'valor',
        'numero_quartos',
        'numero_suites',
        'numero_banheiros',
        'status_unidades_id',
        'observacao',
        'posicao', // Posição/insolação solar da unidade
    ];

    public function torre()
    {
        return $this->belongsTo(EmpreendimentoTorre::class, 'empreendimentos_tores_id');
    }
    
    public function vagas()
    {
        return $this->hasMany(EmpreendimentoUnidadeVagaGaragem::class, 'unidade_id');
    }

    public function medidas()
    {
        return $this->hasMany(MedidaUnidade::class, 'unidade_id');
    }
}
