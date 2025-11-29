<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\PoliticaPrivacidade;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class PoliticaPrivacidadeController extends Controller
{
    public function index()
    {
        try {
            $politicaPrivacidade = PoliticaPrivacidade::first();

            if (!$politicaPrivacidade) {
                $politicaPrivacidade = PoliticaPrivacidade::create([
                    'conteudo' => null,
                ]);
            }

            return response()->json([
                'success' => true,
                'data' => $politicaPrivacidade
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erro ao buscar política de privacidade',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    public function update(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'conteudo' => 'required|string',
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Dados inválidos',
                    'errors' => $validator->errors()
                ], 422);
            }

            $politicaPrivacidade = PoliticaPrivacidade::first();

            if (!$politicaPrivacidade) {
                $politicaPrivacidade = PoliticaPrivacidade::create([
                    'conteudo' => $request->conteudo,
                ]);
            } else {
                $politicaPrivacidade->update([
                    'conteudo' => $request->conteudo,
                ]);
            }

            return response()->json([
                'success' => true,
                'message' => 'Política de privacidade atualizada com sucesso',
                'data' => $politicaPrivacidade
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erro ao atualizar política de privacidade',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    public function appIndex()
    {
        try {
            $politicaPrivacidade = PoliticaPrivacidade::first();

            if (!$politicaPrivacidade) {
                return response()->json([
                    'success' => true,
                    'data' => [
                        'conteudo' => null,
                    ]
                ]);
            }

            return response()->json([
                'success' => true,
                'data' => [
                    'conteudo' => $politicaPrivacidade->conteudo,
                ]
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erro ao buscar política de privacidade',
                'error' => $e->getMessage()
            ], 500);
        }
    }
}
