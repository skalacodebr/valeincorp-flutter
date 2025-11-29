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
        // SQLite não suporta renameColumn ou ALTER bem, ignoramos para SQLite
        if (config('database.default') !== 'sqlite' && Schema::hasTable('negociacoes')) {
            Schema::table('negociacoes', function (Blueprint $table) {
                if (Schema::hasColumn('negociacoes', 'parcelas_construtora_data_pagamento')) {
                    $table->dropColumn('parcelas_construtora_data_pagamento');
                }
                if (Schema::hasColumn('negociacoes', 'parcelas_construtora_numero')) {
                    $table->renameColumn('parcelas_construtora_numero', 'parcelas_documentacao_construtora');
                }
            });
            if (Schema::hasColumn('negociacoes', 'parcelas_documentacao_construtora')) {
                DB::statement("ALTER TABLE negociacoes MODIFY COLUMN parcelas_documentacao_construtora INT NULL COMMENT 'Número de parcelas da documentação da construtora'");
            }
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('negociacoes', function (Blueprint $table) {
            // Reverter renomeação
            $table->renameColumn('parcelas_documentacao_construtora', 'parcelas_construtora_numero');

            // Recriar campo de data
            $table->date('parcelas_construtora_data_pagamento')->nullable()->after('parcelas_construtora_numero');
        });
    }
};