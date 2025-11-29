<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class MotivoPerda extends Model
{
    use HasFactory;

    protected $table = 'motivos_perdas';

    protected $fillable = [
        'motivo',
        'ativo',
    ];

    protected $casts = [
        'ativo' => 'boolean',
    ];
}
