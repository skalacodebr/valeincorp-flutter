<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class ClienteFoto extends Model
{
    use HasFactory;

    protected $table = 'clientes_foto';

    protected $fillable = [
        'clientes_id',
        'foto_url',
    ];

    public function cliente()
    {
        return $this->belongsTo(Cliente::class, 'clientes_id');
    }
}
