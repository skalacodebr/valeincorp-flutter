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
        if (Schema::hasTable('evolucao_obras')) {
            return;
        }
        
        Schema::create('evolucao_obras', function (Blueprint $table) {
            $table->id();
            $table->string('nome');
            $table->date('data_criacao');
            $table->foreignId('empreendimento_id')->constrained('empreendimentos')->onDelete('cascade');
            $table->text('descricao')->nullable();
            $table->integer('percentual_conclusao')->default(0);
            $table->foreignId('created_by')->nullable()->constrained('users');
            $table->foreignId('updated_by')->nullable()->constrained('users');
            $table->timestamps();
            $table->softDeletes();
            
            $table->index('empreendimento_id');
            $table->index('data_criacao');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('evolucao_obras');
    }
};
