<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class ClientePessoa extends Model
{
    use HasFactory;

    protected $table = 'clientes_pessoas';

    protected $fillable = [
        'clientes_id',
        'nome',
        'cpf_cnpj',
        'email',
        'telefone',
        'documento_rg_base64',
        'documento_cpf_base64',
        'comprovante_endereco_base64',
        'carteira_trabalho_base64',
        'pis_base64',
        'comprovante_renda_base64',
        'declaracao_ir_base64',
        'extrato_fgts_base64',
        'certidao_casamento_base64',
    ];

    public function cliente()
    {
        return $this->belongsTo(Cliente::class, 'clientes_id');
    }
}
