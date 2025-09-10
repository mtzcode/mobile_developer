import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/services/user_provider.dart';
import '../../core/utils/logger.dart';
import '../screens/login_screen.dart';
import '../screens/splash_produtos_screen.dart';
import '../screens/cadastro02_screen.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    AppLogger.auth('AuthWrapper inicializado');
    
    // Usar addPostFrameCallback para evitar chamadas durante o build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthStatus();
    });
  }

  Future<void> _checkAuthStatus() async {
    AppLogger.auth('Verificando status de autenticação');
    
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.carregarUsuarioLogado();
      
      AppLogger.auth('Status de autenticação verificado', 'Logado: ${userProvider.isLoggedIn}');
    } catch (e, stackTrace) {
      AppLogger.failure('Verificação de autenticação', 'Erro ao verificar status', e, stackTrace);
    }
  }

  @override
  Widget build(BuildContext context) {
    AppLogger.ui('Construindo AuthWrapper');
    
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        // Mostrar loading enquanto não foi inicializado
        if (!userProvider.isInitialized) {
          AppLogger.ui('AuthWrapper: Mostrando loading (não inicializado)');
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (userProvider.isLoggedIn) {
          final usuario = userProvider.usuarioLogado;
          if (usuario != null && usuario.cadastroCompleto == true) {
            AppLogger.auth('Usuário logado e cadastro completo', 'ID: ${usuario.id}');
            return const SplashProdutosScreen();
          } else {
            AppLogger.auth('Usuário logado mas cadastro incompleto', 'ID: ${usuario?.id}');
            return const Cadastro02Screen();
          }
        } else {
          AppLogger.auth('Usuário não logado - redirecionando para login');
          return const LoginScreen();
        }
      },
    );
  }
} 