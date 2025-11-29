<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class QuantidadeParcelasDisponivel extends Model
{
    protected $table = 'quantidade_parcelas_disponiveis';

    protected $fillable = ['quantidade'];
}
