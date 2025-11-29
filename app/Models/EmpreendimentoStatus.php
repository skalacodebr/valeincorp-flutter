<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class EmpreendimentoStatus extends Model
{
    protected $table = 'empreendimentos_status';

    protected $fillable = ['nome'];
}
