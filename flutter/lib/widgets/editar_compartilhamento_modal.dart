import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../models/compartilhamento.dart';
import '../providers/compartilhamentos_provider.dart';

class EditarCompartilhamentoModal extends StatefulWidget {
  final Compartilhamento compartilhamento;

  const EditarCompartilhamentoModal({
    super.key,
    required this.compartilhamento,
  });

  @override
  State<EditarCompartilhamentoModal> createState() =>
      _EditarCompartilhamentoModalState();
}

class _EditarCompartilhamentoModalState
    extends State<EditarCompartilhamentoModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomeClienteController;
  late TextEditingController _anotacaoController;

  late bool _receberNotificacao;
  late bool _mostrarEspelhoVendas;
  late bool _mostrarEndereco;
  late bool _compartilharDescricao;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nomeClienteController =
        TextEditingController(text: widget.compartilhamento.nomeCliente ?? '');
    _anotacaoController =
        TextEditingController(text: widget.compartilhamento.anotacao ?? '');
    _receberNotificacao = widget.compartilhamento.receberNotificacao;
    _mostrarEspelhoVendas = widget.compartilhamento.mostrarEspelhoVendas;
    _mostrarEndereco = widget.compartilhamento.mostrarEndereco;
    _compartilharDescricao = widget.compartilhamento.compartilharDescricao;
  }

  @override
  void dispose() {
    _nomeClienteController.dispose();
    _anotacaoController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final provider = context.read<CompartilhamentosProvider>();

    final sucesso = await provider.editarCompartilhamento(
      id: widget.compartilhamento.id,
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

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (sucesso) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Compartilhamento atualizado com sucesso!'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Erro ao atualizar compartilhamento'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _desativar() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Desativar compartilhamento?'),
        content: const Text(
          'Tem certeza que deseja desativar este compartilhamento? O link não estará mais acessível.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Desativar'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    setState(() => _isLoading = true);

    final provider = context.read<CompartilhamentosProvider>();

    final sucesso = await provider.deletarCompartilhamento(widget.compartilhamento.id);

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (sucesso) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Compartilhamento desativado com sucesso!'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Erro ao desativar compartilhamento'),
          backgroundColor: AppColors.error,
        ),
      );
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
                  child: const Icon(Icons.edit, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Editar Compartilhamento',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
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

            // Botão Desativar
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isLoading ? null : _desativar,
                icon: const Icon(Icons.block, size: 18),
                label: const Text('Desativar Link'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Botão Salvar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _salvar,
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
                        'Salvar Alterações',
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

