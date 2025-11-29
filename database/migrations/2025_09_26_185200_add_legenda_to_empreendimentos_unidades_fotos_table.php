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
        if (!Schema::hasColumn('empreendimentos_unidades_fotos', 'legenda')) {
            Schema::table('empreendimentos_unidades_fotos', function (Blueprint $table) {
                $table->string('legenda', 255)->nullable()->after('url');
            });
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('empreendimentos_unidades_fotos', function (Blueprint $table) {
            $table->dropColumn('legenda');
        });
    }
};
