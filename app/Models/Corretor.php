<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Laravel\Sanctum\HasApiTokens;
class Corretor extends Authenticatable
{
    use HasFactory, HasApiTokens;
    protected $table = 'corretores';

        protected $fillable = [
            'imobiliarias_id',
            'nome',
            'cpf',
            'email',
            'telefone',
            'senha',
            'creci',
            'documento_url',
            'avatar_url',
            'ativo',
            'token',
            'mostrar_venda',
            'mostrar_espelho',
        ];

        protected $hidden = [
            'senha',
            'remember_token',
        ];

        protected $casts = [
            'ativo'         => 'boolean',
            'mostrar_venda' => 'integer',
            'created_at'    => 'datetime',
            'updated_at'    => 'datetime',
        ];

        // Mutator removido - senha será hasheada manualmente no controller
        // para evitar duplo hash

        public function imobiliaria()
        {
            return $this->belongsTo(Imobiliaria::class, 'imobiliarias_id');
        }

        /**
         * Métodos de autenticação - sobrescrever para usar campo 'senha' ao invés de 'password'
         */
        public function getAuthPassword()
        {
            return $this->senha;
        }

        /**
         * Get the password for the user (alias)
         */
        public function getPasswordAttribute()
        {
            return $this->senha;
        }

        /**
         * Relacionamento com favoritos
         */
        public function favoritos()
        {
            return $this->hasMany(Favorito::class);
        }

        /**
         * Empreendimentos favoritados por este corretor
         */
        public function empreendimentosFavoritos()
        {
            return $this->belongsToMany(Empreendimento::class, 'favoritos', 'corretor_id', 'empreendimento_id')
                        ->withTimestamps();
        }
    }
