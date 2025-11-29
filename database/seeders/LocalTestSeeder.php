<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

class LocalTestSeeder extends Seeder
{
    /**
     * Seed the application's database for local testing.
     */
    public function run(): void
    {
        // Status de Unidades
        DB::table('status_unidades')->insertOrIgnore([
            ['id' => 1, 'nome' => 'Disponível', 'cor' => '#10B981', 'created_at' => now(), 'updated_at' => now()],
            ['id' => 2, 'nome' => 'Reservada', 'cor' => '#F59E0B', 'created_at' => now(), 'updated_at' => now()],
            ['id' => 3, 'nome' => 'Vendida', 'cor' => '#EF4444', 'created_at' => now(), 'updated_at' => now()],
        ]);

        // Status de Empreendimentos
        DB::table('empreendimentos_status')->insertOrIgnore([
            ['id' => 1, 'nome' => 'Em Planejamento', 'created_at' => now(), 'updated_at' => now()],
            ['id' => 2, 'nome' => 'Em Construção', 'created_at' => now(), 'updated_at' => now()],
            ['id' => 3, 'nome' => 'Concluído', 'created_at' => now(), 'updated_at' => now()],
        ]);

        // Tipos de Empreendimento
        DB::table('tipo_empreendimento')->insertOrIgnore([
            ['id' => 1, 'nome' => 'Residencial', 'created_at' => now(), 'updated_at' => now()],
            ['id' => 2, 'nome' => 'Comercial', 'created_at' => now(), 'updated_at' => now()],
            ['id' => 3, 'nome' => 'Misto', 'created_at' => now(), 'updated_at' => now()],
        ]);

        // Tipos de Unidade
        DB::table('tipo_unidades')->insertOrIgnore([
            ['id' => 1, 'nome' => 'Apartamento', 'created_at' => now(), 'updated_at' => now()],
            ['id' => 2, 'nome' => 'Casa', 'created_at' => now(), 'updated_at' => now()],
            ['id' => 3, 'nome' => 'Sala Comercial', 'created_at' => now(), 'updated_at' => now()],
            ['id' => 4, 'nome' => 'Loja', 'created_at' => now(), 'updated_at' => now()],
        ]);

        // Status de Clientes (só insere se não existir)
        if (DB::table('status_clientes')->count() == 0) {
            DB::table('status_clientes')->insert([
                ['id' => 1, 'nome' => 'Novo', 'cor' => '#10B981', 'ordem' => 1, 'ativo' => true, 'created_at' => now(), 'updated_at' => now()],
                ['id' => 2, 'nome' => 'Em Contato', 'cor' => '#3B82F6', 'ordem' => 2, 'ativo' => true, 'created_at' => now(), 'updated_at' => now()],
                ['id' => 3, 'nome' => 'Negociando', 'cor' => '#F59E0B', 'ordem' => 3, 'ativo' => true, 'created_at' => now(), 'updated_at' => now()],
                ['id' => 4, 'nome' => 'Fechado', 'cor' => '#10B981', 'ordem' => 4, 'ativo' => true, 'created_at' => now(), 'updated_at' => now()],
                ['id' => 5, 'nome' => 'Perdido', 'cor' => '#EF4444', 'ordem' => 5, 'ativo' => true, 'created_at' => now(), 'updated_at' => now()],
            ]);
        }

        // Status de Negociações (só insere se não existir)
        if (DB::table('negociacoes_status')->count() == 0) {
            DB::table('negociacoes_status')->insert([
                ['id' => 1, 'nome' => 'Aberta', 'cor' => '#3B82F6', 'ordem' => 1, 'ativo' => true, 'created_at' => now(), 'updated_at' => now()],
                ['id' => 2, 'nome' => 'Em Andamento', 'cor' => '#F59E0B', 'ordem' => 2, 'ativo' => true, 'created_at' => now(), 'updated_at' => now()],
                ['id' => 3, 'nome' => 'Concluída', 'cor' => '#10B981', 'ordem' => 3, 'ativo' => true, 'created_at' => now(), 'updated_at' => now()],
                ['id' => 4, 'nome' => 'Cancelada', 'cor' => '#EF4444', 'ordem' => 4, 'ativo' => true, 'created_at' => now(), 'updated_at' => now()],
            ]);
        }

        // Imobiliária de teste
        DB::table('imobiliarias')->insertOrIgnore([
            'id' => 1,
            'nome' => 'Imobiliária Teste',
            'cnpj' => '00.000.000/0001-00',
            'email' => 'teste@imobiliaria.com',
            'telefone' => '(11) 99999-9999',
            'ativo' => true,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        // Corretor de teste
        DB::table('corretores')->insertOrIgnore([
            'id' => 1,
            'imobiliarias_id' => 1,
            'nome' => 'Corretor Teste',
            'cpf' => '000.000.000-00',
            'email' => 'corretor@teste.com',
            'telefone' => '(11) 99999-8888',
            'senha' => Hash::make('123456'),
            'creci' => 'CRECI-00000',
            'ativo' => true,
            'mostrar_venda' => 1,
            'mostrar_espelho' => true,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        // Empreendimento de teste
        DB::table('empreendimentos')->insertOrIgnore([
            'id' => 1,
            'nome' => 'Residencial Teste',
            'tipo_empreendimento_id' => 1,
            'tipo_unidades_id' => 1,
            'numero_total_unidade' => 50,
            'area_lazer' => true,
            'empreendimentos_status_id' => 2,
            'data_entrega' => '12/25',
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        // Torre de teste
        DB::table('empreendimentos_tores')->insertOrIgnore([
            'id' => 1,
            'empreendimentos_id' => 1,
            'nome' => 'Torre A',
            'numero_andares' => 10,
            'unidades_por_andar' => 4,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        // Algumas unidades de teste
        if (DB::table('empreendimentos_unidades')->count() == 0) {
            for ($andar = 1; $andar <= 3; $andar++) {
                for ($apt = 1; $apt <= 4; $apt++) {
                    DB::table('empreendimentos_unidades')->insert([
                        'empreendimentos_tores_id' => 1,
                        'numero_andar_apartamento' => $andar,
                        'numero_apartamento' => "{$andar}0{$apt}",
                        'tamanho_unidade_metros_quadrados' => rand(50, 120),
                        'valor' => rand(200000, 500000),
                        'numero_quartos' => rand(1, 3),
                        'numero_suites' => rand(0, 2),
                        'numero_banheiros' => rand(1, 2),
                        'status_unidades_id' => 1, // Disponível
                        'created_at' => now(),
                        'updated_at' => now(),
                    ]);
                }
            }
        }

        // Imóvel de teste
        DB::table('imoveis')->insertOrIgnore([
            'id' => 1,
            'titulo' => 'Apartamento Centro',
            'descricao' => 'Lindo apartamento no centro da cidade',
            'tipo' => 'Apartamento',
            'finalidade' => 'Venda',
            'valor' => 350000.00,
            'area' => 85.00,
            'quartos' => 2,
            'suites' => 1,
            'banheiros' => 2,
            'vagas' => 1,
            'bairro' => 'Centro',
            'cidade' => 'São Paulo',
            'estado' => 'SP',
            'ativo' => true,
            'corretor_id' => 1,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        $this->command->info('✅ Dados de teste criados com sucesso!');
        $this->command->info('📧 Login: corretor@teste.com');
        $this->command->info('🔑 Senha: 123456');
    }
}

