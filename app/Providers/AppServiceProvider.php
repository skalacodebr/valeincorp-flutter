<?php

namespace App\Providers;

use Illuminate\Support\ServiceProvider;
use Illuminate\Support\Facades\Storage;
use Illuminate\Database\Eloquent\Relations\Relation;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        //
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        // Configurar morph map para relacionamentos polimórficos
        Relation::morphMap([
            'empreendimento' => \App\Models\Empreendimento::class,
            'unidade' => \App\Models\EmpreendimentoUnidade::class,
        ]);

        // Garantir que a pasta themes existe
        if (!Storage::disk('public')->exists('themes')) {
            Storage::disk('public')->makeDirectory('themes');
        }

        // 🚫 BLOQUEAR COMANDOS PERIGOSOS EM PRODUÇÃO
        if (app()->environment(['production', 'prod'])) {
            $this->blockDangerousCommands();
        }
    }

    /**
     * Bloqueia comandos perigosos que podem apagar dados
     */
    private function blockDangerousCommands(): void
    {
        if (app()->runningInConsole()) {
            $dangerousCommands = [
                'migrate:refresh',
                'migrate:reset', 
                'migrate:fresh',
                'db:wipe',
                'migrate:rollback --step=999'
            ];

            foreach ($dangerousCommands as $command) {
                if (in_array($command, $_SERVER['argv'] ?? [])) {
                    echo "🚫 COMANDO BLOQUEADO: {$command}\n";
                    echo "❌ Este comando foi desabilitado em produção para proteger os dados.\n";
                    exit(1);
                }
            }
        }
    }
}
