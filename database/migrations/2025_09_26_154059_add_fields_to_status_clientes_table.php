<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('status_clientes', function (Blueprint $table) {
            if (!Schema::hasColumn('status_clientes', 'cor')) {
                $table->string('cor', 7)->nullable()->after('nome');
            }
            if (!Schema::hasColumn('status_clientes', 'ordem')) {
                $table->integer('ordem')->default(0)->after('cor');
                $table->index('ordem');
            }
            if (!Schema::hasColumn('status_clientes', 'ativo')) {
                $table->boolean('ativo')->default(true)->after('ordem');
                $table->index('ativo');
            }
        });

        // Inserir status padrão apenas se a tabela estiver vazia
        $count = DB::table('status_clientes')->count();
        if ($count == 0) {
            DB::table('status_clientes')->insert([
                ['nome' => 'Novo', 'cor' => '#10B981', 'ordem' => 1, 'ativo' => true, 'created_at' => now(), 'updated_at' => now()],
                ['nome' => 'Em Contato', 'cor' => '#3B82F6', 'ordem' => 2, 'ativo' => true, 'created_at' => now(), 'updated_at' => now()],
                ['nome' => 'Em Análise', 'cor' => '#6366F1', 'ordem' => 3, 'ativo' => true, 'created_at' => now(), 'updated_at' => now()],
                ['nome' => 'Negociando', 'cor' => '#F59E0B', 'ordem' => 4, 'ativo' => true, 'created_at' => now(), 'updated_at' => now()],
                ['nome' => 'Documentação', 'cor' => '#8B5CF6', 'ordem' => 5, 'ativo' => true, 'created_at' => now(), 'updated_at' => now()],
                ['nome' => 'Fechado', 'cor' => '#10B981', 'ordem' => 6, 'ativo' => true, 'created_at' => now(), 'updated_at' => now()],
                ['nome' => 'Cancelado', 'cor' => '#EF4444', 'ordem' => 7, 'ativo' => true, 'created_at' => now(), 'updated_at' => now()],
                ['nome' => 'Perdido', 'cor' => '#DC2626', 'ordem' => 8, 'ativo' => true, 'created_at' => now(), 'updated_at' => now()],
            ]);
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('status_clientes', function (Blueprint $table) {
            $table->dropIndex(['ordem']);
            $table->dropIndex(['ativo']);

            $table->dropColumn('cor');
            $table->dropColumn('ordem');
            $table->dropColumn('ativo');
        });
    }
};