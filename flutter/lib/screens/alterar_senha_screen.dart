import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/user_provider.dart';
import '../widgets/campo_input.dart';
import '../widgets/botao_principal.dart';

class AlterarSenhaScreen extends StatefulWidget {
  const AlterarSenhaScreen({super.key});

  @override
  State<AlterarSenhaScreen> createState() => _AlterarSenhaScreenState();
}

class _AlterarSenhaScreenState extends State<AlterarSenhaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _senhaAtualController = TextEditingController();
  final _novaSenhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();

  bool _obscureSenhaAtual = true;
  bool _obscureNovaSenha = true;
  bool _obscureConfirmarSenha = true;
  Map<String, String> _erros = {};

  @override
  void dispose() {
    _senhaAtualController.dispose();
    _novaSenhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  bool _validar() {
    _erros = {};

    if (_senhaAtualController.text.isEmpty) {
      _erros['senhaAtual'] = 'Senha atual é obrigatória';
    }

    if (_novaSenhaController.text.isEmpty) {
      _erros['novaSenha'] = 'Nova senha é obrigatória';
    } else if (_novaSenhaController.text.length < 6) {
      _erros['novaSenha'] = 'A senha deve ter pelo menos 6 caracteres';
    }

    if (_confirmarSenhaController.text.isEmpty) {
      _erros['confirmarSenha'] = 'Confirmação é obrigatória';
    } else if (_novaSenhaController.text != _confirmarSenhaController.text) {
      _erros['confirmarSenha'] = 'As senhas não coincidem';
    }

    setState(() {});
    return _erros.isEmpty;
  }

  Future<void> _alterarSenha() async {
    if (!_validar()) return;

    final userProvider = context.read<UserProvider>();

    final success = await userProvider.changePassword(
      senhaAtual: _senhaAtualController.text,
      novaSenha: _novaSenhaController.text,
      confirmarSenha: _confirmarSenhaController.text,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Senha alterada com sucesso!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(userProvider.error ?? 'Erro ao alterar senha'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alterar Senha'),
        backgroundColor: AppColors.primaryBlue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.lock_outline,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Alterar Senha',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Mantenha sua conta segura atualizando sua senha regularmente',
                            style: TextStyle(
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

              const SizedBox(height: 32),

              // Senha atual
              CampoInput(
                label: 'Senha Atual',
                hint: 'Digite sua senha atual',
                controller: _senhaAtualController,
                obscureText: _obscureSenhaAtual,
                prefixIcon: Icons.lock_outline,
                error: _erros['senhaAtual'],
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureSenhaAtual ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: () {
                    setState(() => _obscureSenhaAtual = !_obscureSenhaAtual);
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Nova senha
              CampoInput(
                label: 'Nova Senha',
                hint: 'Mínimo 6 caracteres',
                controller: _novaSenhaController,
                obscureText: _obscureNovaSenha,
                prefixIcon: Icons.lock_reset,
                error: _erros['novaSenha'],
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureNovaSenha ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: () {
                    setState(() => _obscureNovaSenha = !_obscureNovaSenha);
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Confirmar senha
              CampoInput(
                label: 'Confirmar Nova Senha',
                hint: 'Repita a nova senha',
                controller: _confirmarSenhaController,
                obscureText: _obscureConfirmarSenha,
                prefixIcon: Icons.lock_outline,
                error: _erros['confirmarSenha'],
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmarSenha
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: () {
                    setState(
                        () => _obscureConfirmarSenha = !_obscureConfirmarSenha);
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Dicas de senha
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.tips_and_updates,
                            color: Colors.amber.shade700, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Dicas para uma senha forte',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.amber.shade800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildTip('Use pelo menos 6 caracteres'),
                    _buildTip('Misture letras maiúsculas e minúsculas'),
                    _buildTip('Inclua números e símbolos'),
                    _buildTip('Evite informações pessoais'),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Botão
              Consumer<UserProvider>(
                builder: (context, userProvider, child) {
                  return BotaoPrincipal(
                    texto: 'Alterar Senha',
                    onPressed: _alterarSenha,
                    isLoading: userProvider.isLoading,
                    icon: Icons.check,
                  );
                },
              ),

              const SizedBox(height: 16),

              // Cancelar
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline,
              size: 14, color: Colors.amber.shade700),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: Colors.amber.shade800,
            ),
          ),
        ],
      ),
    );
  }
}

