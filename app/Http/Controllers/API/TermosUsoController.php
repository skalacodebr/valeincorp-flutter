<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\TermosUso;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class TermosUsoController extends Controller
{
    public function index()
    {
        try {
            $termosUso = TermosUso::first();

            if (!$termosUso) {
                $termosUso = TermosUso::create([
                    'conteudo' => null,
                ]);
            }

            return response()->json([
                'success' => true,
                'data' => $termosUso
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erro ao buscar termos de uso',
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

            $termosUso = TermosUso::first();

            if (!$termosUso) {
                $termosUso = TermosUso::create([
                    'conteudo' => $request->conteudo,
                ]);
            } else {
                $termosUso->update([
                    'conteudo' => $request->conteudo,
                ]);
            }

            return response()->json([
                'success' => true,
                'message' => 'Termos de uso atualizados com sucesso',
                'data' => $termosUso
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erro ao atualizar termos de uso',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    public function appIndex()
    {
        try {
            $termosUso = TermosUso::first();

            if (!$termosUso) {
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
                    'conteudo' => $termosUso->conteudo,
                ]
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erro ao buscar termos de uso',
                'error' => $e->getMessage()
            ], 500);
        }
    }
}
