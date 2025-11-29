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
        Schema::table('corretores', function (Blueprint $table) {
            if (!Schema::hasColumn('corretores', 'documento_url')) {
                $table->string('documento_url')->nullable()->after('creci');
            }
            if (!Schema::hasColumn('corretores', 'avatar_url')) {
                $table->string('avatar_url')->nullable()->after('documento_url');
            }
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('corretores', function (Blueprint $table) {
            $table->dropColumn(['documento_url', 'avatar_url']);
        });
    }
};
