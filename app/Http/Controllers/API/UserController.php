<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\Corretor;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;
use App\Traits\FileUploadTrait;

class UserController extends Controller
{
    use FileUploadTrait;

    public function profile(Request $request)
    {
        $user = $request->user();
        
        return response()->json([
            'success' => true,
            'user' => [
                'id' => $user->id,
                'nome' => $user->nome,
                'email' => $user->email,
                'creci' => $user->creci,
                'telefone' => $user->telefone,
                'cpfCnpj' => $user->cpf,
                'documento' => $user->documento_url ?? null,
                'mostrar_venda' => (int)($user->mostrar_venda ?? 0),
                'isPessoaJuridica' => false,
                'fotoUsuario' => $user->avatar_url ?? null,
                'createdAt' => $user->created_at->toISOString(),
                'updatedAt' => $user->updated_at->toISOString(),
            ]
        ]);
    }

    public function updateProfile(Request $request)
    {
        $user = $request->user();
        
        $validator = Validator::make($request->all(), [
            'nome' => 'sometimes|required|string|max:255',
            'email' => 'sometimes|required|email|unique:corretores,email,' . $user->id,
            'telefone' => 'nullable|string|max:20',
            'cpf' => 'nullable|string|max:20',
            'creci' => 'nullable|string|max:255',
            'mostrar_venda' => 'nullable|integer|in:0,1',
            'documento' => 'nullable|file|mimes:pdf,doc,docx,jpg,jpeg,png|max:5120',
            'senha' => 'nullable|string|min:6',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Dados inválidos',
                'errors' => $validator->errors()
            ], 422);
        }

        $updateData = $request->only(['nome', 'email', 'telefone', 'cpf', 'creci', 'mostrar_venda']);
        
        // Adicionar senha ao update se fornecida
        // Não precisa fazer Hash aqui pois o modelo Corretor já faz automaticamente
        if ($request->has('senha') && $request->senha) {
            $updateData['senha'] = $request->senha;
        }
        
        // Upload do documento se fornecido
        if ($request->hasFile('documento')) {
            $file = $request->file('documento');
            $fileName = 'user_' . $user->id . '_documento_' . time() . '.' . $file->getClientOriginalExtension();
            $filePath = 'documentos/' . $fileName;
            $disk = \App\Helpers\StorageHelper::getStorageDisk();
            $file->storeAs('documentos', $fileName, $disk);
            $documentoUrl = \App\Helpers\StorageHelper::getPublicUrl($filePath);
            $updateData['documento_url'] = $documentoUrl;
        }

        $user->update($updateData);

        return response()->json([
            'success' => true,
            'message' => 'Perfil atualizado com sucesso',
            'user' => [
                'id' => $user->id,
                'nome' => $user->nome,
                'email' => $user->email,
                'creci' => $user->creci,
                'telefone' => $user->telefone,
                'cpfCnpj' => $user->cpf,
                'documento' => $user->documento_url ?? null,
                'mostrar_venda' => (int)($user->mostrar_venda ?? 0),
                'isPessoaJuridica' => false,
                'fotoUsuario' => $user->avatar_url ?? null,
                'updatedAt' => $user->fresh()->updated_at->toISOString(),
            ]
        ]);
    }

    public function changePassword(Request $request)
    {
        $user = $request->user();
        
        $validator = Validator::make($request->all(), [
            'senhaAtual' => 'required|string',
            'novaSenha' => 'required|string|min:6',
            'confirmarSenha' => 'required|string|same:novaSenha',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Dados inválidos',
                'errors' => $validator->errors()
            ], 422);
        }

        if (!Hash::check($request->senhaAtual, $user->senha)) {
            return response()->json([
                'success' => false,
                'message' => 'Senha atual incorreta'
            ], 400);
        }

        // Não precisa fazer Hash aqui pois o modelo Corretor já faz automaticamente
        $user->update([
            'senha' => $request->novaSenha
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Senha alterada com sucesso'
        ]);
    }

    public function uploadAvatar(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'avatar' => 'required|image|mimes:jpeg,png,jpg,gif|max:2048',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Arquivo inválido',
                'errors' => $validator->errors()
            ], 422);
        }

        $user = $request->user();
        
        if ($request->hasFile('avatar')) {
            $file = $request->file('avatar');
            $fileName = 'user_' . $user->id . '_avatar.' . $file->getClientOriginalExtension();
            $filePath = 'avatars/' . $fileName;
            $disk = \App\Helpers\StorageHelper::getStorageDisk();
            $file->storeAs('avatars', $fileName, $disk);
            $avatarUrl = \App\Helpers\StorageHelper::getPublicUrl($filePath);

            // Atualizar usuário com URL do avatar
            $user->update(['avatar_url' => $avatarUrl]);

            return response()->json([
                'success' => true,
                'message' => 'Foto de perfil atualizada com sucesso',
                'avatarUrl' => $avatarUrl
            ]);
        }

        return response()->json([
            'success' => false,
            'message' => 'Nenhum arquivo enviado'
        ], 400);
    }
}
