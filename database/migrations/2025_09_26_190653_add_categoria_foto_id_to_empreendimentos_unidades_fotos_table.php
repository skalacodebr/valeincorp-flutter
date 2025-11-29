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
        if (!Schema::hasColumn('empreendimentos_unidades_fotos', 'categoria_foto_id')) {
            Schema::table('empreendimentos_unidades_fotos', function (Blueprint $table) {
                $table->unsignedBigInteger('categoria_foto_id')->nullable()->after('legenda');
                $table->index('categoria_foto_id');
            });
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('empreendimentos_unidades_fotos', function (Blueprint $table) {
            $table->dropForeign(['categoria_foto_id']);
            $table->dropIndex(['categoria_foto_id']);
            $table->dropColumn('categoria_foto_id');
        });
    }
};
