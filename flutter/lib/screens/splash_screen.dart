import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../config/routes.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeInController;
  late AnimationController _fadeOutController;
  late Animation<double> _fadeInAnimation;
  late Animation<double> _fadeOutAnimation;

  bool _showContent = false;
  bool _isFadingOut = false;

  @override
  void initState() {
    super.initState();

    // Controlador para fade in
    _fadeInController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Controlador para fade out
    _fadeOutController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Animação fade in com curva suave
    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeInController,
        curve: Curves.easeInOut,
      ),
    );

    // Animação fade out com curva suave
    _fadeOutAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _fadeOutController,
        curve: Curves.easeInOut,
      ),
    );

    _startAnimations();
  }

  Future<void> _startAnimations() async {
    // Pequeno delay inicial para garantir que a tela está montada
    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted) return;

    setState(() {
      _showContent = true;
    });

    // Iniciar fade in
    await _fadeInController.forward();

    if (!mounted) return;

    // Verificar autenticação durante a exibição do logo
    final authProvider = context.read<AuthProvider>();
    await authProvider.init();

    // Manter o logo visível por um tempo
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    // Iniciar fade out
    setState(() {
      _isFadingOut = true;
    });

    await _fadeOutController.forward();

    if (!mounted) return;

    // Navegar para próxima tela
    _navigateToNextScreen(authProvider);
  }

  void _navigateToNextScreen(AuthProvider authProvider) {
    if (authProvider.isAuthenticated) {
      Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
    }
  }

  @override
  void dispose() {
    _fadeInController.dispose();
    _fadeOutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryBlue,
              Color(0xFF0D1831),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Elementos decorativos sutis no background
            _buildBackgroundElements(),

            // Logo centralizado com animação
            Center(
              child: _showContent
                  ? AnimatedBuilder(
                      animation:
                          _isFadingOut ? _fadeOutController : _fadeInController,
                      builder: (context, child) {
                        final opacity = _isFadingOut
                            ? _fadeOutAnimation.value
                            : _fadeInAnimation.value;

                        return Opacity(
                          opacity: opacity,
                          child: Transform.scale(
                            scale: 0.95 + (0.05 * opacity),
                            child: _buildLogo(),
                          ),
                        );
                      },
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundElements() {
    return Stack(
      children: [
        // Círculo decorativo superior esquerdo
        Positioned(
          top: -80,
          left: -80,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.primaryGold.withOpacity(0.08),
                  AppColors.primaryGold.withOpacity(0.0),
                ],
              ),
            ),
          ),
        ),

        // Círculo decorativo inferior direito
        Positioned(
          bottom: -120,
          right: -80,
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.white.withOpacity(0.04),
                  Colors.white.withOpacity(0.0),
                ],
              ),
            ),
          ),
        ),

        // Linha decorativa dourada sutil
        Positioned(
          top: MediaQuery.of(context).size.height * 0.3,
          left: 0,
          right: 0,
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppColors.primaryGold.withOpacity(0.1),
                  AppColors.primaryGold.withOpacity(0.2),
                  AppColors.primaryGold.withOpacity(0.1),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Linha decorativa inferior
        Positioned(
          bottom: MediaQuery.of(context).size.height * 0.3,
          left: 0,
          right: 0,
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppColors.primaryGold.withOpacity(0.1),
                  AppColors.primaryGold.withOpacity(0.2),
                  AppColors.primaryGold.withOpacity(0.1),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLogo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Image.asset(
        'assets/images/VERSAO-HORIZONTAL-COM-LETRAS-BRANCAS-e1741152352785.png',
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          // Fallback se o logo não carregar
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.apartment_rounded,
                size: 70,
                color: Colors.white,
              ),
              const SizedBox(height: 16),
              Text(
                'VALE INCORP',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 4,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
