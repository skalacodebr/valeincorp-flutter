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
        Schema::table('click_tracking', function (Blueprint $table) {
            if (!Schema::hasColumn('click_tracking', 'compartilhamento_id')) {
                $table->foreignId('compartilhamento_id')
                    ->nullable()
                    ->after('entity_id')
                    ->constrained('compartilhamentos')
                    ->onDelete('set null')
                    ->comment('ID do compartilhamento que gerou este clique');
                
                $table->index('compartilhamento_id');
            }
        });
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
