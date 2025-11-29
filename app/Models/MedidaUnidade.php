<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class MedidaUnidade extends Model
{
    use HasFactory;

    protected $table = 'medidas_unidades';

    protected $fillable = [
        'unidade_id',
        'tipo_medida_id',
        'valor',
    ];

    protected $casts = [
        'valor' => 'decimal:2',
    ];

    /**
     * Relacionamento com a unidade
     */
    public function unidade()
    {
        return $this->belongsTo(EmpreendimentoUnidade::class, 'unidade_id');
    }

    /**
     * Relacionamento com o tipo de medida
     */
    public function tipoMedida()
    {
        return $this->belongsTo(TipoMedidaUnidade::class, 'tipo_medida_id');
    }
}
