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
        Schema::table('tipos_documentos', function (Blueprint $table) {
            $table->enum('tipo_arquivo', ['pdf', 'imagem'])->after('descricao');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('tipos_documentos', function (Blueprint $table) {
            $table->dropColumn('tipo_arquivo');
        });
    }
};
