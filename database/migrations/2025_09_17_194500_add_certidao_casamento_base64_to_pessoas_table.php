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
        if (!Schema::hasColumn('clientes_pessoas', 'certidao_casamento_base64')) {
            Schema::table('clientes_pessoas', function (Blueprint $table) {
                $table->longText('certidao_casamento_base64')->nullable();
            });
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('clientes_pessoas', function (Blueprint $table) {
            $table->dropColumn('certidao_casamento_base64');
        });
    }
};