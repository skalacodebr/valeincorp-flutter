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
        if (Schema::hasTable('favoritos')) {
            return;
        }
        
        Schema::create('favoritos', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('corretor_id');
            $table->unsignedBigInteger('empreendimento_id');
            $table->timestamps();
            
            // Índices para performance
            $table->index('corretor_id');
            $table->index('empreendimento_id');
            $table->index(['corretor_id', 'empreendimento_id']);
            
            // Evitar duplicatas - um corretor pode favoritar o mesmo empreendimento apenas uma vez
            $table->unique(['corretor_id', 'empreendimento_id'], 'unique_favorito');
            
            // Foreign Keys
            $table->foreign('corretor_id')->references('id')->on('corretores')->onDelete('cascade');
            $table->foreign('empreendimento_id')->references('id')->on('empreendimentos')->onDelete('cascade');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('favoritos');
    }
};