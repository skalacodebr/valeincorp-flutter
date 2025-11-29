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
        // SQLite não suporta MODIFY COLUMN, ignoramos
        if (config('database.default') !== 'sqlite') {
            DB::statement("ALTER TABLE empreendimentos MODIFY COLUMN data_entrega VARCHAR(5) NULL COMMENT 'Data de entrega prevista no formato MM-AA (ex: 12-25)'");
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        // Reverter para o formato anterior
        DB::statement("ALTER TABLE empreendimentos MODIFY COLUMN data_entrega VARCHAR(5) NULL COMMENT 'Data de entrega prevista no formato MM/AA (ex: 12/25)'");
    }
};
