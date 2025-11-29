import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../config/theme.dart';
import '../config/routes.dart';
import '../providers/auth_provider.dart';
import '../widgets/campo_input.dart';
import '../widgets/barra_progresso.dart';

class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final _formKey = GlobalKey<FormState>();
  int _etapaAtual = 1;
  static const int _totalEtapas = 3;
  bool _isPessoaJuridica = false;

  // Controllers
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _cpfCnpjController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _creciController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();

  // Masks
  final _cpfMask = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {'#': RegExp(r'[0-9]')},
  );
  final _cnpjMask = MaskTextInputFormatter(
    mask: '##.###.###/####-##',
    filter: {'#': RegExp(r'[0-9]')},
  );
  final _telefoneMask = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {'#': RegExp(r'[0-9]')},
  );

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  Map<String, String> _erros = {};

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _cpfCnpjController.dispose();
    _telefoneController.dispose();
    _creciController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  bool _validarEtapa() {
    setState(() => _erros = {});

    if (_etapaAtual == 1) {
      if (_nomeController.text.trim().isEmpty) {
        _erros['nome'] = 'Nome completo é obrigatório';
      }
      if (_emailController.text.trim().isEmpty) {
        _erros['email'] = 'Email é obrigatório';
      } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
          .hasMatch(_emailController.text)) {
        _erros['email'] = 'Email inválido';
      }
      final cpfCnpj = _cpfCnpjController.text.replaceAll(RegExp(r'\D'), '');
      if (cpfCnpj.isEmpty) {
        _erros['cpfCnpj'] = '${_isPessoaJuridica ? 'CNPJ' : 'CPF'} é obrigatório';
      } else if (!_isPessoaJuridica && cpfCnpj.length != 11) {
        _erros['cpfCnpj'] = 'CPF deve ter 11 dígitos';
      } else if (_isPessoaJuridica && cpfCnpj.length != 14) {
        _erros['cpfCnpj'] = 'CNPJ deve ter 14 dígitos';
      }
    }

    if (_etapaAtual == 2) {
      final telefone = _telefoneController.text.replaceAll(RegExp(r'\D'), '');
      if (telefone.isEmpty) {
        _erros['telefone'] = 'Telefone é obrigatório';
      } else if (telefone.length != 11) {
        _erros['telefone'] = 'Telefone deve ter 11 dígitos';
      }
      if (_creciController.text.trim().isEmpty) {
        _erros['creci'] = 'CRECI é obrigatório';
      }
    }

    if (_etapaAtual == 3) {
      if (_senhaController.text.isEmpty) {
        _erros['senha'] = 'Senha é obrigatória';
      } else if (_senhaController.text.length < 6) {
        _erros['senha'] = 'Senha deve ter pelo menos 6 caracteres';
      }
      if (_confirmarSenhaController.text.isEmpty) {
        _erros['confirmarSenha'] = 'Confirmação de senha é obrigatória';
      } else if (_senhaController.text != _confirmarSenhaController.text) {
        _erros['confirmarSenha'] = 'Senhas não coincidem';
      }
    }

    setState(() {});
    return _erros.isEmpty;
  }

  Future<void> _proximaEtapa() async {
    if (!_validarEtapa()) return;

    if (_etapaAtual < _totalEtapas) {
      setState(() => _etapaAtual++);
    } else {
      await _finalizarCadastro();
    }
  }

  void _etapaAnterior() {
    if (_etapaAtual > 1) {
      setState(() => _etapaAtual--);
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _finalizarCadastro() async {
    final authProvider = context.read<AuthProvider>();

    final result = await authProvider.register(
      nomeCompleto: _nomeController.text.trim(),
      email: _emailController.text.trim(),
      cpfCnpj: _cpfCnpjController.text,
      isPessoaJuridica: _isPessoaJuridica,
      telefone: _telefoneController.text,
      creci: _creciController.text.trim(),
      senha: _senhaController.text,
      confirmarSenha: _confirmarSenhaController.text,
    );

    if (!mounted) return;

    if (result['success'] == true) {
      Navigator.pushReplacementNamed(context, AppRoutes.cadastroSucesso);
    } else {
      // Handle API errors
      if (result['errors'] != null) {
        final apiErrors = result['errors'] as Map<String, List<String>>;
        setState(() {
          _erros = apiErrors.map((key, value) => MapEntry(key, value.first));
        });

        // Navigate to the step with errors
        if (_erros.containsKey('nomeCompleto') ||
            _erros.containsKey('email') ||
            _erros.containsKey('cpfCnpj')) {
          setState(() => _etapaAtual = 1);
        } else if (_erros.containsKey('telefone') ||
            _erros.containsKey('creci')) {
          setState(() => _etapaAtual = 2);
        } else if (_erros.containsKey('senha')) {
          setState(() => _etapaAtual = 3);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Erro no cadastro'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header
          _buildHeader(),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    BarraProgresso(
                      etapaAtual: _etapaAtual,
                      totalEtapas: _totalEtapas,
                    ),
                    const SizedBox(height: 24),
                    _buildEtapaAtual(),
                    const SizedBox(height: 32),
                    _buildBotao(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primaryBlue,
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              IconButton(
                onPressed: _etapaAnterior,
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.1),
                ),
              ),
              const Expanded(
                child: Text(
                  'Novo Cadastro',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 48), // Balance the back button
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEtapaAtual() {
    switch (_etapaAtual) {
      case 1:
        return _buildEtapa1();
      case 2:
        return _buildEtapa2();
      case 3:
        return _buildEtapa3();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildEtapa1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Dados Pessoais',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Vamos começar com suas informações básicas',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 24),

        CampoInput(
          label: 'Nome Completo',
          hint: 'Seu nome completo',
          controller: _nomeController,
          prefixIcon: Icons.person_outline,
          error: _erros['nome'] ?? _erros['nomeCompleto'],
        ),
        const SizedBox(height: 16),

        CampoInput(
          label: 'Email',
          hint: 'seu@email.com',
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          prefixIcon: Icons.mail_outline,
          error: _erros['email'],
        ),
        const SizedBox(height: 16),

        CampoInput(
          label: _isPessoaJuridica ? 'CNPJ' : 'CPF',
          hint: _isPessoaJuridica ? '00.000.000/0000-00' : '000.000.000-00',
          controller: _cpfCnpjController,
          keyboardType: TextInputType.number,
          prefixIcon: Icons.description_outlined,
          inputFormatters: [_isPessoaJuridica ? _cnpjMask : _cpfMask],
          error: _erros['cpfCnpj'],
        ),
        const SizedBox(height: 16),

        // Toggle for Pessoa Jurídica
        GestureDetector(
          onTap: () {
            setState(() {
              _isPessoaJuridica = !_isPessoaJuridica;
              _cpfCnpjController.clear();
            });
          },
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: _isPessoaJuridica
                      ? AppColors.primaryGold
                      : Colors.transparent,
                  border: Border.all(
                    color: _isPessoaJuridica
                        ? AppColors.primaryGold
                        : AppColors.border,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: _isPessoaJuridica
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 12),
              const Text(
                'Sou pessoa jurídica (CNPJ)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEtapa2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Contato e Profissão',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Agora suas informações de contato',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 24),

        CampoInput(
          label: 'Telefone',
          hint: '(00) 00000-0000',
          controller: _telefoneController,
          keyboardType: TextInputType.phone,
          prefixIcon: Icons.phone_outlined,
          inputFormatters: [_telefoneMask],
          error: _erros['telefone'],
        ),
        const SizedBox(height: 16),

        CampoInput(
          label: 'CRECI',
          hint: 'Digite seu número do CRECI',
          controller: _creciController,
          prefixIcon: Icons.business_outlined,
          error: _erros['creci'],
        ),
      ],
    );
  }

  Widget _buildEtapa3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Segurança',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Por último, defina sua senha de acesso',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 24),

        CampoInput(
          label: 'Senha',
          hint: 'Mínimo 6 caracteres',
          controller: _senhaController,
          obscureText: _obscurePassword,
          prefixIcon: Icons.lock_outline,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility,
              color: AppColors.textSecondary,
            ),
            onPressed: () {
              setState(() => _obscurePassword = !_obscurePassword);
            },
          ),
          error: _erros['senha'],
        ),
        const SizedBox(height: 16),

        CampoInput(
          label: 'Confirmar Senha',
          hint: 'Confirme sua senha',
          controller: _confirmarSenhaController,
          obscureText: _obscureConfirmPassword,
          prefixIcon: Icons.lock_outline,
          suffixIcon: IconButton(
            icon: Icon(
              _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
              color: AppColors.textSecondary,
            ),
            onPressed: () {
              setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
            },
          ),
          error: _erros['confirmarSenha'],
        ),
      ],
    );
  }

  Widget _buildBotao() {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        final isLastStep = _etapaAtual == _totalEtapas;
        
        return SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: auth.isLoading ? null : _proximaEtapa,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGold,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
            ),
            child: auth.isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    isLastStep ? 'Criar Conta' : 'Continuar',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
          ),
        );
      },
    );
  }
}

