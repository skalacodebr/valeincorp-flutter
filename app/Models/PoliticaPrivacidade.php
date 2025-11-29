<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class PoliticaPrivacidade extends Model
{
    use HasFactory;

    protected $table = 'politica_privacidade';

    protected $fillable = [
        'conteudo',
    ];
}
