import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../config/theme.dart';
import '../providers/compartilhamentos_provider.dart';

class CriarCompartilhamentoModal extends StatefulWidget {
  final String entityType; // 'empreendimento' ou 'unidade'
  final int entityId;
  final String titulo;
  final String? imageUrl;

  const CriarCompartilhamentoModal({
    super.key,
    required this.entityType,
    required this.entityId,
    required this.titulo,
    this.imageUrl,
  });

  @override
  State<CriarCompartilhamentoModal> createState() =>
      _CriarCompartilhamentoModalState();
}

class _CriarCompartilhamentoModalState
    extends State<CriarCompartilhamentoModal> {
  final _formKey = GlobalKey<FormState>();
  final _nomeClienteController = TextEditingController();
  final _anotacaoController = TextEditingController();

  bool _receberNotificacao = false;
  bool _mostrarEspelhoVendas = false;
  bool _mostrarEndereco = true;
  bool _compartilharDescricao = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nomeClienteController.dispose();
    _anotacaoController.dispose();
    super.dispose();
  }

  Future<void> _criarECompartilhar() async {
    if (!_formKey.currentState!.validate()) {
      debugPrint('[Compartilhamento] Validação do formulário falhou');
      return;
    }

    debugPrint('[Compartilhamento] Iniciando criação do compartilhamento...');
    setState(() => _isLoading = true);

    final provider = context.read<CompartilhamentosProvider>();

    try {
      debugPrint('[Compartilhamento] Chamando provider.criarCompartilhamento...');
      final compartilhamento = await provider.criarCompartilhamento(
        entityType: widget.entityType,
        entityId: widget.entityId,
        nomeCliente: _nomeClienteController.text.isEmpty
            ? null
            : _nomeClienteController.text,
        anotacao: _anotacaoController.text.isEmpty
            ? null
            : _anotacaoController.text,
        receberNotificacao: _receberNotificacao,
        mostrarEspelhoVendas: _mostrarEspelhoVendas,
        mostrarEndereco: _mostrarEndereco,
        compartilharDescricao: _compartilharDescricao,
      );

      if (!mounted) {
        debugPrint('[Compartilhamento] Widget não está mais montado, abortando');
        return;
      }

      if (compartilhamento == null) {
        debugPrint('[Compartilhamento] Falha ao criar compartilhamento. Erro: ${provider.error}');
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'Erro ao criar compartilhamento'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      debugPrint('[Compartilhamento] Compartilhamento criado com sucesso! ID: ${compartilhamento.id}');
      
      final linkCompleto = compartilhamento.urlCompleta;
      debugPrint('[Compartilhamento] URL completa obtida: $linkCompleto');

      // Validar se a URL está presente
      if (linkCompleto.isEmpty) {
        debugPrint('[Compartilhamento] ERRO: URL completa está vazia!');
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro: URL de compartilhamento não foi gerada'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      // Preparar a mensagem antes de fechar o modal
      final mensagem = '''
${widget.titulo}

Veja mais detalhes: $linkCompleto

_Compartilhado via Valeincorp_
''';

      debugPrint('[Compartilhamento] Mensagem preparada. Tamanho: ${mensagem.length} caracteres');
      debugPrint('[Compartilhamento] Tentando abrir share sheet do iOS...');

      try {
        // Obter a posição para iPads (necessário para share sheet aparecer corretamente)
        // Usamos um Rect seguro baseado no tamanho da tela para evitar valores NaN
        Rect? sharePositionOrigin;
        
        try {
          final screenSize = MediaQuery.of(context).size;
          // Usar centro da tela como posição segura
          if (screenSize.width > 0 && screenSize.height > 0 && 
              screenSize.width.isFinite && screenSize.height.isFinite) {
            sharePositionOrigin = Rect.fromCenter(
              center: Offset(screenSize.width / 2, screenSize.height / 2),
              width: 100,
              height: 100,
            );
            debugPrint('[Compartilhamento] SharePositionOrigin definido: $sharePositionOrigin');
          }
        } catch (e) {
          debugPrint('[Compartilhamento] Erro ao calcular sharePositionOrigin: $e');
        }

        // Chamar o share ANTES de fechar o modal para garantir que o contexto esteja válido
        // No iOS, isso abrirá automaticamente o UIActivityViewController
        debugPrint('[Compartilhamento] Chamando Share.share()...');
        await Share.share(
          mensagem,
          subject: widget.titulo,
          sharePositionOrigin: sharePositionOrigin,
        );
        
        debugPrint('[Compartilhamento] Share.share() retornou com sucesso');
        debugPrint('[Compartilhamento] Share sheet deve ter sido aberto');
        
        // Aguardar um pequeno delay antes de fechar o modal para garantir que o share sheet apareceu
        await Future.delayed(const Duration(milliseconds: 300));
        
        // Desativar loading antes de fechar o modal
        if (mounted) {
          setState(() => _isLoading = false);
        }
        
        // Fechar o modal após o share ser aberto
        if (mounted) {
          debugPrint('[Compartilhamento] Fechando modal...');
          Navigator.pop(context);
        }
      } catch (e, stackTrace) {
        debugPrint('[Compartilhamento] ERRO ao chamar Share.share(): $e');
        debugPrint('[Compartilhamento] Stack trace: $stackTrace');
        
        // Se houver erro, fechar o modal e mostrar mensagem
        if (mounted) {
          setState(() => _isLoading = false);
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao abrir compartilhamento: $e'),
              backgroundColor: AppColors.error,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    } catch (e, stackTrace) {
      debugPrint('[Compartilhamento] ERRO inesperado: $e');
      debugPrint('[Compartilhamento] Stack trace: $stackTrace');
      
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro inesperado: $e'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Header
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.share, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Compartilhar ${widget.entityType == 'unidade' ? 'Unidade' : 'Empreendimento'}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.titulo,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Nome do Cliente
            TextFormField(
              controller: _nomeClienteController,
              decoration: InputDecoration(
                labelText: 'Nome do Cliente (opcional)',
                hintText: 'Digite o nome do cliente',
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Anotação
            TextFormField(
              controller: _anotacaoController,
              decoration: InputDecoration(
                labelText: 'Anotação (opcional)',
                hintText: 'Adicione uma observação',
                prefixIcon: const Icon(Icons.note_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            // Checkbox Notificação
            CheckboxListTile(
              value: _receberNotificacao,
              onChanged: (value) {
                setState(() => _receberNotificacao = value ?? false);
              },
              title: const Text('Receber notificação quando link for acessado'),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 8),

            // Divisor
            const Divider(),
            const SizedBox(height: 8),

            // Título das opções de visualização
            const Text(
              'Opções de Visualização',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // Checkbox Espelho de Vendas
            CheckboxListTile(
              value: _mostrarEspelhoVendas,
              onChanged: (value) {
                setState(() => _mostrarEspelhoVendas = value ?? false);
              },
              title: const Text('Disponibilizar espelho de vendas'),
              subtitle: const Text(
                'Mostra informações sobre vendas e disponibilidade',
                style: TextStyle(fontSize: 12),
              ),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),

            // Checkbox Mostrar Endereço
            CheckboxListTile(
              value: _mostrarEndereco,
              onChanged: (value) {
                setState(() => _mostrarEndereco = value ?? true);
              },
              title: const Text('Mostrar endereço'),
              subtitle: const Text(
                'Exibe o endereço completo do empreendimento',
                style: TextStyle(fontSize: 12),
              ),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),

            // Checkbox Compartilhar Descrição
            CheckboxListTile(
              value: _compartilharDescricao,
              onChanged: (value) {
                setState(() => _compartilharDescricao = value ?? true);
              },
              title: const Text('Compartilhar descrição do empreendimento'),
              subtitle: const Text(
                'Inclui a descrição e detalhes do imóvel',
                style: TextStyle(fontSize: 12),
              ),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),

            const SizedBox(height: 24),

            // Botão Criar e Compartilhar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _criarECompartilhar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGold,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Criar e Compartilhar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),

            SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
          ],
        ),
      ),
    );
  }
}

