import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../config/theme.dart';
import '../models/compartilhamento.dart';
import '../services/compartilhamento_service.dart';

class ShareSettingsModal extends StatefulWidget {
  final String entityType; // 'empreendimento' ou 'unidade'
  final int entityId;
  final String entityNome;
  final String? entitySubtitulo;
  final String? imageUrl;

  const ShareSettingsModal({
    super.key,
    required this.entityType,
    required this.entityId,
    required this.entityNome,
    this.entitySubtitulo,
    this.imageUrl,
  });

  /// Mostra o modal e retorna o compartilhamento criado, ou null se cancelado
  static Future<Compartilhamento?> show({
    required BuildContext context,
    required String entityType,
    required int entityId,
    required String entityNome,
    String? entitySubtitulo,
    String? imageUrl,
  }) {
    return showModalBottomSheet<Compartilhamento>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ShareSettingsModal(
        entityType: entityType,
        entityId: entityId,
        entityNome: entityNome,
        entitySubtitulo: entitySubtitulo,
        imageUrl: imageUrl,
      ),
    );
  }

  @override
  State<ShareSettingsModal> createState() => _ShareSettingsModalState();
}

class _ShareSettingsModalState extends State<ShareSettingsModal> {
  final CompartilhamentoService _service = CompartilhamentoService();
  final TextEditingController _nomeClienteController = TextEditingController();
  final TextEditingController _anotacaoController = TextEditingController();

  bool _receberNotificacoes = true;
  bool _mostrarEspelhoVendas = false;
  bool _mostrarEndereco = false;
  bool _compartilharDescricao = false;

  bool _carregando = false;

  @override
  void dispose() {
    _nomeClienteController.dispose();
    _anotacaoController.dispose();
    super.dispose();
  }

  Future<void> _criarCompartilhamento() async {
    setState(() => _carregando = true);

    try {
      final request = CriarCompartilhamentoRequest(
        entityType: widget.entityType,
        entityId: widget.entityId,
        nomeCliente: _nomeClienteController.text.trim(),
        anotacao: _anotacaoController.text.trim(),
        receberNotificacao: _receberNotificacoes,
        mostrarEspelhoVendas: _mostrarEspelhoVendas,
        mostrarEndereco: _mostrarEndereco,
        compartilharDescricao: _compartilharDescricao,
      );

      final response = await _service.criar(request);

      if (response.success && response.data != null) {
        final compartilhamento = response.data!;

        // Abre o share nativo com o link rastreável
        await _compartilharLink(compartilhamento);

        if (mounted) {
          Navigator.pop(context, compartilhamento);
        }
      } else {
        // Mostrar opção para o usuário: compartilhar sem rastreamento ou tentar novamente
        if (mounted) {
          final compartilharSemRastreio = await _mostrarDialogoFallback();
          if (compartilharSemRastreio == true) {
            await _compartilharDireto();
            if (mounted) Navigator.pop(context);
          } else {
            setState(() => _carregando = false);
          }
        }
      }
    } catch (e) {
      debugPrint('[ShareSettings] Erro ao criar compartilhamento: $e');
      // Mostrar opção para o usuário
      if (mounted) {
        final compartilharSemRastreio = await _mostrarDialogoFallback();
        if (compartilharSemRastreio == true) {
          await _compartilharDireto();
          if (mounted) Navigator.pop(context);
        } else {
          setState(() => _carregando = false);
        }
      }
    } finally {
      if (mounted) {
        setState(() => _carregando = false);
      }
    }
  }

