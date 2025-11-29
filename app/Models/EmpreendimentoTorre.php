<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class EmpreendimentoTorre extends Model
{
    protected $table = 'empreendimentos_tores';

    protected $fillable = [
        'empreendimentos_id',
        'nome',
        'numero_andares',
        'quantidade_unidades_andar',
    ];

    // Append computed attributes to JSON
    protected $appends = [
        'total_unidades',
        'unidades_por_andar',
    ];

    public function empreendimento()
    {
        return $this->belongsTo(Empreendimento::class, 'empreendimentos_id');
    }

    public function excessoes()
    {
        return $this->hasMany(EmpreendimentoTorreExcessao::class, 'empreendimentos_tores_id');
    }

    public function unidades()
    {
        return $this->hasMany(EmpreendimentoUnidade::class, 'empreendimentos_tores_id');
    }

    public function fotosUnidades()
    {
        return $this->hasMany(EmpreendimentoUnidadeFoto::class, 'empreendimentos_tores_id');
    }

    public function videosUnidades()
    {
        return $this->hasMany(EmpreendimentoUnidadeVideo::class, 'empreendimentos_tores_id');
    }

    public function vagasGaragem()
    {
        return $this->hasMany(EmpreendimentoUnidadeVagaGaragem::class, 'empreendimentos_tores_id');
    }

    // Computed: array of units per floor considering exceptions
    public function getUnidadesPorAndarAttribute(): array
    {
        $porAndar = [];
        $base = (int) ($this->quantidade_unidades_andar ?? 0);
        $excessoes = $this->relationLoaded('excessoes') ? $this->excessoes : $this->excessoes()->get();
        $mapExcessoes = $excessoes->keyBy('numero_andar');

        $andares = (int) ($this->numero_andares ?? 0);
        for ($andar = 1; $andar <= $andares; $andar++) {
            $porAndar[$andar] = isset($mapExcessoes[$andar])
                ? (int) $mapExcessoes[$andar]->quantidade_unidades_andar
                : $base;
        }
        return $porAndar;
    }

    // Computed: total units in this tower considering exceptions
    public function getTotalUnidadesAttribute(): int
    {
        return array_sum($this->unidades_por_andar);
    }
}
