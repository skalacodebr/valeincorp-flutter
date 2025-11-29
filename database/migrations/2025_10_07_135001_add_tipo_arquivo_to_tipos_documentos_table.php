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
        if (Schema::hasTable('tipos_documentos') && !Schema::hasColumn('tipos_documentos', 'tipo_arquivo')) {
            Schema::table('tipos_documentos', function (Blueprint $table) {
                if (Schema::hasColumn('tipos_documentos', 'descricao')) {
                    $table->enum('tipo_arquivo', ['pdf', 'imagem'])->after('descricao');
                } else {
                    $table->enum('tipo_arquivo', ['pdf', 'imagem']);
                }
            });
        }
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
