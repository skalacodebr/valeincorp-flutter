import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../config/theme.dart';
import '../config/routes.dart';
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/bottom_navigation.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildUserCard(),
                  const SizedBox(height: 24),
                  _buildMenuSection(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavigation(currentItem: NavItem.perfil),
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
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 12),
              const Text(
                'Meu Perfil',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserCard() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primaryGold,
                    width: 3,
                  ),
                ),
                child: ClipOval(
                  child: userProvider.fotoUsuario != null
                      ? CachedNetworkImage(
                          imageUrl: userProvider.fotoUsuario!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: AppColors.background,
                            child: const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primaryGold,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: AppColors.background,
                            child: const Icon(
                              Icons.person,
                              size: 35,
                              color: AppColors.textHint,
                            ),
                          ),
                        )
                      : Container(
                          color: AppColors.background,
                          child: const Icon(
                            Icons.person,
                            size: 35,
                            color: AppColors.textHint,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 16),
              
              // User info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userProvider.nome,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userProvider.email,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGold.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'CRECI: ${userProvider.creci}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.primaryGold,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuSection() {
    final menuItems = [
      _MenuItem(
        icon: Icons.person_outline,
        title: 'Meus Dados',
        subtitle: 'Edite suas informações pessoais',
        route: AppRoutes.meusDados,
      ),
      _MenuItem(
        icon: Icons.lock_outline,
        title: 'Alterar Senha',
        subtitle: 'Atualize sua senha de acesso',
        route: AppRoutes.alterarSenha,
      ),
      _MenuItem(
        icon: Icons.help_outline,
        title: 'Dúvidas',
        subtitle: 'Perguntas frequentes',
        onTap: () => _mostrarEmBreve(),
      ),
      _MenuItem(
        icon: Icons.description_outlined,
        title: 'Termos de Uso',
        subtitle: 'Termos e condições do app',
        onTap: () => _mostrarEmBreve(),
      ),
      _MenuItem(
        icon: Icons.privacy_tip_outlined,
        title: 'Política de Privacidade',
        subtitle: 'Como tratamos seus dados',
        onTap: () => _mostrarEmBreve(),
      ),
      _MenuItem(
        icon: Icons.logout,
        title: 'Sair da Conta',
        subtitle: 'Encerrar sessão',
        isLogout: true,
        onTap: () => _confirmarLogout(),
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: menuItems.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          
          return Column(
            children: [
              _buildMenuItem(item),
              if (index < menuItems.length - 1)
                const Divider(height: 1, indent: 56),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMenuItem(_MenuItem item) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: item.isLogout
              ? AppColors.error.withOpacity(0.1)
              : AppColors.primaryBlue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          item.icon,
          color: item.isLogout ? AppColors.error : AppColors.primaryBlue,
          size: 20,
        ),
      ),
      title: Text(
        item.title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: item.isLogout ? AppColors.error : AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        item.subtitle,
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.textSecondary,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: item.isLogout ? AppColors.error : AppColors.textHint,
      ),
      onTap: () {
        if (item.onTap != null) {
          item.onTap!();
        } else if (item.route != null) {
          Navigator.pushNamed(context, item.route!);
        }
      },
    );
  }

  void _mostrarEmBreve() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidade em breve!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _confirmarLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair da conta?'),
        content: const Text(
          'Tem certeza que deseja encerrar sua sessão?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<AuthProvider>().logout();
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.onboarding,
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? route;
  final VoidCallback? onTap;
  final bool isLogout;

  _MenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.route,
    this.onTap,
    this.isLogout = false,
  });
}

