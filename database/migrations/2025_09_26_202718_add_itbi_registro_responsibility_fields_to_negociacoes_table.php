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
        Schema::table('negociacoes', function (Blueprint $table) {
            // Usando boolean ao invés de enum para compatibilidade com SQLite
            if (!Schema::hasColumn('negociacoes', 'itbi_responsabilidade_cliente')) {
                $table->boolean('itbi_responsabilidade_cliente')->default(false);
            }
            if (!Schema::hasColumn('negociacoes', 'registro_responsabilidade_cliente')) {
                $table->boolean('registro_responsabilidade_cliente')->default(false);
            }
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('negociacoes', function (Blueprint $table) {
            $table->dropColumn(['itbi_responsavel', 'registro_responsavel']);
        });
    }
};