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
        // SQLite não suporta change(), já criamos com longText na base
        if (config('database.default') !== 'sqlite' && Schema::hasTable('clientes_fotos')) {
            Schema::table('clientes_fotos', function (Blueprint $table) {
                $table->longText('foto_url')->nullable()->change();
            });
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('clientes_foto', function (Blueprint $table) {
            $table->text('foto_url')->nullable()->change();
        });
    }
};
