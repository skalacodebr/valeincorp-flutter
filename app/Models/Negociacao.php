<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Negociacao extends Model
{
    protected $table = 'negociacoes';

    // Desabilitar proteção de mass assignment para teste
    protected $guarded = [];

    protected $fillable = [
        'empreendimentos_id',
        'empreendimentos_unidades_id',
        'clientes_id',
        'equipe_usuarios_id',
        'corretores_id',
        'valor_contrato',
        'numero_contrato',
        'data',
        'modalidades_vendas_id',
        'situacoes_vendas_id',
        'validade',
        'conformidades_vendas_id',
        'nome_correspondente',
        'imobiliarias_id',
        'ibti_registro_vendas_id',
        'valor_entrada_ato',
        'quantidade_parcelas_disponiveis_id',
        'valor_reforco',
        'valor_financiamento',
        'nome_banco',
        'diferenca_valor',
        'percentual_comissao',
        'equipe_usuarios_id_corretor',
        'negociacoes_status_id',
        'registro_imoveis_cidade_cartorio',
        'observacoes',
        'parcelas_atos_numero',
        'parcelas_documentacao_construtora',
        'valor_fgts',
        'utilizar_fgts',
        'distratado',
        'itbi_responsavel',
        'registro_responsavel',
        'data_vencimento_avaliacao_cca',
        'data_assinatura_contrato_construtora',
        'empreendimentos_box_id',
        'permuta',
    ];

    // (Opcional) Para facilitar o uso de tipos nativos
    protected $casts = [
        'data'                                => 'date',
        'validade'                            => 'date',
        'data_vencimento_avaliacao_cca'       => 'date',
        'data_assinatura_contrato_construtora' => 'date',
        'utilizar_fgts'                       => 'boolean',
        'distratado'                          => 'boolean',
        'permuta'                             => 'decimal:2',
        'valor_contrato'                      => 'decimal:2',
        'valor_entrada_ato'                   => 'decimal:2',
        'valor_reforco'                       => 'decimal:2',
        'valor_financiamento'                 => 'decimal:2',
        'valor_fgts'                          => 'decimal:2',
        'diferenca_valor'                     => 'decimal:2',
        'percentual_comissao'                 => 'decimal:2',
    ];

    // Removido o appends e accessor valorPermuta pois agora permuta já é um valor monetário direto

    // Mutator para garantir que permuta seja salva como valor monetário
    public function setPermutaAttribute($value)
    {
        // Garante que o valor seja numérico ou null
        $this->attributes['permuta'] = $value !== null ? (float) $value : null;
    }

    // Relacionamentos
    public function empreendimento()
    {
        return $this->belongsTo(Empreendimento::class, 'empreendimentos_id');
    }

    public function unidade()
    {
        return $this->belongsTo(EmpreendimentoUnidade::class, 'empreendimentos_unidades_id');
    }

    public function cliente()
    {
        return $this->belongsTo(Cliente::class, 'clientes_id');
    }

    public function corretor()
    {
        return $this->belongsTo(EquipeUsuario::class, 'corretores_id');
    }

    public function equipeUsuario()
    {
        return $this->belongsTo(EquipeUsuario::class, 'equipe_usuarios_id');
    }

    public function status()
    {
        return $this->belongsTo(NegociacaoStatus::class, 'negociacoes_status_id');
    }
}
