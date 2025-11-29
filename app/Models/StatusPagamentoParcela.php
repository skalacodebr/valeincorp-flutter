<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class StatusPagamentoParcela extends Model
{
    protected $table = 'status_pagamentos_parcelas';

    protected $fillable = ['nome'];
}
