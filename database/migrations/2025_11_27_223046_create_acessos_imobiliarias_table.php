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
        if (Schema::hasTable('acessos_imobiliarias')) {
            return;
        }

        Schema::create('acessos_imobiliarias', function (Blueprint $table) {
            $table->id();
            $table->foreignId('imobiliaria_id')->nullable()->constrained('imobiliarias')->onDelete('set null');
            $table->foreignId('user_id')->nullable()->constrained('users')->onDelete('set null');
            $table->string('tipo_acesso')->comment('login, app_open, api_call');
            $table->string('ip_address', 45)->nullable()->comment('IP do acesso');
            $table->text('user_agent')->nullable()->comment('User agent');
            $table->timestamp('acessado_at')->useCurrent()->comment('Timestamp do acesso');
            $table->json('detalhes')->nullable()->comment('Informações adicionais em JSON');
            $table->timestamps();

            // Índices para otimizar consultas
            $table->index(['imobiliaria_id', 'acessado_at']);
            $table->index(['user_id', 'acessado_at']);
            $table->index('tipo_acesso');
            $table->index('acessado_at');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('acessos_imobiliarias');
    }
};
