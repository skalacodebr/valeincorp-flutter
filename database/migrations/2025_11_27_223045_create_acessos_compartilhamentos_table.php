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
        if (Schema::hasTable('acessos_compartilhamentos')) {
            return;
        }

        Schema::create('acessos_compartilhamentos', function (Blueprint $table) {
            $table->id();
            $table->foreignId('compartilhamento_id')->constrained('compartilhamentos')->onDelete('cascade');
            $table->string('ip_address', 45)->nullable()->comment('IP do visitante');
            $table->text('user_agent')->nullable()->comment('User agent do navegador');
            $table->timestamp('acessado_at')->useCurrent()->comment('Timestamp do acesso');
            $table->string('referer')->nullable()->comment('URL de origem (opcional)');
            $table->timestamps();

            // Índices para otimizar consultas
            $table->index('compartilhamento_id');
            $table->index('acessado_at');
            $table->index(['compartilhamento_id', 'acessado_at']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('acessos_compartilhamentos');
    }
};
