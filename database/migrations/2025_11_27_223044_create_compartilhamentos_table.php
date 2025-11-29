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
        if (Schema::hasTable('compartilhamentos')) {
            return;
        }

        Schema::create('compartilhamentos', function (Blueprint $table) {
            $table->id();
            $table->foreignId('corretor_id')->constrained('corretores')->onDelete('cascade');
            $table->string('entity_type')->comment('empreendimento ou unidade');
            $table->unsignedBigInteger('entity_id')->comment('ID do empreendimento ou unidade');
            $table->string('link_unico', 64)->unique()->comment('Token único para o link compartilhado');
            $table->string('nome_cliente')->nullable()->comment('Nome do cliente para quem foi compartilhado');
            $table->text('anotacao')->nullable()->comment('Observações do corretor');
            $table->boolean('receber_notificacao')->default(false)->comment('Receber notificação quando link for acessado');
            $table->boolean('mostrar_espelho_vendas')->default(false)->comment('Disponibilizar espelho de vendas');
            $table->boolean('mostrar_endereco')->default(true)->comment('Mostrar endereço completo');
            $table->boolean('compartilhar_descricao')->default(true)->comment('Compartilhar descrição do empreendimento');
            $table->unsignedInteger('total_visualizacoes')->default(0)->comment('Contador de visualizações');
            $table->timestamp('ultima_visualizacao_at')->nullable()->comment('Timestamp da última visualização');
            $table->boolean('ativo')->default(true)->comment('Link ativo ou desativado');
            $table->timestamp('expira_em')->nullable()->comment('Data de expiração do link (opcional)');
            $table->timestamps();

            // Índices para otimizar consultas
            $table->index(['corretor_id', 'ativo']);
            $table->index(['entity_type', 'entity_id']);
            $table->index('link_unico');
            $table->index('created_at');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('compartilhamentos');
    }
};
