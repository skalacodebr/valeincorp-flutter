<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        if (Schema::hasTable('categorias_fotos')) {
            return;
        }
        
        Schema::create('categorias_fotos', function (Blueprint $table) {
            $table->id();
            $table->string('nome')->unique();
            $table->string('codigo')->unique();
            $table->text('descricao')->nullable();
            $table->integer('ordem')->default(0);
            $table->boolean('ativo')->default(true);
            $table->timestamps();

            $table->index('ativo');
            $table->index('ordem');
        });

        // Inserir categorias padrão baseadas nas existentes
        DB::table('categorias_fotos')->insert([
            ['nome' => 'Interna', 'codigo' => 'interna', 'descricao' => 'Fotos internas dos ambientes', 'ordem' => 1, 'ativo' => true, 'created_at' => now(), 'updated_at' => now()],
            ['nome' => 'Planta Baixa', 'codigo' => 'planta_baixa', 'descricao' => 'Plantas baixas das unidades', 'ordem' => 2, 'ativo' => true, 'created_at' => now(), 'updated_at' => now()],
            ['nome' => 'Fotos das Áreas', 'codigo' => 'fotos_das_areas', 'descricao' => 'Fotos das áreas do empreendimento', 'ordem' => 3, 'ativo' => true, 'created_at' => now(), 'updated_at' => now()],
            ['nome' => 'Uso Comum', 'codigo' => 'uso_comum', 'descricao' => 'Áreas de uso comum', 'ordem' => 4, 'ativo' => true, 'created_at' => now(), 'updated_at' => now()],
            ['nome' => 'Implantação', 'codigo' => 'implantacao', 'descricao' => 'Plantas de implantação', 'ordem' => 5, 'ativo' => true, 'created_at' => now(), 'updated_at' => now()],
        ]);
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('categorias_fotos');
    }
};
