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
        if (Schema::hasTable('empreendimentos_documentos')) {
            return;
        }
        
        Schema::create('empreendimentos_documentos', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('empreendimentos_id');
            $table->unsignedBigInteger('tipos_documentos_id');
            $table->string('arquivo_url', 500); // URL pública do arquivo
            $table->string('nome_original', 255); // Nome original do arquivo
            $table->string('nome_salvo', 255); // Nome salvo no storage
            $table->string('tipo_mime', 100); // application/pdf, image/png, etc
            $table->unsignedBigInteger('tamanho_bytes')->nullable();
            $table->timestamps();

            // Indexes para performance
            $table->index('empreendimentos_id');
            $table->index('tipos_documentos_id');

            // Garantir que não haja documentos duplicados do mesmo tipo para o mesmo empreendimento
            $table->unique(['empreendimentos_id', 'tipos_documentos_id'], 'unique_emp_tipo_doc');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('empreendimentos_documentos');
    }
};