  /// Mostra diálogo perguntando se quer compartilhar sem rastreamento
  Future<bool?> _mostrarDialogoFallback() async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 8),
            Expanded(child: Text('Compartilhar sem rastreamento?')),
          ],
        ),
        content: const Text(
          'Não foi possível registrar este compartilhamento no servidor.\n\n'
          'Você pode compartilhar mesmo assim, mas NÃO será possível:\n'
          '• Rastrear visualizações\n'
          '• Receber notificações de acesso\n'
          '• Ver estatísticas na tela de Atividades',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Tentar novamente'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: const Text('Compartilhar assim mesmo'),
          ),
        ],
      ),
    );
  }

  /// Compartilhamento direto (fallback quando API não está disponível)
  Future<void> _compartilharDireto() async {
    final nomeCliente = _nomeClienteController.text.trim();
    final saudacao = nomeCliente.isNotEmpty ? 'Olá $nomeCliente!\n\n' : '';
    
    final tipoLabel = widget.entityType == 'empreendimento' ? 'empreendimento' : 'unidade';
    final baseUrl = widget.entityType == 'empreendimento' 
        ? 'https://app.valeincorp.com.br/imovel-publico/${widget.entityId}'
        : 'https://app.valeincorp.com.br/unidade-publica/${widget.entityId}';

    final mensagem = '''
$saudacao🏠 *${widget.entityNome}*
${widget.entitySubtitulo != null ? '${widget.entitySubtitulo}\n' : ''}
Preparei este $tipoLabel especialmente para você! 

🔗 Acesse todos os detalhes:
$baseUrl

_Compartilhado via Valeincorp_
''';

    await Share.share(
      mensagem,
      subject: widget.entityNome,
    );
  }

  Future<void> _compartilharLink(Compartilhamento compartilhamento) async {
    final nomeCliente = _nomeClienteController.text.trim();
    final saudacao = nomeCliente.isNotEmpty ? 'Olá $nomeCliente!\n\n' : '';
    
    final tipoLabel = widget.entityType == 'empreendimento' ? 'empreendimento' : 'unidade';

    final mensagem = '''
$saudacao🏠 *${widget.entityNome}*
${widget.entitySubtitulo != null ? '${widget.entitySubtitulo}\n' : ''}
Preparei este $tipoLabel especialmente para você! 

🔗 Acesse todos os detalhes:
${compartilhamento.urlCompleta}

_Compartilhado via Valeincorp_
''';

    await Share.share(
      mensagem,
      subject: widget.entityNome,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(),
              const SizedBox(height: 24),

              // Preview do que será compartilhado
              _buildPreview(),
              const SizedBox(height: 20),

              // Campo Nome do Cliente
              _buildTextField(
                controller: _nomeClienteController,
                label: 'Nome do Cliente',
                hint: 'Digite o nome do cliente',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 16),

              // Campo Anotações
              _buildTextField(
                controller: _anotacaoController,
                label: 'Anotações para controle',
                hint: 'Anotações internas (não aparece para o cliente)',
                icon: Icons.note_alt_outlined,
                maxLines: 2,
              ),
              const SizedBox(height: 20),

              // Opções de compartilhamento
              _buildOpcoes(),
              const SizedBox(height: 24),

              // Botão criar compartilhamento
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _carregando ? null : _criarCompartilhamento,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    disabledBackgroundColor: AppColors.primaryBlue.withOpacity(0.5),
                  ),
                  child: _carregando
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Criar compartilhamento',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.entityNome,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (widget.entitySubtitulo != null)
                Text(
                  widget.entitySubtitulo!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.close, color: Colors.white, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildPreview() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Imagem ou ícone
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: widget.imageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      widget.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.apartment,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  )
                : Icon(
                    widget.entityType == 'unidade' ? Icons.door_front_door : Icons.apartment,
                    color: AppColors.primaryBlue,
                    size: 28,
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.entityNome,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: widget.entityType == 'empreendimento'
                        ? AppColors.primaryGold.withOpacity(0.1)
                        : AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    widget.entityType == 'empreendimento' ? 'Empreendimento' : 'Unidade',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: widget.entityType == 'empreendimento'
                          ? AppColors.primaryGold
                          : AppColors.success,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: AppColors.textSecondary),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: AppColors.background,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildOpcoes() {
    return Column(
      children: [
        _buildOpcaoItem(
          titulo: 'Receber notificações',
          subtitulo: 'Ser notificado quando o link for acessado',
          valor: _receberNotificacoes,
          onChanged: (v) => setState(() => _receberNotificacoes = v),
        ),
        _buildOpcaoItem(
          titulo: 'Disponibilizar espelho de vendas',
          subtitulo: 'Cliente poderá ver disponibilidade das unidades',
          valor: _mostrarEspelhoVendas,
          onChanged: (v) => setState(() => _mostrarEspelhoVendas = v),
        ),
        _buildOpcaoItem(
          titulo: 'Mostrar Endereço',
          subtitulo: 'Exibir localização completa do empreendimento',
          valor: _mostrarEndereco,
          onChanged: (v) => setState(() => _mostrarEndereco = v),
        ),
        _buildOpcaoItem(
          titulo: 'Compartilhar descrição do empreendimento',
          subtitulo: 'Incluir texto descritivo no compartilhamento',
          valor: _compartilharDescricao,
          onChanged: (v) => setState(() => _compartilharDescricao = v),
          isLast: true,
        ),
      ],
    );
  }

  Widget _buildOpcaoItem({
    required String titulo,
    required String subtitulo,
    required bool valor,
    required ValueChanged<bool> onChanged,
    bool isLast = false,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: () => onChanged(!valor),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                // Checkbox customizado
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: valor ? AppColors.primaryBlue : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: valor ? AppColors.primaryBlue : AppColors.border,
                      width: 2,
                    ),
                  ),
                  child: valor
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titulo,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        subtitulo,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (!isLast)
          Divider(
            color: AppColors.border.withOpacity(0.5),
            height: 1,
          ),
      ],
    );
  }
}

