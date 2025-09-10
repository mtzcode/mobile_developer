import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:firebase_app_check/firebase_app_check.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/logger.dart';
import 'core/error/error_handler.dart';
import 'data/services/notification_service.dart';

import 'presentation/widgets/auth_wrapper.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/cadastro01_screen.dart';
import 'presentation/screens/cadastro02_screen.dart';
import 'presentation/screens/splash_produtos_screen.dart';
import 'presentation/screens/produtos_screen.dart';
import 'presentation/screens/carrinho_screen.dart';
import 'presentation/screens/notificacoes_screen.dart';
import 'presentation/screens/notification_test_screen.dart';
import 'presentation/screens/admin/notification_admin_screen.dart';
import 'presentation/screens/enderecos_screen.dart';
import 'presentation/screens/cadastro_endereco_screen.dart';
import 'presentation/screens/meus_dados_screen.dart';
import 'presentation/screens/redefinir_senha_screen.dart';
import 'presentation/screens/pedidos_screen.dart';

import 'presentation/screens/confirmacao_pedido_screen.dart';
import 'presentation/screens/ajuda_screen.dart';
import 'presentation/screens/sobre_screen.dart';
import 'data/services/carrinho_provider.dart';
import 'data/datasources/firestore_auth_service.dart';
import 'data/services/user_provider.dart';
import 'data/services/pedidos_provider.dart';
import 'firebase_options.dart';
import 'core/utils/snackbar_utils.dart';


/// Handler para notificações em background
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await firebaseMessagingBackgroundHandler(message);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configurar logging
  _configureLogging();
  
  // Inicializar Firebase
  AppLogger.startOperation('Firebase initialization');
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    AppLogger.success('Firebase initialization');
    
    // Configurar handler de background para FCM
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    AppLogger.success('FCM background handler configured');
    

  } catch (e, stackTrace) {
    AppLogger.failure('Firebase initialization', 'Erro ao inicializar Firebase', e, stackTrace);
    rethrow;
  }
  
  // Configurar AppCheck (desabilitado temporariamente para debug)
  // await FirebaseAppCheck.instance.activate(
  //   androidProvider: AndroidProvider.debug,
  //   appleProvider: AppleProvider.debug,
  // );

  AppLogger.info('Aplicativo iniciado com sucesso');
  runApp(const MyApp());
  
  // Inicializar sistema de notificações após o app estar rodando
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _initializeNotificationSystem();
  });
}

/// Configura o sistema de logging baseado no ambiente
void _configureLogging() {
  // Em produção, você pode definir isso baseado em variáveis de ambiente
  const bool isProduction = bool.fromEnvironment('dart.vm.product', defaultValue: false);
  
  AppLogger.setProductionMode(isProduction);
  
  if (isProduction) {
    AppLogger.info('Modo de produção ativado - logs de debug desabilitados');
  } else {
    AppLogger.info('Modo de desenvolvimento ativado - todos os logs habilitados');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    AppLogger.ui('Construindo widget MyApp');
    
    // Configurar ErrorHandler
    _configureErrorHandler();
    
    return ProviderScope(
      child: provider.MultiProvider(
        providers: [
          provider.ChangeNotifierProvider(create: (_) => UserProvider()),
          provider.Provider<FirestoreAuthService>(create: (_) => FirestoreAuthService()),
          provider.ChangeNotifierProxyProvider<UserProvider, CarrinhoProvider>(
            create: (_) => CarrinhoProvider(userId: ''),
            update: (context, userProvider, previous) {
              final userId = userProvider.usuarioLogado?.id;
              if (userId != null && userId.isNotEmpty) {
                return CarrinhoProvider(userId: userId);
              } else {
                return CarrinhoProvider(userId: '');
              }
            },
          ),
          provider.ChangeNotifierProxyProvider<UserProvider, PedidosProvider>(
            create: (_) => PedidosProvider(userId: ''),
            update: (context, userProvider, previous) {
              final userId = userProvider.usuarioLogado?.id;
              if (userId != null && userId.isNotEmpty) {
                return PedidosProvider(userId: userId);
              } else {
                return PedidosProvider(userId: '');
              }
            },
          ),
        ],
        child: MaterialApp(
        title: 'Mercado Fácil',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        navigatorKey: appNavigatorKey, // Usar navigatorKey global
        home: const AuthWrapper(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/cadastro01': (context) => const Cadastro01Screen(),
          '/cadastro02': (context) => const Cadastro02Screen(),
          '/home': (context) => const SplashProdutosScreen(),
          '/splash_produtos': (context) => const SplashProdutosScreen(),
          '/produtos': (context) => const ProdutosScreen(),
          '/carrinho': (context) => const CarrinhoScreen(),
          '/notificacoes': (context) => const NotificacoesScreen(),
          '/notification-test': (context) => const NotificationTestScreen(),
          '/notification-admin': (context) => const NotificationAdminScreen(),
          '/enderecos': (context) => const EnderecosScreen(),
          '/cadastro-endereco': (context) => const CadastroEnderecoScreen(),
          '/perfil': (context) => const MeusDadosScreen(),
          '/redefinir_senha': (context) => const RedefinirSenhaScreen(),
          '/pedidos': (context) => const PedidosScreen(),
          '/confirmacao-pedido': (context) => const ConfirmacaoPedidoScreen(),
          '/ajuda': (context) => const AjudaScreen(),
          '/sobre': (context) => const SobreScreen(),
        },
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: MediaQuery.of(context).textScaler.clamp(
                minScaleFactor: 0.8,
                maxScaleFactor: 1.5,
              ),
            ),
            child: child!,
          );
        },
      ),
      ),
    );
  }

  /// Configura o ErrorHandler com os callbacks necessários
  void _configureErrorHandler() {
    ErrorHandler.configure(
      showError: (message, {title, icon, color}) {
        // Este callback será configurado quando tivermos acesso ao context
        AppLogger.operationWarning('ErrorHandler não configurado com context', 'Mensagem: $message');
      },
      showLoading: (show) {
        // Este callback será configurado quando tivermos acesso ao context
        AppLogger.info('Loading ${show ? "iniciado" : "finalizado"}');
      },
      navigate: (route, {arguments}) {
        // Este callback será configurado quando tivermos acesso ao context
        AppLogger.navigation('Navegação solicitada: $route');
      },
    );
  }
}

/// Inicializa o sistema completo de notificações multi-canal
Future<void> _initializeNotificationSystem() async {
  try {
    AppLogger.startOperation('Notification system initialization');
    
    // Aguarda um pouco para garantir que o app está totalmente carregado
    await Future.delayed(const Duration(seconds: 2));
    
    // Inicializar serviços de notificação básicos
    final notificationService = NotificationService();
    await notificationService.initialize();
    
    AppLogger.success('Sistema de notificações multi-canal inicializado');
    AppLogger.info('✅ Email Service: Configurado');
    AppLogger.info('✅ Push Notifications: Ativo');
    AppLogger.info('✅ Favorites Promotion Detector: Pronto');
    AppLogger.info('✅ Cart Reminder Service: Pronto');
    AppLogger.info('✅ Notification Scheduler: Aguardando usuário logado');
    
    AppLogger.success('Notification system initialization');
    
  } catch (e, stackTrace) {
    AppLogger.failure(
      'Notification system initialization',
      'Erro ao inicializar sistema de notificações',
      e,
      stackTrace,
    );
  }
}