<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\StatusCliente;
use App\Models\NegociacaoStatus;

class StatusSeeder extends Seeder
{
    public function run()
    {
        // Status dos Clientes
        $statusClientes = [
            ['nome' => 'Ativo'],
            ['nome' => 'Inativo'],
            ['nome' => 'Prospectivo'],
            ['nome' => 'Bloqueado'],
            ['nome' => 'Em Negociação']
        ];

        foreach ($statusClientes as $status) {
            StatusCliente::firstOrCreate($status);
        }

        // Status das Negociações
        $statusNegociacoes = [
            ['nome' => 'Em Análise'],
            ['nome' => 'Aprovada'],
            ['nome' => 'Finalizada'],
            ['nome' => 'Cancelada'],
            ['nome' => 'Em Andamento']
        ];

        foreach ($statusNegociacoes as $status) {
            NegociacaoStatus::firstOrCreate($status);
        }
    }
}