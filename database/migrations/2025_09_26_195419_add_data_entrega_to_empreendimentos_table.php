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
        if (!Schema::hasColumn('empreendimentos', 'data_entrega')) {
            Schema::table('empreendimentos', function (Blueprint $table) {
                $table->string('data_entrega', 5)->nullable()->after('empreendimentos_status_id')->comment('Data de entrega prevista no formato MM/AA (ex: 12/25)');
            });
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('empreendimentos', function (Blueprint $table) {
            $table->dropColumn('data_entrega');
        });
    }
};
