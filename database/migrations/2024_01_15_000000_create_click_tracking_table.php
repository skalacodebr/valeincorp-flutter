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
        if (Schema::hasTable('click_tracking')) {
            return;
        }
        
        Schema::create('click_tracking', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('user_id')->nullable()->comment('ID do usuário que fez o clique (pode ser null para usuários não logados)');
            $table->string('entity_type')->comment('Tipo da entidade: empreendimento ou unidade');
            $table->unsignedBigInteger('entity_id')->comment('ID do empreendimento ou unidade');
            $table->string('action_type')->comment('Tipo da ação: view (visualização) ou share (compartilhamento)');
            $table->string('share_platform')->nullable()->comment('Plataforma de compartilhamento: whatsapp, link, facebook, twitter, instagram');
            $table->string('ip_address', 45)->nullable()->comment('Endereço IP do usuário');
            $table->text('user_agent')->nullable()->comment('User Agent do navegador');
            $table->date('click_date')->comment('Data do clique (dd/mm/yy)');
            $table->timestamp('clicked_at')->useCurrent()->comment('Timestamp exato do clique');
            $table->timestamps();

            // Índices para otimizar consultas
            $table->index(['entity_type', 'entity_id', 'click_date'], 'click_tracking_entity_type_entity_id_click_date_index');
            $table->index(['user_id', 'click_date'], 'click_tracking_user_id_click_date_index');
            $table->index(['action_type', 'click_date'], 'click_tracking_action_type_click_date_index');
            $table->index('click_date', 'click_tracking_click_date_index');
            
            // Índices adicionais para relatórios
            $table->index(['entity_type', 'entity_id', 'action_type', 'click_date'], 'idx_click_tracking_entity_stats');
            $table->index(['entity_type', 'entity_id', 'action_type', 'share_platform', 'click_date'], 'idx_click_tracking_share_stats');
            $table->index(['click_date', 'action_type', 'entity_type'], 'idx_click_tracking_daily_stats');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('click_tracking');
    }
};
