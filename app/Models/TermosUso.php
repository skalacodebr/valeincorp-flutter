<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class TermosUso extends Model
{
    use HasFactory;

    protected $table = 'termos_uso';

    protected $fillable = [
        'conteudo',
    ];
}
