<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class EmpreendimentoImagemArquivo extends Model
{
    protected $table = 'empreendimentos_imagens_arquivos';

    protected $fillable = [
        'empreendimentos_id',
        'foto_url',
        'arquivo_url',
    ];

    public function empreendimento()
    {
        return $this->belongsTo(Empreendimento::class, 'empreendimentos_id');
    }
}
