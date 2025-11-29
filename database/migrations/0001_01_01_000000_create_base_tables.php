<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations - Cria todas as tabelas base do sistema
     */
    public function up(): void
    {
        // ========================================
        // TABELAS DE LOOKUP / AUXILIARES
        // ========================================
        
        Schema::create('users', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('email')->unique();
            $table->timestamp('email_verified_at')->nullable();
            $table->string('password');
            $table->rememberToken();
            $table->timestamps();
        });

        Schema::create('sessions', function (Blueprint $table) {
            $table->string('id')->primary();
            $table->foreignId('user_id')->nullable()->index();
            $table->string('ip_address', 45)->nullable();
            $table->text('user_agent')->nullable();
            $table->longText('payload');
            $table->integer('last_activity')->index();
        });

        Schema::create('cache', function (Blueprint $table) {
            $table->string('key')->primary();
            $table->mediumText('value');
            $table->integer('expiration');
        });

        Schema::create('cache_locks', function (Blueprint $table) {
            $table->string('key')->primary();
            $table->string('owner');
            $table->integer('expiration');
        });

        Schema::create('personal_access_tokens', function (Blueprint $table) {
            $table->id();
            $table->morphs('tokenable');
            $table->string('name');
            $table->string('token', 64)->unique();
            $table->text('abilities')->nullable();
            $table->timestamp('last_used_at')->nullable();
            $table->timestamp('expires_at')->nullable();
            $table->timestamps();
        });

        Schema::create('tipo_empreendimento', function (Blueprint $table) {
            $table->id();
            $table->string('nome');
            $table->timestamps();
        });

        Schema::create('tipo_unidades', function (Blueprint $table) {
            $table->id();
            $table->string('nome');
            $table->timestamps();
        });

        Schema::create('status_unidades', function (Blueprint $table) {
            $table->id();
            $table->string('nome');
            $table->string('cor')->nullable();
            $table->timestamps();
        });

        Schema::create('empreendimentos_status', function (Blueprint $table) {
            $table->id();
            $table->string('nome');
            $table->timestamps();
        });

        Schema::create('tipo_area_lazer', function (Blueprint $table) {
            $table->id();
            $table->string('nome');
            $table->timestamps();
        });

        Schema::create('tipos_medida_unidades', function (Blueprint $table) {
            $table->id();
            $table->string('nome');
            $table->timestamps();
        });

        Schema::create('cargos', function (Blueprint $table) {
            $table->id();
            $table->string('nome');
            $table->timestamps();
        });

        Schema::create('permissoes', function (Blueprint $table) {
            $table->id();
            $table->string('nome');
            $table->text('descricao')->nullable();
            $table->timestamps();
        });

        Schema::create('status_leads', function (Blueprint $table) {
            $table->id();
            $table->string('nome');
            $table->timestamps();
        });

        Schema::create('origens_leads', function (Blueprint $table) {
            $table->id();
            $table->string('nome');
            $table->timestamps();
        });

        Schema::create('status_clientes', function (Blueprint $table) {
            $table->id();
            $table->string('nome');
            $table->string('cor')->nullable();
            $table->integer('ordem')->default(0);
            $table->boolean('ativo')->default(true);
            $table->timestamps();
        });

        Schema::create('negociacoes_status', function (Blueprint $table) {
            $table->id();
            $table->string('nome');
            $table->string('cor')->nullable();
            $table->integer('ordem')->default(0);
            $table->boolean('ativo')->default(true);
            $table->timestamps();
        });

        Schema::create('formas_pagamento', function (Blueprint $table) {
            $table->id();
            $table->string('nome');
            $table->timestamps();
        });

        Schema::create('modalidades_vendas', function (Blueprint $table) {
            $table->id();
            $table->string('nome');
            $table->timestamps();
        });

        Schema::create('situacoes_vendas', function (Blueprint $table) {
            $table->id();
            $table->string('nome');
            $table->timestamps();
        });

        Schema::create('ibti_registro_vendas', function (Blueprint $table) {
            $table->id();
            $table->string('nome');
            $table->timestamps();
        });

        Schema::create('conformidades_vendas', function (Blueprint $table) {
            $table->id();
            $table->string('nome');
            $table->timestamps();
        });

        Schema::create('status_pagamentos_parcelas', function (Blueprint $table) {
            $table->id();
            $table->string('nome');
            $table->timestamps();
        });

        Schema::create('quantidade_parcelas_disponiveis', function (Blueprint $table) {
            $table->id();
            $table->integer('quantidade');
            $table->timestamps();
        });

        // ========================================
        // TABELAS PRINCIPAIS
        // ========================================

        Schema::create('construtores', function (Blueprint $table) {
            $table->id();
            $table->string('nome');
            $table->string('cnpj')->nullable();
            $table->string('email')->nullable();
            $table->string('telefone')->nullable();
            $table->timestamps();
        });

        Schema::create('imobiliarias', function (Blueprint $table) {
            $table->id();
            $table->string('nome');
            $table->string('cnpj')->nullable();
            $table->string('email')->nullable();
            $table->string('telefone')->nullable();
            $table->string('logo_url')->nullable();
            $table->boolean('ativo')->default(true);
            $table->timestamps();
        });

        Schema::create('imobiliarias_endereco', function (Blueprint $table) {
            $table->id();
            $table->foreignId('imobiliarias_id')->constrained('imobiliarias')->onDelete('cascade');
            $table->string('cep')->nullable();
            $table->string('logradouro')->nullable();
            $table->string('numero')->nullable();
            $table->string('complemento')->nullable();
            $table->string('bairro')->nullable();
            $table->string('cidade')->nullable();
            $table->string('estado')->nullable();
            $table->timestamps();
        });

        Schema::create('imobiliarias_responsaveis', function (Blueprint $table) {
            $table->id();
            $table->foreignId('imobiliarias_id')->constrained('imobiliarias')->onDelete('cascade');
            $table->string('nome');
            $table->string('cpf')->nullable();
            $table->string('email')->nullable();
            $table->string('telefone')->nullable();
            $table->timestamps();
        });

        Schema::create('corretores', function (Blueprint $table) {
            $table->id();
            $table->foreignId('imobiliarias_id')->nullable()->constrained('imobiliarias')->onDelete('set null');
            $table->string('nome');
            $table->string('cpf')->nullable();
            $table->string('email')->unique();
            $table->string('telefone')->nullable();
            $table->string('senha');
            $table->string('creci')->nullable();
            $table->text('documento_url')->nullable();
            $table->text('avatar_url')->nullable();
            $table->boolean('ativo')->default(true);
            $table->string('token')->nullable();
            $table->integer('mostrar_venda')->default(0);
            $table->boolean('mostrar_espelho')->default(true);
            $table->rememberToken();
            $table->timestamps();
        });

        Schema::create('equipe_usuarios', function (Blueprint $table) {
            $table->id();
            $table->string('nome');
            $table->string('email')->unique();
            $table->string('senha');
            $table->foreignId('cargo_id')->nullable()->constrained('cargos')->onDelete('set null');
            $table->boolean('ativo')->default(true);
            $table->rememberToken();
            $table->timestamps();
        });

        Schema::create('equipe_permissoes', function (Blueprint $table) {
            $table->id();
            $table->foreignId('equipe_usuario_id')->constrained('equipe_usuarios')->onDelete('cascade');
            $table->foreignId('permissao_id')->constrained('permissoes')->onDelete('cascade');
            $table->timestamps();
        });

        // ========================================
        // EMPREENDIMENTOS E RELACIONADOS
        // ========================================

        Schema::create('empreendimentos', function (Blueprint $table) {
            $table->id();
            $table->string('nome');
            $table->foreignId('tipo_empreendimento_id')->nullable()->constrained('tipo_empreendimento')->onDelete('set null');
            $table->foreignId('tipo_unidades_id')->nullable()->constrained('tipo_unidades')->onDelete('set null');
            $table->integer('numero_total_unidade')->nullable();
            $table->decimal('tamanho_total_comum_unidade_metros_quadrados', 10, 2)->nullable();
            $table->boolean('area_lazer')->default(false);
            $table->decimal('area_total', 10, 2)->nullable();
            $table->text('observacoes')->nullable();
            $table->foreignId('empreendimentos_status_id')->nullable()->constrained('empreendimentos_status')->onDelete('set null');
            $table->string('data_entrega')->nullable();
            $table->foreignId('equipe_usuarios_id')->nullable()->constrained('equipe_usuarios')->onDelete('set null');
            $table->longText('memorial_descritivo_base64')->nullable();
            $table->longText('catalogo_pdf_base64')->nullable();
            $table->text('memorial_descritivo_url')->nullable();
            $table->text('catalogo_pdf_url')->nullable();
            $table->json('evolucao')->nullable();
            $table->text('imagem_empreendimento')->nullable();
            $table->timestamps();
        });

        Schema::create('empreendimentos_endereco', function (Blueprint $table) {
            $table->id();
            $table->foreignId('empreendimentos_id')->constrained('empreendimentos')->onDelete('cascade');
            $table->string('cep')->nullable();
            $table->string('logradouro')->nullable();
            $table->string('numero')->nullable();
            $table->string('complemento')->nullable();
            $table->string('bairro')->nullable();
            $table->string('cidade')->nullable();
            $table->string('estado')->nullable();
            $table->decimal('latitude', 10, 8)->nullable();
            $table->decimal('longitude', 11, 8)->nullable();
            $table->timestamps();
        });

        Schema::create('empreendimentos_area_lazer', function (Blueprint $table) {
            $table->id();
            $table->foreignId('empreendimentos_id')->constrained('empreendimentos')->onDelete('cascade');
            $table->foreignId('tipo_area_lazer_id')->nullable()->constrained('tipo_area_lazer')->onDelete('set null');
            $table->string('nome')->nullable();
            $table->text('descricao')->nullable();
            $table->timestamps();
        });

        Schema::create('empreendimentos_imagens_arquivos', function (Blueprint $table) {
            $table->id();
            $table->foreignId('empreendimentos_id')->constrained('empreendimentos')->onDelete('cascade');
            $table->text('url');
            $table->string('tipo')->nullable();
            $table->timestamps();
        });

        Schema::create('empreendimentos_tores', function (Blueprint $table) {
            $table->id();
            $table->foreignId('empreendimentos_id')->constrained('empreendimentos')->onDelete('cascade');
            $table->string('nome');
            $table->integer('numero_andares')->nullable();
            $table->integer('unidades_por_andar')->nullable();
            $table->timestamps();
        });

        Schema::create('empreendimentos_tores_excessao', function (Blueprint $table) {
            $table->id();
            $table->foreignId('empreendimentos_tores_id')->constrained('empreendimentos_tores')->onDelete('cascade');
            $table->integer('andar');
            $table->integer('quantidade_unidades');
            $table->timestamps();
        });

        Schema::create('empreendimentos_unidades', function (Blueprint $table) {
            $table->id();
            $table->foreignId('empreendimentos_tores_id')->constrained('empreendimentos_tores')->onDelete('cascade');
            $table->integer('numero_andar_apartamento')->nullable();
            $table->string('numero_apartamento')->nullable();
            $table->decimal('tamanho_unidade_metros_quadrados', 10, 2)->nullable();
            $table->decimal('valor', 15, 2)->nullable();
            $table->integer('numero_quartos')->nullable();
            $table->integer('numero_suites')->nullable();
            $table->integer('numero_banheiros')->nullable();
            $table->foreignId('status_unidades_id')->nullable()->constrained('status_unidades')->onDelete('set null');
            $table->text('observacao')->nullable();
            $table->string('posicao')->nullable();
            $table->timestamps();
        });

        Schema::create('empreendimentos_unidades_vagas_garem', function (Blueprint $table) {
            $table->id();
            $table->foreignId('unidade_id')->constrained('empreendimentos_unidades')->onDelete('cascade');
            $table->string('numero')->nullable();
            $table->string('tipo')->nullable();
            $table->timestamps();
        });

        Schema::create('medidas_unidades', function (Blueprint $table) {
            $table->id();
            $table->foreignId('unidade_id')->constrained('empreendimentos_unidades')->onDelete('cascade');
            $table->foreignId('tipo_medida_unidade_id')->nullable()->constrained('tipos_medida_unidades')->onDelete('set null');
            $table->decimal('valor', 10, 2)->nullable();
            $table->timestamps();
        });

        Schema::create('empreendimentos_unidades_fotos', function (Blueprint $table) {
            $table->id();
            $table->foreignId('empreendimentos_tores_id')->constrained('empreendimentos_tores')->onDelete('cascade');
            $table->text('url');
            $table->string('legenda')->nullable();
            $table->foreignId('categoria_foto_id')->nullable();
            $table->timestamps();
        });

        Schema::create('empreendimentos_unidades_videos', function (Blueprint $table) {
            $table->id();
            $table->foreignId('empreendimentos_tores_id')->constrained('empreendimentos_tores')->onDelete('cascade');
            $table->text('url')->nullable();
            $table->string('titulo')->nullable();
            $table->text('descricao')->nullable();
            $table->string('tipo')->nullable();
            $table->timestamps();
        });

        // ========================================
        // CLIENTES
        // ========================================

        Schema::create('clientes', function (Blueprint $table) {
            $table->id();
            $table->string('nome');
            $table->string('cpf')->nullable();
            $table->string('email')->nullable();
            $table->string('telefone')->nullable();
            $table->string('estado_civil')->nullable();
            $table->foreignId('status_cliente_id')->nullable()->constrained('status_clientes')->onDelete('set null');
            $table->foreignId('corretor_id')->nullable()->constrained('corretores')->onDelete('set null');
            $table->text('observacoes')->nullable();
            $table->timestamps();
        });

        Schema::create('clientes_endereco', function (Blueprint $table) {
            $table->id();
            $table->foreignId('cliente_id')->constrained('clientes')->onDelete('cascade');
            $table->string('cep')->nullable();
            $table->string('logradouro')->nullable();
            $table->string('numero')->nullable();
            $table->string('complemento')->nullable();
            $table->string('bairro')->nullable();
            $table->string('cidade')->nullable();
            $table->string('estado')->nullable();
            $table->timestamps();
        });

        Schema::create('clientes_foto', function (Blueprint $table) {
            $table->id();
            $table->foreignId('cliente_id')->constrained('clientes')->onDelete('cascade');
            $table->longText('foto_url')->nullable();
            $table->timestamps();
        });

        Schema::create('clientes_pessoas', function (Blueprint $table) {
            $table->id();
            $table->foreignId('cliente_id')->constrained('clientes')->onDelete('cascade');
            $table->string('nome');
            $table->string('cpf')->nullable();
            $table->string('rg')->nullable();
            $table->string('email')->nullable();
            $table->string('telefone')->nullable();
            $table->string('parentesco')->nullable();
            $table->longText('documento_frente_base64')->nullable();
            $table->longText('documento_verso_base64')->nullable();
            $table->longText('certidao_casamento_base64')->nullable();
            $table->timestamps();
        });

        // ========================================
        // LEADS
        // ========================================

        Schema::create('leads', function (Blueprint $table) {
            $table->id();
            $table->string('nome');
            $table->string('email')->nullable();
            $table->string('telefone')->nullable();
            $table->foreignId('status_lead_id')->nullable()->constrained('status_leads')->onDelete('set null');
            $table->foreignId('origem_lead_id')->nullable()->constrained('origens_leads')->onDelete('set null');
            $table->foreignId('corretor_id')->nullable()->constrained('corretores')->onDelete('set null');
            $table->foreignId('empreendimento_id')->nullable()->constrained('empreendimentos')->onDelete('set null');
            $table->text('observacoes')->nullable();
            $table->timestamps();
        });

        // ========================================
        // NEGOCIAÇÕES
        // ========================================

        Schema::create('negociacoes', function (Blueprint $table) {
            $table->id();
            $table->foreignId('cliente_id')->nullable()->constrained('clientes')->onDelete('set null');
            $table->foreignId('corretor_id')->nullable()->constrained('corretores')->onDelete('set null');
            $table->foreignId('unidade_id')->nullable()->constrained('empreendimentos_unidades')->onDelete('set null');
            $table->foreignId('negociacoes_status_id')->nullable()->constrained('negociacoes_status')->onDelete('set null');
            $table->foreignId('forma_pagamento_id')->nullable()->constrained('formas_pagamento')->onDelete('set null');
            $table->foreignId('modalidade_venda_id')->nullable()->constrained('modalidades_vendas')->onDelete('set null');
            $table->foreignId('situacao_venda_id')->nullable()->constrained('situacoes_vendas')->onDelete('set null');
            $table->foreignId('conformidade_venda_id')->nullable()->constrained('conformidades_vendas')->onDelete('set null');
            $table->decimal('valor_venda', 15, 2)->nullable();
            $table->decimal('valor_entrada', 15, 2)->nullable();
            $table->decimal('valor_financiamento', 15, 2)->nullable();
            $table->decimal('valor_permuta', 15, 2)->nullable();
            $table->text('descricao_permuta')->nullable();
            $table->integer('parcelas_construtora_qtd')->nullable();
            $table->decimal('parcelas_construtora_valor', 15, 2)->nullable();
            $table->string('parcelas_construtora_vencimento')->nullable();
            $table->boolean('itbi_responsabilidade_cliente')->default(false);
            $table->boolean('registro_responsabilidade_cliente')->default(false);
            $table->text('observacoes')->nullable();
            $table->timestamps();
        });

        Schema::create('pagamentos', function (Blueprint $table) {
            $table->id();
            $table->foreignId('negociacao_id')->constrained('negociacoes')->onDelete('cascade');
            $table->decimal('valor', 15, 2)->nullable();
            $table->date('data_pagamento')->nullable();
            $table->string('tipo')->nullable();
            $table->timestamps();
        });

        Schema::create('pagamentos_parcelas', function (Blueprint $table) {
            $table->id();
            $table->foreignId('negociacao_id')->constrained('negociacoes')->onDelete('cascade');
            $table->integer('numero_parcela');
            $table->decimal('valor', 15, 2)->nullable();
            $table->date('data_vencimento')->nullable();
            $table->date('data_pagamento')->nullable();
            $table->foreignId('status_pagamento_parcela_id')->nullable()->constrained('status_pagamentos_parcelas')->onDelete('set null');
            $table->timestamps();
        });

        Schema::create('historico_pagamentos', function (Blueprint $table) {
            $table->id();
            $table->foreignId('negociacao_id')->constrained('negociacoes')->onDelete('cascade');
            $table->text('descricao')->nullable();
            $table->decimal('valor', 15, 2)->nullable();
            $table->date('data')->nullable();
            $table->timestamps();
        });

        // ========================================
        // TABELAS AUXILIARES FALTANTES
        // ========================================

        Schema::create('canais_contato', function (Blueprint $table) {
            $table->id();
            $table->string('nome');
            $table->timestamps();
        });

        Schema::create('tipos_documentos', function (Blueprint $table) {
            $table->id();
            $table->string('nome');
            $table->timestamps();
        });

        Schema::create('categorias_fotos', function (Blueprint $table) {
            $table->id();
            $table->string('nome');
            $table->timestamps();
        });

        Schema::create('motivos_perdas', function (Blueprint $table) {
            $table->id();
            $table->string('nome');
            $table->timestamps();
        });

        Schema::create('termos_uso', function (Blueprint $table) {
            $table->id();
            $table->text('conteudo');
            $table->boolean('ativo')->default(true);
            $table->timestamps();
        });

        Schema::create('politica_privacidade', function (Blueprint $table) {
            $table->id();
            $table->text('conteudo');
            $table->boolean('ativo')->default(true);
            $table->timestamps();
        });

        Schema::create('empreendimentos_documentos', function (Blueprint $table) {
            $table->id();
            $table->foreignId('empreendimentos_id')->constrained('empreendimentos')->onDelete('cascade');
            $table->foreignId('tipo_documento_id')->nullable()->constrained('tipos_documentos')->onDelete('set null');
            $table->text('url')->nullable();
            $table->string('nome')->nullable();
            $table->timestamps();
        });

        Schema::create('favoritos', function (Blueprint $table) {
            $table->id();
            $table->foreignId('corretor_id')->constrained('corretores')->onDelete('cascade');
            $table->foreignId('empreendimento_id')->nullable()->constrained('empreendimentos')->onDelete('cascade');
            $table->foreignId('unidade_id')->nullable()->constrained('empreendimentos_unidades')->onDelete('cascade');
            $table->timestamps();
        });

        Schema::create('evolucao_obras', function (Blueprint $table) {
            $table->id();
            $table->foreignId('empreendimento_id')->constrained('empreendimentos')->onDelete('cascade');
            $table->integer('percentual')->nullable();
            $table->text('descricao')->nullable();
            $table->date('data')->nullable();
            $table->timestamps();
        });

        Schema::create('click_tracking', function (Blueprint $table) {
            $table->id();
            $table->foreignId('corretor_id')->nullable()->constrained('corretores')->onDelete('set null');
            $table->foreignId('empreendimento_id')->nullable()->constrained('empreendimentos')->onDelete('set null');
            $table->string('tipo_acao')->nullable();
            $table->timestamps();
        });

        // ========================================
        // IMÓVEIS (listagem externa)
        // ========================================

        Schema::create('imoveis', function (Blueprint $table) {
            $table->id();
            $table->string('titulo');
            $table->text('descricao')->nullable();
            $table->string('tipo')->nullable();
            $table->string('finalidade')->nullable();
            $table->decimal('valor', 15, 2)->nullable();
            $table->decimal('area', 10, 2)->nullable();
            $table->integer('quartos')->nullable();
            $table->integer('suites')->nullable();
            $table->integer('banheiros')->nullable();
            $table->integer('vagas')->nullable();
            $table->string('cep')->nullable();
            $table->string('logradouro')->nullable();
            $table->string('numero')->nullable();
            $table->string('complemento')->nullable();
            $table->string('bairro')->nullable();
            $table->string('cidade')->nullable();
            $table->string('estado')->nullable();
            $table->decimal('latitude', 10, 8)->nullable();
            $table->decimal('longitude', 11, 8)->nullable();
            $table->json('fotos')->nullable();
            $table->boolean('ativo')->default(true);
            $table->foreignId('corretor_id')->nullable()->constrained('corretores')->onDelete('set null');
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        // Drop em ordem inversa de dependência
        Schema::dropIfExists('imoveis');
        Schema::dropIfExists('historico_pagamentos');
        Schema::dropIfExists('pagamentos_parcelas');
        Schema::dropIfExists('pagamentos');
        Schema::dropIfExists('negociacoes');
        Schema::dropIfExists('leads');
        Schema::dropIfExists('clientes_pessoas');
        Schema::dropIfExists('clientes_fotos');
        Schema::dropIfExists('clientes_enderecos');
        Schema::dropIfExists('clientes');
        Schema::dropIfExists('empreendimentos_unidades_videos');
        Schema::dropIfExists('empreendimentos_unidades_fotos');
        Schema::dropIfExists('medida_unidades');
        Schema::dropIfExists('empreendimentos_unidades_vagas_garagem');
        Schema::dropIfExists('empreendimentos_unidades');
        Schema::dropIfExists('empreendimentos_torres_excessoes');
        Schema::dropIfExists('empreendimentos_torres');
        Schema::dropIfExists('empreendimentos_imagens_arquivos');
        Schema::dropIfExists('empreendimentos_areas_lazer');
        Schema::dropIfExists('empreendimentos_enderecos');
        Schema::dropIfExists('empreendimentos');
        Schema::dropIfExists('equipe_permissoes');
        Schema::dropIfExists('equipe_usuarios');
        Schema::dropIfExists('corretores');
        Schema::dropIfExists('imobiliarias_responsaveis');
        Schema::dropIfExists('imobiliarias_enderecos');
        Schema::dropIfExists('imobiliarias');
        Schema::dropIfExists('construtores');
        Schema::dropIfExists('quantidade_parcelas_disponiveis');
        Schema::dropIfExists('status_pagamento_parcelas');
        Schema::dropIfExists('conformidade_vendas');
        Schema::dropIfExists('ibti_registro_vendas');
        Schema::dropIfExists('situacao_vendas');
        Schema::dropIfExists('modalidade_vendas');
        Schema::dropIfExists('formas_pagamento');
        Schema::dropIfExists('negociacoes_status');
        Schema::dropIfExists('status_clientes');
        Schema::dropIfExists('origem_leads');
        Schema::dropIfExists('status_leads');
        Schema::dropIfExists('permissoes');
        Schema::dropIfExists('cargos');
        Schema::dropIfExists('tipo_medida_unidades');
        Schema::dropIfExists('tipo_area_lazer');
        Schema::dropIfExists('empreendimentos_status');
        Schema::dropIfExists('status_unidades');
        Schema::dropIfExists('tipo_unidades');
        Schema::dropIfExists('tipo_empreendimentos');
        Schema::dropIfExists('personal_access_tokens');
        Schema::dropIfExists('cache_locks');
        Schema::dropIfExists('cache');
        Schema::dropIfExists('sessions');
        Schema::dropIfExists('users');
    }
};

