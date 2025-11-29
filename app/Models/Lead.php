<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Lead extends Model
{
    protected $table = 'leads';

    protected $fillable = [
        'nome',
        'email',
        'telefone',
        'profissao',
        'origens_leads_id',
        'status_leads',
        'observacoes',
        'motivo',
        'data_entrada',
    ];

    public function origem()
    {
        return $this->belongsTo(OrigemLead::class, 'origens_leads_id');
    }

    public function status()
    {
        return $this->belongsTo(StatusLead::class, 'status_leads');
    }
}
