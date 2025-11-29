<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class StatusLead extends Model
{
    use HasFactory;

    protected $table = 'status_leads';

    protected $fillable = [
        'nome',
        'cor',
        'ordem',
        'ativo',
    ];

    protected $casts = [
        'ativo' => 'boolean',
        'ordem' => 'integer',
    ];
}
