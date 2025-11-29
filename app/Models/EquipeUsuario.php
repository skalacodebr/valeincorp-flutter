<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Laravel\Sanctum\HasApiTokens;

class EquipeUsuario extends Authenticatable
{
    use HasApiTokens, HasFactory;

    protected $table = 'equipe_usuarios';

    protected $fillable = [
        'nome',
        'telefone',
        'email',
        'senha',
        'data_entrada',
        'cargos_id',
        'status',
        'remember_token',
    ];

    protected $hidden = ['senha'];

    protected $casts = [
        'status' => 'boolean',
        'data_entrada' => 'date',
    ];

    public function cargo()
    {
        return $this->belongsTo(Cargo::class, 'cargos_id');
    }

    public function permissoes()
    {
        return $this->belongsToMany(Permissao::class, 'equipe_permissoes', 'equipe_usuarios_id', 'permissoes_id');
    }

    /**
     * Get the unique identifier for the user.
     *
     * @return mixed
     */
    public function getAuthIdentifier()
    {
        return $this->getKey();
    }

    /**
     * Get the password for the user.
     *
     * @return string
     */
    public function getAuthPassword()
    {
        return $this->senha;
    }

    /**
     * Get the name of the unique identifier for the user.
     *
     * @return string
     */
    public function getAuthIdentifierName()
    {
        return $this->getKeyName();
    }

    /**
     * Get the token value for the "remember me" session.
     *
     * @return string|null
     */
    public function getRememberToken()
    {
        return $this->{$this->getRememberTokenName()};
    }

    /**
     * Set the token value for the "remember me" session.
     *
     * @param  string  $value
     * @return void
     */
    public function setRememberToken($value)
    {
        $this->{$this->getRememberTokenName()} = $value;
    }

    /**
     * Get the column name for the "remember me" token.
     *
     * @return string
     */
    public function getRememberTokenName()
    {
        return 'remember_token';
    }
}
