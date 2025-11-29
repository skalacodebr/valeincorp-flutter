<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\Corretor;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Str;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Facades\Password;

class AuthController extends Controller
{
    public function login(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|email',
            'senha' => 'required|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Dados inválidos',
                'errors' => $validator->errors()
            ], 422);
        }

        $corretor = Corretor::where('email', $request->email)->first();

        if (!$corretor) {
            return response()->json([
                'success' => false,
                'message' => 'Email não encontrado'
            ], 401);
        }


        // Teste mais detalhado dos hashes
        $hash1 = '$2y$10$NsO2gJrOY9zPjHHoNERMouJP/tYHzypRbGU7VpZcUyekDq/6nJ27u';
        $hash2 = '$2y$12$MQY9OMq2PVgdTsZENdXQ2.yvOaq30NOEasWx/Vl8LUNcSTvGmZf3S';
        
        $teste1 = Hash::check('123456', $hash1);
        $teste2 = Hash::check('123456', $hash2);
        
        // Teste se o hash2 foi gerado com outra senha
        $testeOutras = [
            'hash_vazio' => Hash::check('', $hash2),
            'hash_duplo' => Hash::check(Hash::make('123456'), $hash2),
            'hash_bcrypt_123456' => Hash::check(bcrypt('123456'), $hash2)
        ];
        
        \Log::info('Hash Test Detalhado', [
            'teste1_result' => $teste1,
            'teste2_result' => $teste2,
            'hash1_length' => strlen($hash1),
            'hash2_length' => strlen($hash2),
            'hash1_valid' => (bool) preg_match('/^\$2[ayb]\$\d{2}\$[A-Za-z0-9\.\/]{53}$/', $hash1),
            'hash2_valid' => (bool) preg_match('/^\$2[ayb]\$\d{2}\$[A-Za-z0-9\.\/]{53}$/', $hash2),
            'outras_tentativas' => $testeOutras
        ]);

        if (!Hash::check($request->senha, $corretor->senha)) {
            return response()->json([
                'success' => false,
                'message' => 'Senha incorreta'
            ], 401);
        }

        // Verifica se o usuário está ativo
        if (!$corretor->ativo) {
            return response()->json([
                'success' => false,
                'message' => 'Sua conta ainda não foi aprovada pelo administrador. Aguarde a aprovação para acessar o sistema.'
            ], 403);
        }

        $token = $corretor->createToken('auth_token')->plainTextToken;
        $refreshToken = Str::random(60);

        return response()->json([
            'success' => true,
            'user' => [
                'id' => $corretor->id,
                'nome' => $corretor->nome,
                'email' => $corretor->email,
                'creci' => $corretor->creci,
                'telefone' => $corretor->telefone,
                'cpfCnpj' => $corretor->cpf,
                'mostrar_venda' => (int)($corretor->mostrar_venda ?? 0),
                'isPessoaJuridica' => false,
                'fotoUsuario' => null,
                'createdAt' => $corretor->created_at->toISOString(),
            ],
            'token' => $token,
            'refreshToken' => $refreshToken
        ]);
    }

    public function register(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'nomeCompleto' => 'required|string|max:255',
            'email' => 'required|email|unique:corretores,email',
            'cpfCnpj' => 'required|string|max:20',
            'isPessoaJuridica' => 'boolean',
            'telefone' => 'nullable|string|max:20',
            'creci' => 'nullable|string|max:255',
            'senha' => 'required|string|min:6',
            'confirmarSenha' => 'required|string|same:senha',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Dados inválidos',
                'errors' => $validator->errors()
            ], 422);
        }

        $senhaHash = Hash::make($request->senha);

        $corretor = Corretor::create([
            'nome' => $request->nomeCompleto,
            'email' => $request->email,
            'cpf' => $request->cpfCnpj,
            'telefone' => $request->telefone,
            'creci' => $request->creci,
            'senha' => $senhaHash,
            'ativo' => false,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Conta criada com sucesso! Aguarde a aprovação do administrador para acessar o sistema.',
            'user' => [
                'id' => $corretor->id,
                'nome' => $corretor->nome,
                'email' => $corretor->email,
                'creci' => $corretor->creci,
                'telefone' => $corretor->telefone,
                'cpfCnpj' => $corretor->cpf,
                'isPessoaJuridica' => $request->isPessoaJuridica ?? false,
                'createdAt' => $corretor->created_at->toISOString(),
            ]
        ], 201);
    }

    public function forgotPassword(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|email|exists:corretores,email',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Email não encontrado'
            ], 404);
        }

        // Simular envio de email (implementar com seu provedor)
        return response()->json([
            'success' => true,
            'message' => 'Email de recuperação enviado com sucesso'
        ]);
    }

    public function resetPassword(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'token' => 'required|string',
            'novaSenha' => 'required|string|min:6',
            'confirmarSenha' => 'required|string|same:novaSenha',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Dados inválidos'
            ], 422);
        }

        // Implementar lógica de reset com token
        return response()->json([
            'success' => true,
            'message' => 'Senha alterada com sucesso'
        ]);
    }

    public function refresh(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'refreshToken' => 'required|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Token inválido'
            ], 401);
        }

        // Implementar lógica de refresh token
        $newToken = Str::random(60);
        $newRefreshToken = Str::random(60);

        return response()->json([
            'success' => true,
            'token' => $newToken,
            'refreshToken' => $newRefreshToken
        ]);
    }
}
