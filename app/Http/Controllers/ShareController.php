<?php

namespace App\Http\Controllers;

use App\Models\Compartilhamento;
use App\Models\AcessoCompartilhamento;
use App\Models\Notification;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class ShareController extends Controller
{
    /**
     * Exibir página pública de compartilhamento
     */
    public function show($linkUnico)
    {
        $compartilhamento = Compartilhamento::where('link_unico', $linkUnico)->first();

        if (!$compartilhamento) {
            abort(404, 'Link de compartilhamento não encontrado');
        }

        // Verificar se está ativo e não expirado
        if (!$compartilhamento->isAtivo()) {
            return view('share.expired', [
                'compartilhamento' => $compartilhamento
            ]);
        }

        // Registrar acesso
        $this->registrarAcesso($compartilhamento, request());

        // Carregar dados da entidade
        $entity = null;
        $entityData = null;

        if ($compartilhamento->entity_type === 'empreendimento') {
            $entity = $compartilhamento->empreendimento;
            if ($entity) {
                $entityData = $this->formatarEmpreendimento($entity, $compartilhamento);
            }
        } elseif ($compartilhamento->entity_type === 'unidade') {
            $entity = $compartilhamento->unidade;
            if ($entity) {
                $entityData = $this->formatarUnidade($entity, $compartilhamento);
            }
        }

        if (!$entity) {
            abort(404, 'Entidade não encontrada');
        }

        return view('share.show', [
            'compartilhamento' => $compartilhamento,
            'entity' => $entity,
            'entityData' => $entityData,
        ]);
    }

    /**
     * Registrar acesso ao compartilhamento
     */
    private function registrarAcesso(Compartilhamento $compartilhamento, Request $request): void
    {
        DB::transaction(function () use ($compartilhamento, $request) {
            // Registrar acesso individual
            AcessoCompartilhamento::create([
                'compartilhamento_id' => $compartilhamento->id,
                'ip_address' => $request->ip(),
                'user_agent' => $request->userAgent(),
                'acessado_at' => now(),
                'referer' => $request->header('referer'),
            ]);

            // Incrementar contador de visualizações
            $compartilhamento->incrementarVisualizacao();

            // Criar notificação se configurado
            if ($compartilhamento->receber_notificacao) {
                $this->criarNotificacao($compartilhamento);
            }
        });
    }

    /**
     * Criar notificação para o corretor
     */
    private function criarNotificacao(Compartilhamento $compartilhamento): void
    {
        $entityNome = 'item';
        if ($compartilhamento->entity_type === 'empreendimento') {
            $entityNome = $compartilhamento->empreendimento->nome ?? 'Empreendimento';
        } elseif ($compartilhamento->entity_type === 'unidade') {
            $entityNome = 'Unidade ' . ($compartilhamento->unidade->numero ?? '');
        }

        $mensagem = "Seu compartilhamento de {$entityNome}";
        if ($compartilhamento->nome_cliente) {
            $mensagem .= " para {$compartilhamento->nome_cliente}";
        }
        $mensagem .= " foi visualizado.";

        // Criar notificação no banco (se a tabela existir)
        try {
            Notification::create([
                'user_id' => $compartilhamento->corretor_id,
                'type' => 'compartilhamento_acessado',
                'title' => 'Compartilhamento Visualizado',
                'message' => $mensagem,
                'data' => json_encode([
                    'compartilhamento_id' => $compartilhamento->id,
                    'entity_type' => $compartilhamento->entity_type,
                    'entity_id' => $compartilhamento->entity_id,
                    'total_visualizacoes' => $compartilhamento->total_visualizacoes + 1,
                ]),
                'read_at' => null,
            ]);
        } catch (\Exception $e) {
            // Se a tabela não existir, apenas logar o erro
            \Log::warning('Não foi possível criar notificação: ' . $e->getMessage());
        }

        // TODO: Enviar push notification aqui
        // Exemplo: usar Laravel Notifications com FCM ou similar
    }

    /**
     * Formatar dados do empreendimento para exibição
     */
    private function formatarEmpreendimento($empreendimento, Compartilhamento $compartilhamento): array
    {
        $data = [
            'id' => $empreendimento->id,
            'nome' => $empreendimento->nome,
            'codigo' => $empreendimento->codigo ?? 'EMO' . str_pad($empreendimento->id, 3, '0', STR_PAD_LEFT),
        ];

        // Descrição (se permitido)
        if ($compartilhamento->compartilhar_descricao) {
            $data['descricao'] = $empreendimento->observacoes ?? '';
        }

        // Endereço (se permitido)
        if ($compartilhamento->mostrar_endereco && $empreendimento->endereco) {
            $endereco = $empreendimento->endereco;
            $data['endereco'] = [
                'logradouro' => $endereco->logradouro,
                'numero' => $endereco->numero,
                'complemento' => $endereco->complemento,
                'bairro' => $endereco->bairro,
                'cidade' => $endereco->cidade,
                'estado' => $endereco->estado,
                'cep' => $endereco->cep,
                'latitude' => $endereco->latitude,
                'longitude' => $endereco->longitude,
            ];
        }

        // Espelho de vendas (se permitido)
        if ($compartilhamento->mostrar_espelho_vendas) {
            // TODO: Carregar dados do espelho de vendas
            $data['espelho_vendas'] = [
                'total_unidades' => $empreendimento->unidades->count() ?? 0,
                'unidades_disponiveis' => $empreendimento->unidades->where('status_unidades_id', 1)->count() ?? 0,
                // Adicionar mais dados conforme necessário
            ];
        }

        return $data;
    }

    /**
     * Formatar dados da unidade para exibição
     */
    private function formatarUnidade($unidade, Compartilhamento $compartilhamento): array
    {
        $data = [
            'id' => $unidade->id,
            'numero' => $unidade->numero,
            'torre' => $unidade->torre->nome ?? '',
        ];

        // Descrição (se permitido)
        if ($compartilhamento->compartilhar_descricao) {
            $data['descricao'] = $unidade->observacoes ?? '';
        }

        // Endereço (se permitido)
        if ($compartilhamento->mostrar_endereco && $unidade->empreendimento->endereco) {
            $endereco = $unidade->empreendimento->endereco;
            $data['endereco'] = [
                'logradouro' => $endereco->logradouro,
                'numero' => $endereco->numero,
                'complemento' => $endereco->complemento,
                'bairro' => $endereco->bairro,
                'cidade' => $endereco->cidade,
                'estado' => $endereco->estado,
                'cep' => $endereco->cep,
                'latitude' => $endereco->latitude,
                'longitude' => $endereco->longitude,
            ];
        }

        // Espelho de vendas (se permitido)
        if ($compartilhamento->mostrar_espelho_vendas) {
            $data['espelho_vendas'] = [
                'valor' => $unidade->valor_venda ?? 0,
                'status' => $unidade->status->nome ?? '',
                // Adicionar mais dados conforme necessário
            ];
        }

        return $data;
    }
}
