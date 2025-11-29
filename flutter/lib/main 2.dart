import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'config/routes.dart';
import 'providers/auth_provider.dart';
import 'providers/user_provider.dart';
import 'providers/favoritos_provider.dart';
import 'providers/compartilhamentos_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configurar orientação apenas retrato
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Configurar estilo da barra de status
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, UserProvider>(
          create: (_) => UserProvider(),
          update: (_, auth, user) => user!..updateAuth(auth),
        ),
        ChangeNotifierProxyProvider<AuthProvider, FavoritosProvider>(
          create: (_) => FavoritosProvider(),
          update: (_, auth, favoritos) => favoritos!..updateAuth(auth),
        ),
        ChangeNotifierProxyProvider<AuthProvider, CompartilhamentosProvider>(
          create: (_) => CompartilhamentosProvider(),
          update: (_, auth, compartilhamentos) => compartilhamentos!..updateAuth(auth),
        ),
      ],
      child: MaterialApp(
        title: 'Valeincorp',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.splash,
        onGenerateRoute: AppRoutes.generateRoute,
      ),
    );
  }
}

