<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Mail\CorretorResetTokenMail;
use App\Models\Corretor;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Mail;

class CorretorAuthApiController extends Controller
{
    /**
     * Envia um token de 6 dígitos para o e-mail informado e salva no banco.
     * POST /api/corretores/recuperar-senha
     */
    public function sendToken(Request $request)
    {
        $data = $request->validate([
            'email' => ['required', 'email'],
        ]);

        $corretor = Corretor::where('email', $data['email'])->first();

        if (!$corretor) {
            return response()->json([
                'message' => 'E-mail não encontrado.',
                'code' => 'EMAIL_NOT_FOUND'
            ], 404);
        }

        // Gera token numérico de 6 dígitos
        $token = (string) random_int(100000, 999999);

        // Salva token no corretor
        $corretor->token = $token;
        $corretor->save();

        try {
            Mail::to($corretor->email)->send(new CorretorResetTokenMail($corretor->nome, $token));
        } catch (\Throwable $e) {
            return response()->json([
                'message' => 'Falha ao enviar o e-mail. Tente novamente em instantes.',
                'code' => 'MAIL_SEND_FAILED'
            ], 500);
        }

        return response()->json([
            'message' => 'Token enviado para o e-mail informado.'
        ], 200);
    }

    /**
     * Redefine a senha validando e-mail + token.
     * POST /api/corretores/redefinir-senha
     */
    public function resetPassword(Request $request)
    {
        $data = $request->validate([
            'email'    => ['required', 'email'],
            'token'    => ['required', 'digits:6'],
            'password' => ['required', 'min:6', 'confirmed'],
        ]);

        $corretor = Corretor::where('email', $data['email'])->first();

        if (!$corretor) {
            return response()->json([
                'message' => 'E-mail não encontrado.',
                'code' => 'EMAIL_NOT_FOUND'
            ], 404);
        }

        if ($corretor->token !== $data['token']) {
            return response()->json([
                'message' => 'Token inválido.',
                'code' => 'INVALID_TOKEN'
            ], 401);
        }

        // Tudo ok → salva a nova senha (hash) e limpa o token
        $corretor->senha = Hash::make($data['password']);
        $corretor->token = null;
        $corretor->save();

        return response()->json([
            'message' => 'Senha redefinida com sucesso.'
        ], 200);
    }
}
