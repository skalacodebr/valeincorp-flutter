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
        if (Schema::hasTable('click_tracking') && !Schema::hasColumn('click_tracking', 'compartilhamento_id')) {
            Schema::table('click_tracking', function (Blueprint $table) {
                $column = $table->foreignId('compartilhamento_id')
                    ->nullable();
                
                if (Schema::hasColumn('click_tracking', 'entity_id')) {
                    $column->after('entity_id');
                }
                
                $column->constrained('compartilhamentos')
                    ->onDelete('set null')
                    ->comment('ID do compartilhamento que gerou este clique');
                
                $table->index('compartilhamento_id');
            });
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('click_tracking', function (Blueprint $table) {
            if (Schema::hasColumn('click_tracking', 'compartilhamento_id')) {
                $table->dropForeign(['compartilhamento_id']);
                $table->dropIndex(['compartilhamento_id']);
                $table->dropColumn('compartilhamento_id');
            }
        });
    }
};
