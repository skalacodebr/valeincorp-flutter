<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Casts\Attribute;

class Empreendimento extends Model
{
    protected $fillable = [
        'nome',
        'tipo_empreendimento_id',
        'tipo_unidades_id',
        'numero_total_unidade',
        'tamanho_total_comum_unidade_metros_quadrados',
        'area_lazer',
        'area_total',
        'observacoes',
        'empreendimentos_status_id',
        'data_entrega',
        'equipe_usuarios_id',
        'memorial_descritivo_base64',
        'catalogo_pdf_base64',
        'memorial_descritivo_url',
        'catalogo_pdf_url',
        'evolucao',
        'imagem_empreendimento',
    ];

    protected $casts = [
        'evolucao' => 'array',
        'area_lazer' => 'boolean',
    ];

    protected $appends = [
        'total_unidades_todas_torres',
    ];

    protected function evolucaoCompleta(): Attribute
    {
        return Attribute::make(
            get: function () {
                if (!$this->evolucao) return [];

                $evolucaoIds = collect($this->evolucao)->pluck('id');
                $evolucoes = EvolucaoObra::whereIn('id', $evolucaoIds)->get();

                return collect($this->evolucao)->map(function ($item) use ($evolucoes) {
                    $evolucao = $evolucoes->firstWhere('id', $item['id']);
                    return [
                        'id' => $item['id'],
                        'percentual_conclusao' => $item['percentual_conclusao'],
                        'nome' => $evolucao->nome ?? 'Evolução não encontrada',
                        'data_criacao' => $evolucao->data_criacao ?? null,
                    ];
                });
            }
        );
    }

    public function evolucoesDaObra()
    {
        if (!$this->evolucao) return collect([]);

        $evolucaoIds = collect($this->evolucao)->pluck('id');
        return EvolucaoObra::whereIn('id', $evolucaoIds)->get();
    }

    public function torres()
    {
        return $this->hasMany(EmpreendimentoTorre::class, 'empreendimentos_id');
    }

    public function areasLazer()
    {
        return $this->hasMany(EmpreendimentoAreaLazer::class, 'empreendimentos_id');
    }

    public function endereco()
    {
        return $this->hasOne(EmpreendimentoEndereco::class, 'empreendimentos_id');
    }

    public function status()
    {
        return $this->belongsTo(EmpreendimentoStatus::class, 'empreendimentos_status_id');
    }

    public function imagensArquivos()
    {
        return $this->hasMany(EmpreendimentoImagemArquivo::class, 'empreendimentos_id');
    }

    public function evolucaoObras()
    {
        return $this->hasMany(EvolucaoObra::class, 'empreendimento_id');
    }

    public function documentos()
    {
        return $this->hasMany(EmpreendimentoDocumento::class, 'empreendimentos_id');
    }

    public function fotosUnidades()
    {
        return $this->hasManyThrough(
            EmpreendimentoUnidadeFoto::class,
            EmpreendimentoTorre::class,
            'empreendimentos_id', // chave estrangeira em torres
            'empreendimentos_tores_id', // chave estrangeira em fotos
            'id', // chave local em empreendimentos
            'id'  // chave local em torres
        );
    }

    public function imagensCompletas()
    {
        // Combina imagens do arquivo principal + fotos das unidades
        $imagensArquivos = $this->imagensArquivos;
        $fotosUnidades = $this->fotosUnidades;

        return $imagensArquivos->concat($fotosUnidades);
    }

    public function unidades()
    {
        return $this->hasManyThrough(
            EmpreendimentoUnidade::class,
            EmpreendimentoTorre::class,
            'empreendimentos_id', // chave estrangeira em torres
            'empreendimentos_tores_id', // chave estrangeira em unidades
            'id', // chave local em empreendimentos
            'id'  // chave local em torres
        );
    }

    public function videosUnidades()
    {
        return $this->hasManyThrough(
            EmpreendimentoUnidadeVideo::class,
            EmpreendimentoTorre::class,
            'empreendimentos_id', // chave estrangeira em torres
            'empreendimentos_tores_id', // chave estrangeira em videos
            'id', // chave local em empreendimentos
            'id'  // chave local em torres
        );
    }

    public function getTotalUnidadesTodasTorresAttribute(): int
    {
        $torres = $this->relationLoaded('torres')
            ? $this->torres
            : $this->torres()->with('excessoes')->get();

        return (int) $torres->sum(function ($torre) {
            // Ensure computed is available
            if (!array_key_exists('total_unidades', $torre->getAttributes())) {
                // accessing attribute triggers accessor
                return (int) $torre->total_unidades;
            }
            return (int) $torre->getAttribute('total_unidades');
        });
    }

    public function getStatisticsAttribute()
    {
        $unidades = $this->unidades;

        if ($unidades->isEmpty()) {
            return [
                'totalUnidades' => 0,
                'unidadesVendidas' => 0,
                'percentualVendido' => 0,
                'unidadesDisponiveis' => 0,
                'valorMedio' => 0
            ];
        }

        $totalUnidades = $unidades->count();
        $unidadesVendidas = $unidades->where('status_unidades_id', 3)->count(); // Status "Vendida" = 3
        $percentualVendido = $totalUnidades > 0 ? round(($unidadesVendidas / $totalUnidades) * 100, 1) : 0;
        $unidadesDisponiveis = $unidades->where('status_unidades_id', 1)->count(); // Status "Disponível" = 1
        $unidadesDisponiveisCollection = $unidades->where('status_unidades_id', 1);
        $colecaoParaMedia = $unidadesDisponiveisCollection->isNotEmpty()
            ? $unidadesDisponiveisCollection
            : $unidades;
        $valorMedio = $colecaoParaMedia->avg('valor') ?: 0;

        return [
            'totalUnidades' => $totalUnidades,
            'unidadesVendidas' => $unidadesVendidas,
            'percentualVendido' => $percentualVendido,
            'unidadesDisponiveis' => $unidadesDisponiveis,
            'valorMedio' => round($valorMedio, 2)
        ];
    }
}
