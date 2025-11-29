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
        if (!Schema::hasColumn('empreendimentos', 'area_total')) {
            Schema::table('empreendimentos', function (Blueprint $table) {
                $table->decimal('area_total', 10, 2)->nullable()->after('area_lazer');
            });
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('empreendimentos', function (Blueprint $table) {
            $table->dropColumn('area_total');
        });
    }
};
