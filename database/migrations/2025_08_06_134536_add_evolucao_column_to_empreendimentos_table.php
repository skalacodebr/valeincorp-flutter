<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        if (!Schema::hasColumn('empreendimentos', 'evolucao')) {
            Schema::table('empreendimentos', function (Blueprint $table) {
                $table->json('evolucao')->nullable()->after('observacoes')
                      ->comment('Array JSON com evoluções da obra: [{"id": 1, "percentual_conclusao": 45}]');
            });
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('empreendimentos', function (Blueprint $table) {
            $table->dropColumn('evolucao');
        });
    }
};
