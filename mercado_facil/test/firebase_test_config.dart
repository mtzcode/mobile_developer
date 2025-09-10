import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mercado_facil/data/services/carrinho_provider.dart';


/// Configuração de teste que evita inicialização do Firebase
class FirebaseTestConfig {
  static const Duration defaultTimeout = Duration(seconds: 30);
  static const Duration shortTimeout = Duration(seconds: 5);
  
  /// Setup para testes sem Firebase
  static Widget createTestApp({
    required Widget child,
    List<ChangeNotifierProvider> providers = const [],
    String testUserId = 'test_user_123',
  }) {
    return MaterialApp(
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => CarrinhoProvider(userId: testUserId)),
          // Mock providers para evitar Firebase
          ...providers,
        ],
        child: child,
      ),
    );
  }
  
  /// Setup para testes de integração sem Firebase
  static Widget createIntegrationTestApp({
    required Widget child,
  }) {
    return MaterialApp(
      title: 'Mercado Fácil Test',
      home: child,
      debugShowCheckedModeBanner: false,
    );
  }
  
  /// Utilitário para aguardar animações
  static Future<void> waitForAnimations(WidgetTester tester) async {
    await tester.pumpAndSettle();
  }
  
  /// Utilitário para aguardar operações assíncronas
  static Future<void> waitForAsync(WidgetTester tester) async {
    await tester.pump();
    await Future.delayed(const Duration(milliseconds: 100));
    await tester.pump();
  }
  
  /// Utilitário para encontrar widgets por texto
  static Finder findText(String text) {
    return find.text(text);
  }
  
  /// Utilitário para encontrar widgets por tipo
  static Finder findWidget<T extends Widget>() {
    return find.byType(T);
  }
  
  /// Utilitário para encontrar widgets por chave
  static Finder findKey(Key key) {
    return find.byKey(key);
  }
}

/// Mocks para evitar Firebase
class MockUserProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}

class MockPedidosProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}

/// Extensões úteis para testes
extension WidgetTesterExtensions on WidgetTester {
  /// Toca em um widget e aguarda animações
  Future<void> tapAndWait(Finder finder) async {
    await tap(finder);
    await FirebaseTestConfig.waitForAnimations(this);
  }
  
  /// Insere texto e aguarda
  Future<void> enterTextAndWait(Finder finder, String text) async {
    await enterText(finder, text);
    await FirebaseTestConfig.waitForAsync(this);
  }
  
  /// Desliza e aguarda
  Future<void> dragAndWait(Finder finder, Offset offset) async {
    await drag(finder, offset);
    await FirebaseTestConfig.waitForAnimations(this);
  }
}

/// Constantes para testes
class TestConstants {
  // URLs de teste
  static const String testImageUrl = 'https://via.placeholder.com/150';
  static const String testProductId = 'test_product_123';
  static const String testUserId = 'test_user_123';
  
  // Dados de teste
  static const String testEmail = 'test@example.com';
  static const String testPassword = 'Test123!@#';
  static const String testName = 'Usuário Teste';
  static const String testPhone = '11999999999';
  static const String testCpf = '12345678901';
  static const String testCep = '01234567';
  
  // Timeouts
  static const Duration networkTimeout = Duration(seconds: 10);
  static const Duration animationTimeout = Duration(seconds: 5);
  static const Duration loadingTimeout = Duration(seconds: 3);
}