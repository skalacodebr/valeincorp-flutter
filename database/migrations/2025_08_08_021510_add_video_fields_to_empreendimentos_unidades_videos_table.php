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
        Schema::table('empreendimentos_unidades_videos', function (Blueprint $table) {
            if (!Schema::hasColumn('empreendimentos_unidades_videos', 'video_path')) {
                $table->string('video_path')->nullable();
            }
            if (!Schema::hasColumn('empreendimentos_unidades_videos', 'video_url')) {
                $table->string('video_url')->nullable();
            }
            if (!Schema::hasColumn('empreendimentos_unidades_videos', 'original_name')) {
                $table->string('original_name')->nullable();
            }
            if (!Schema::hasColumn('empreendimentos_unidades_videos', 'file_size')) {
                $table->bigInteger('file_size')->nullable();
            }
            if (!Schema::hasColumn('empreendimentos_unidades_videos', 'mime_type')) {
                $table->string('mime_type')->nullable();
            }
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('empreendimentos_unidades_videos', function (Blueprint $table) {
            $table->dropColumn(['video_path', 'video_url', 'original_name', 'file_size', 'mime_type']);
        });
    }
};
