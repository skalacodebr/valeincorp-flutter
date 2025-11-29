<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class StatusClienteSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Limpar tabela antes de inserir (apenas em desenvolvimento)
        if (app()->environment('local', 'development')) {
            DB::table('status_clientes')->truncate();
        }

        // Status padrão seguindo o processo de vendas/relacionamento com clientes
        $statusClientes = [
            [
                'nome' => 'Potencial',
                'cor' => '#10B981',
                'ordem' => 1,
                'ativo' => true,
                'created_at' => now(),
                'updated_at' => now()
            ],
            [
                'nome' => 'Contato Feito',
                'cor' => '#3B82F6',
                'ordem' => 2,
                'ativo' => true,
                'created_at' => now(),
                'updated_at' => now()
            ],
            [
                'nome' => 'Qualificado',
                'cor' => '#6366F1',
                'ordem' => 3,
                'ativo' => true,
                'created_at' => now(),
                'updated_at' => now()
            ],
            [
                'nome' => 'Em Negociação',
                'cor' => '#F59E0B',
                'ordem' => 4,
                'ativo' => true,
                'created_at' => now(),
                'updated_at' => now()
            ],
            [
                'nome' => 'Proposta Enviada',
                'cor' => '#FF6347',
                'ordem' => 5,
                'ativo' => true,
                'created_at' => now(),
                'updated_at' => now()
            ],
            [
                'nome' => 'Cliente Ativo',
                'cor' => '#228B22',
                'ordem' => 6,
                'ativo' => true,
                'created_at' => now(),
                'updated_at' => now()
            ],
            [
                'nome' => 'Documentação',
                'cor' => '#8B5CF6',
                'ordem' => 7,
                'ativo' => true,
                'created_at' => now(),
                'updated_at' => now()
            ],
            [
                'nome' => 'Ex-cliente',
                'cor' => '#DC2626',
                'ordem' => 8,
                'ativo' => true,
                'created_at' => now(),
                'updated_at' => now()
            ],
            [
                'nome' => 'Cancelado',
                'cor' => '#EF4444',
                'ordem' => 9,
                'ativo' => true,
                'created_at' => now(),
                'updated_at' => now()
            ],
            [
                'nome' => 'Inativo',
                'cor' => '#808080',
                'ordem' => 10,
                'ativo' => false, // Este status começa desativado
                'created_at' => now(),
                'updated_at' => now()
            ]
        ];

        // Inserir apenas se não existirem registros
        if (DB::table('status_clientes')->count() == 0) {
            DB::table('status_clientes')->insert($statusClientes);
        }
    }
}