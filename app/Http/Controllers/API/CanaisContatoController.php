<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\CanaisContato;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class CanaisContatoController extends Controller
{
    public function index()
    {
        try {
            $canaisContato = CanaisContato::first();

            if (!$canaisContato) {
                $canaisContato = CanaisContato::create([
                    'telefone' => null,
                    'email' => null,
                    'whatsapp' => null,
                    'perguntas' => null,
                ]);
            }

            return response()->json([
                'success' => true,
                'data' => $canaisContato
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erro ao buscar canais de contato',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    public function update(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'telefone' => 'nullable|string|max:255',
                'email' => 'nullable|email|max:255',
                'whatsapp' => 'nullable|string|max:255',
                'perguntas' => 'nullable|array',
                'perguntas.*.pergunta' => 'required|string',
                'perguntas.*.resposta' => 'required|string',
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Dados inválidos',
                    'errors' => $validator->errors()
                ], 422);
            }

            $canaisContato = CanaisContato::first();

            if (!$canaisContato) {
                $canaisContato = CanaisContato::create([
                    'telefone' => $request->telefone,
                    'email' => $request->email,
                    'whatsapp' => $request->whatsapp,
                    'perguntas' => $request->perguntas,
                ]);
            } else {
                $canaisContato->update([
                    'telefone' => $request->telefone,
                    'email' => $request->email,
                    'whatsapp' => $request->whatsapp,
                    'perguntas' => $request->perguntas,
                ]);
            }

            return response()->json([
                'success' => true,
                'message' => 'Canais de contato atualizados com sucesso',
                'data' => $canaisContato
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erro ao atualizar canais de contato',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    public function appIndex()
    {
        try {
            $canaisContato = CanaisContato::first();

            if (!$canaisContato) {
                return response()->json([
                    'success' => true,
                    'data' => [
                        'telefone' => null,
                        'email' => null,
                        'whatsapp' => null,
                        'perguntas' => null,
                    ]
                ]);
            }

            return response()->json([
                'success' => true,
                'data' => [
                    'telefone' => $canaisContato->telefone,
                    'email' => $canaisContato->email,
                    'whatsapp' => $canaisContato->whatsapp,
                    'perguntas' => $canaisContato->perguntas,
                ]
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erro ao buscar canais de contato',
                'error' => $e->getMessage()
            ], 500);
        }
    }
}
