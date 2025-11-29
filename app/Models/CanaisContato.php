<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class CanaisContato extends Model
{
    use HasFactory;

    protected $table = 'canais_contato';

    protected $fillable = [
        'telefone',
        'email',
        'whatsapp',
        'perguntas',
    ];

    protected $casts = [
        'perguntas' => 'array',
    ];
}
