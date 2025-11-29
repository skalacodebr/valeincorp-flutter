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
        // SQLite não suporta change(), já criamos com o tipo correto na base
        if (config('database.default') !== 'sqlite') {
            Schema::table('negociacoes', function (Blueprint $table) {
                $table->decimal('permuta', 12, 2)->nullable()->change();
            });
            DB::statement("ALTER TABLE negociacoes MODIFY COLUMN permuta DECIMAL(12,2) NULL COMMENT 'Valor monetário da permuta (não porcentagem)'");
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('negociacoes', function (Blueprint $table) {
            $table->decimal('permuta', 6, 2)->nullable()->change();
        });

        // Remover comentário
        DB::statement("ALTER TABLE negociacoes MODIFY COLUMN permuta DECIMAL(6,2) NULL");
    }
};
