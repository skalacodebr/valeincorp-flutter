import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../config/theme.dart';
import '../providers/user_provider.dart';
import '../widgets/campo_input.dart';
import '../widgets/botao_principal.dart';

class MeusDadosScreen extends StatefulWidget {
  const MeusDadosScreen({super.key});

  @override
  State<MeusDadosScreen> createState() => _MeusDadosScreenState();
}

class _MeusDadosScreenState extends State<MeusDadosScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _cpfController = TextEditingController();
  final _creciController = TextEditingController();
  
  final _telefoneMask = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {'#': RegExp(r'[0-9]')},
  );
  final _cpfMask = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {'#': RegExp(r'[0-9]')},
  );

  bool _editando = false;
  File? _novaFoto;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    _cpfController.dispose();
    _creciController.dispose();
    super.dispose();
  }

  void _carregarDados() {
    final userProvider = context.read<UserProvider>();
    final user = userProvider.user;
    
    if (user != null) {
      _nomeController.text = user.nome;
      _emailController.text = user.email;
      _telefoneController.text = user.telefone;
      _cpfController.text = user.cpfCnpj;
      _creciController.text = user.creci;
    }
  }

  Future<void> _selecionarFoto() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() => _novaFoto = File(image.path));
    }
  }

  Future<void> _salvarDados() async {
    if (!_formKey.currentState!.validate()) return;

    final userProvider = context.read<UserProvider>();
    
    // Upload photo if changed
    if (_novaFoto != null) {
      final photoSuccess = await userProvider.uploadAvatar(_novaFoto!);
      if (!photoSuccess && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(userProvider.error ?? 'Erro ao atualizar foto'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
    
    // Update profile data
    final success = await userProvider.updateProfile(
      nome: _nomeController.text.trim(),
      email: _emailController.text.trim(),
      telefone: _telefoneController.text,
      cpf: _cpfController.text,
      creci: _creciController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      setState(() {
        _editando = false;
        _novaFoto = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Perfil atualizado com sucesso!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(userProvider.error ?? 'Erro ao atualizar perfil'),
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
        title: const Text('Meus Dados'),
        backgroundColor: AppColors.primaryBlue,
        actions: [
          if (!_editando)
            IconButton(
              onPressed: () => setState(() => _editando = true),
              icon: const Icon(Icons.edit),
            ),
        ],
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Avatar
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primaryGold,
                              width: 3,
                            ),
                          ),
                          child: ClipOval(
                            child: _novaFoto != null
                                ? Image.file(_novaFoto!, fit: BoxFit.cover)
                                : userProvider.fotoUsuario != null
                                    ? CachedNetworkImage(
                                        imageUrl: userProvider.fotoUsuario!,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) => Container(
                                          color: AppColors.background,
                                        ),
                                        errorWidget: (context, url, error) =>
                                            _buildDefaultAvatar(),
                                      )
                                    : _buildDefaultAvatar(),
                          ),
                        ),
                        if (_editando)
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: GestureDetector(
                              onTap: _selecionarFoto,
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryGold,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Form fields
                  CampoInput(
                    label: 'Nome Completo',
                    hint: 'Seu nome',
                    controller: _nomeController,
                    prefixIcon: Icons.person_outline,
                    enabled: _editando,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  CampoInput(
                    label: 'Email',
                    hint: 'seu@email.com',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.mail_outline,
                    enabled: _editando,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  CampoInput(
                    label: 'Telefone',
                    hint: '(00) 00000-0000',
                    controller: _telefoneController,
                    keyboardType: TextInputType.phone,
                    prefixIcon: Icons.phone_outlined,
                    inputFormatters: [_telefoneMask],
                    enabled: _editando,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  CampoInput(
                    label: 'CPF',
                    hint: '000.000.000-00',
                    controller: _cpfController,
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.description_outlined,
                    inputFormatters: [_cpfMask],
                    enabled: _editando,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  CampoInput(
                    label: 'CRECI',
                    hint: 'Número do CRECI',
                    controller: _creciController,
                    prefixIcon: Icons.badge_outlined,
                    enabled: _editando,
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Buttons
                  if (_editando) ...[
                    BotaoPrincipal(
                      texto: 'Salvar Alterações',
                      onPressed: _salvarDados,
                      isLoading: userProvider.isLoading,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            _editando = false;
                            _novaFoto = null;
                          });
                          _carregarDados();
                        },
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: AppColors.background,
      child: const Icon(
        Icons.person,
        size: 50,
        color: AppColors.textHint,
      ),
    );
  }
}

