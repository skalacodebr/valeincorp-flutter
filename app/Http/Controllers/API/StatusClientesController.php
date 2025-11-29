<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\StatusCliente;
use Illuminate\Http\Request;

class StatusClientesController extends Controller
{
    /**
     * Listar todos os status de clientes
     */
    public function index()
    {
        try {
            $statusClientes = StatusCliente::all();

            // Adicionar cores padrão baseadas no nome
            $statusComCores = $statusClientes->map(function ($status) {
                $cores = [
                    'ativo' => '#10b981',
                    'ativa' => '#10b981',
                    'potencial' => '#3b82f6',
                    'inativo' => '#6b7280',
                    'inativa' => '#6b7280',
                    'ex-cliente' => '#ef4444',
                    'negociação' => '#f59e0b',
                    'negociacao' => '#f59e0b',
                    'aguardando' => '#a855f7',
                    'pendente' => '#ec4899',
                    'suspenso' => '#64748b',
                ];

                $nomeNormalizado = strtolower(str_replace(['-', '_'], '', $status->nome));

                foreach ($cores as $key => $cor) {
                    if (str_contains($nomeNormalizado, $key)) {
                        $status->cor = $cor;
                        break;
                    }
                }

                if (!isset($status->cor)) {
                    $status->cor = '#9ca3af'; // Cor padrão
                }

                return $status;
            });

            return response()->json([
                'success' => true,
                'data' => $statusComCores
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erro ao buscar status de clientes',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Buscar um status específico
     */
    public function show($id)
    {
        try {
            $status = StatusCliente::findOrFail($id);

            return response()->json([
                'success' => true,
                'data' => $status
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Status não encontrado',
                'error' => $e->getMessage()
            ], 404);
        }
    }
}