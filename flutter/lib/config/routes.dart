import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/login_screen.dart';
import '../screens/cadastro_screen.dart';
import '../screens/cadastro_sucesso_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/buscar_screen.dart';
import '../screens/empreendimentos_screen.dart';
import '../screens/imovel_detalhes_screen.dart';
import '../screens/unidade_detalhes_screen.dart';
import '../screens/favoritos_screen.dart';
import '../screens/atividades_screen.dart';
import '../screens/perfil_screen.dart';
import '../screens/meus_dados_screen.dart';
import '../screens/alterar_senha_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String cadastro = '/cadastro';
  static const String cadastroSucesso = '/cadastro-sucesso';
  static const String dashboard = '/dashboard';
  static const String buscar = '/buscar';
  static const String empreendimentos = '/empreendimentos';
  static const String imovelDetalhes = '/imovel';
  static const String unidadeDetalhes = '/unidade';
  static const String favoritos = '/favoritos';
  static const String atividades = '/atividades';
  static const String perfil = '/perfil';
  static const String meusDados = '/perfil/meus-dados';
  static const String alterarSenha = '/perfil/alterar-senha';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      
      case onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      
      case cadastro:
        return MaterialPageRoute(builder: (_) => const CadastroScreen());
      
      case cadastroSucesso:
        return MaterialPageRoute(builder: (_) => const CadastroSucessoScreen());
      
      case dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardScreen());
      
      case buscar:
        return MaterialPageRoute(builder: (_) => const BuscarScreen());
      
      case empreendimentos:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => EmpreendimentosScreen(filtros: args),
        );
      
      case imovelDetalhes:
        final imovelId = settings.arguments as int;
        return MaterialPageRoute(
          builder: (_) => ImovelDetalhesScreen(imovelId: imovelId),
        );
      
      case unidadeDetalhes:
        final unidadeId = settings.arguments as int;
        return MaterialPageRoute(
          builder: (_) => UnidadeDetalhesScreen(unidadeId: unidadeId),
        );
      
      case favoritos:
        return MaterialPageRoute(builder: (_) => const FavoritosScreen());
      
      case atividades:
        return MaterialPageRoute(builder: (_) => const AtividadesScreen());
      
      case perfil:
        return MaterialPageRoute(builder: (_) => const PerfilScreen());
      
      case meusDados:
        return MaterialPageRoute(builder: (_) => const MeusDadosScreen());
      
      case alterarSenha:
        return MaterialPageRoute(builder: (_) => const AlterarSenhaScreen());
      
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Rota não encontrada: ${settings.name}'),
            ),
          ),
        );
    }
  }
}

