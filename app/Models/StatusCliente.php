<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class StatusCliente extends Model
{
    use HasFactory;

    protected $table = 'status_clientes';

    protected $fillable = [
        'nome',
        'cor',
        'ordem',
        'ativo'
    ];

    protected $casts = [
        'ativo' => 'boolean',
        'ordem' => 'integer'
    ];

    protected $hidden = [
        'created_at',
        'updated_at'
    ];

    public function clientes()
    {
        return $this->hasMany(Cliente::class, 'status_clientes_id');
    }
}
