<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Cliente extends Model
{
    use HasFactory;

    protected $table = 'clientes';

    protected $fillable = [
        'observacoes',
        'status_clientes_id',
        'equipe_usuarios_id',
        'imobiliarias_id',
        'corretores_id',
        'profissao',
        'estado_civil',
    ];

    // Pessoa vinculada
    public function pessoa()
    {
        return $this->hasOne(ClientePessoa::class, 'clientes_id');
    }

    // Endereço vinculado
    public function endereco()
    {
        return $this->hasOne(ClienteEndereco::class, 'clientes_id');
    }

    // Foto vinculada
    public function foto()
    {
        return $this->hasOne(ClienteFoto::class, 'clientes_id');
    }

    // Status do cliente (Ativo, Inativo, Prospect etc)
    public function status()
    {
        return $this->belongsTo(StatusCliente::class, 'status_clientes_id');
    }

    // Usuário da equipe que criou o cliente
    public function equipe()
    {
        return $this->belongsTo(EquipeUsuario::class, 'equipe_usuarios_id');
    }

    // Imobiliária vinculada (crie o model se ainda não existir)
    public function imobiliaria()
    {
        return $this->belongsTo(Imobiliaria::class, 'imobiliarias_id');
    }

    // Corretor vinculado (crie o model se ainda não existir)
    public function corretor()
    {
        return $this->belongsTo(Corretor::class, 'corretores_id');
    }
}
