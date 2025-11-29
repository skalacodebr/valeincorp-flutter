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
        Schema::table('negociacoes_status', function (Blueprint $table) {
            if (!Schema::hasColumn('negociacoes_status', 'cor')) {
                $table->string('cor', 7)->default('#808080')->after('nome');
            }
            if (!Schema::hasColumn('negociacoes_status', 'ordem')) {
                $table->integer('ordem')->default(0)->after('cor');
                $table->index('ordem');
            }
            if (!Schema::hasColumn('negociacoes_status', 'ativo')) {
                $table->boolean('ativo')->default(true)->after('ordem');
                $table->index('ativo');
            }
        });

        // Atualizar registros existentes com cores e ordem apropriadas
        $statusData = [
            ['id' => 1, 'nome' => 'Aberta', 'cor' => '#3B82F6', 'ordem' => 1],
            ['id' => 2, 'nome' => 'Em Andamento', 'cor' => '#F59E0B', 'ordem' => 2],
            ['id' => 3, 'nome' => 'Concluída', 'cor' => '#10B981', 'ordem' => 3],
            ['id' => 4, 'nome' => 'Cancelada', 'cor' => '#EF4444', 'ordem' => 4],
        ];

        foreach ($statusData as $status) {
            DB::table('negociacoes_status')
                ->where('id', $status['id'])
                ->update([
                    'cor' => $status['cor'],
                    'ordem' => $status['ordem'],
                    'ativo' => true,
                    'updated_at' => now()
                ]);
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('negociacoes_status', function (Blueprint $table) {
            $table->dropIndex(['ordem']);
            $table->dropIndex(['ativo']);

            $table->dropColumn('cor');
            $table->dropColumn('ordem');
            $table->dropColumn('ativo');
        });
    }
};