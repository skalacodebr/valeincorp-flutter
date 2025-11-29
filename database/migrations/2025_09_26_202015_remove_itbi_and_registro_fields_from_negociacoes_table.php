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
        // Só remove se as colunas existirem (não existem na base SQLite)
        Schema::table('negociacoes', function (Blueprint $table) {
            $columns = ['itbi_data_pagamento_protocolo', 'registro_imoveis_data_registro', 'numero_itbi'];
            foreach ($columns as $column) {
                if (Schema::hasColumn('negociacoes', $column)) {
                    $table->dropColumn($column);
                }
            }
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('negociacoes', function (Blueprint $table) {
            $table->date('itbi_data_pagamento_protocolo')->nullable();
            $table->date('registro_imoveis_data_registro')->nullable();
            $table->string('numero_itbi')->nullable();
        });
    }
};