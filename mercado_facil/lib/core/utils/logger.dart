import 'package:logger/logger.dart';

/// Sistema de logging profissional centralizado para o app Mercado Fácil
/// 
/// Fornece diferentes níveis de log:
/// - debug: Para informações detalhadas de desenvolvimento
/// - info: Para informações gerais do app
/// - warning: Para avisos que não quebram a funcionalidade
/// - error: Para erros que afetam a funcionalidade
/// - fatal: Para erros críticos que podem quebrar o app
class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2, // Número de linhas de stack trace
      errorMethodCount: 8, // Número de linhas de stack trace para erros
      lineLength: 120, // Comprimento da linha
      colors: true, // Cores no console
      printEmojis: true, // Emojis para diferentes níveis
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart, // Mostrar timestamp
    ),
    output: ConsoleOutput(), // Saída para console
  );

  // Configuração para produção (sem debug)
  static final Logger _productionLogger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 80,
      colors: false,
      printEmojis: false,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
    output: ConsoleOutput(),
  );

  static bool _isProduction = false;

  /// Configura o modo de produção
  static void setProductionMode(bool isProduction) {
    _isProduction = isProduction;
  }

  /// Log de debug - informações detalhadas para desenvolvimento
  static void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    if (!_isProduction) {
      _logger.d(message, error: error, stackTrace: stackTrace);
    }
  }

  /// Log de informação - informações gerais do app
  static void info(String message, [dynamic error, StackTrace? stackTrace]) {
    if (_isProduction) {
      _productionLogger.i(message, error: error, stackTrace: stackTrace);
    } else {
      _logger.i(message, error: error, stackTrace: stackTrace);
    }
  }

  /// Log de aviso - situações que merecem atenção mas não quebram a funcionalidade
  static void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    if (_isProduction) {
      _productionLogger.w(message, error: error, stackTrace: stackTrace);
    } else {
      _logger.w(message, error: error, stackTrace: stackTrace);
    }
  }

  /// Log de erro - erros que afetam a funcionalidade
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    if (_isProduction) {
      _productionLogger.e(message, error: error, stackTrace: stackTrace);
    } else {
      _logger.e(message, error: error, stackTrace: stackTrace);
    }
  }

  /// Log fatal - erros críticos que podem quebrar o app
  static void fatal(String message, [dynamic error, StackTrace? stackTrace]) {
    if (_isProduction) {
      _productionLogger.f(message, error: error, stackTrace: stackTrace);
    } else {
      _logger.f(message, error: error, stackTrace: stackTrace);
    }
  }

  /// Log específico para operações de API/Firestore
  static void api(String message, [dynamic error, StackTrace? stackTrace]) {
    final apiMessage = '[API] $message';
    if (_isProduction) {
      _productionLogger.i(apiMessage, error: error, stackTrace: stackTrace);
    } else {
      _logger.i(apiMessage, error: error, stackTrace: stackTrace);
    }
  }

  /// Log específico para operações de cache
  static void cache(String message, [dynamic error, StackTrace? stackTrace]) {
    final cacheMessage = '[CACHE] $message';
    if (_isProduction) {
      _productionLogger.i(cacheMessage, error: error, stackTrace: stackTrace);
    } else {
      _logger.i(cacheMessage, error: error, stackTrace: stackTrace);
    }
  }

  /// Log específico para operações de autenticação
  static void auth(String message, [dynamic error, StackTrace? stackTrace]) {
    final authMessage = '[AUTH] $message';
    if (_isProduction) {
      _productionLogger.i(authMessage, error: error, stackTrace: stackTrace);
    } else {
      _logger.i(authMessage, error: error, stackTrace: stackTrace);
    }
  }

  /// Log específico para operações de carrinho
  static void cart(String message, [dynamic error, StackTrace? stackTrace]) {
    final cartMessage = '[CART] $message';
    if (_isProduction) {
      _productionLogger.i(cartMessage, error: error, stackTrace: stackTrace);
    } else {
      _logger.i(cartMessage, error: error, stackTrace: stackTrace);
    }
  }

  /// Log específico para operações de pedidos
  static void order(String message, [dynamic error, StackTrace? stackTrace]) {
    final orderMessage = '[ORDER] $message';
    if (_isProduction) {
      _productionLogger.i(orderMessage, error: error, stackTrace: stackTrace);
    } else {
      _logger.i(orderMessage, error: error, stackTrace: stackTrace);
    }
  }

  /// Log específico para operações de produtos
  static void product(String message, [dynamic error, StackTrace? stackTrace]) {
    final productMessage = '[PRODUCT] $message';
    if (_isProduction) {
      _productionLogger.i(productMessage, error: error, stackTrace: stackTrace);
    } else {
      _logger.i(productMessage, error: error, stackTrace: stackTrace);
    }
  }

  /// Log específico para operações de UI
  static void ui(String message, [dynamic error, StackTrace? stackTrace]) {
    final uiMessage = '[UI] $message';
    if (!_isProduction) {
      _logger.d(uiMessage, error: error, stackTrace: stackTrace);
    }
  }

  /// Log específico para operações de navegação
  static void navigation(String message, [dynamic error, StackTrace? stackTrace]) {
    final navMessage = '[NAV] $message';
    if (!_isProduction) {
      _logger.d(navMessage, error: error, stackTrace: stackTrace);
    }
  }

  /// Log específico para operações de performance
  static void performance(String message, [dynamic error, StackTrace? stackTrace]) {
    final perfMessage = '[PERF] $message';
    if (_isProduction) {
      _productionLogger.i(perfMessage, error: error, stackTrace: stackTrace);
    } else {
      _logger.i(perfMessage, error: error, stackTrace: stackTrace);
    }
  }

  /// Log específico para operações de segurança
  static void security(String message, [dynamic error, StackTrace? stackTrace]) {
    final secMessage = '[SECURITY] $message';
    if (_isProduction) {
      _productionLogger.w(secMessage, error: error, stackTrace: stackTrace);
    } else {
      _logger.w(secMessage, error: error, stackTrace: stackTrace);
    }
  }

  /// Log de início de operação
  static void startOperation(String operation) {
    final startMessage = '🚀 Iniciando: $operation';
    if (!_isProduction) {
      _logger.i(startMessage);
    }
  }

  /// Log de fim de operação
  static void endOperation(String operation) {
    final endMessage = '✅ Finalizado: $operation';
    if (!_isProduction) {
      _logger.i(endMessage);
    }
  }

  /// Log de operação com sucesso
  static void success(String operation, [String? details]) {
    final successMessage = details != null 
        ? '✅ Sucesso: $operation - $details'
        : '✅ Sucesso: $operation';
    if (_isProduction) {
      _productionLogger.i(successMessage);
    } else {
      _logger.i(successMessage);
    }
  }

  /// Log de operação com falha
  static void failure(String operation, [String? details, dynamic error, StackTrace? stackTrace]) {
    final failureMessage = details != null 
        ? '❌ Falha: $operation - $details'
        : '❌ Falha: $operation';
    if (_isProduction) {
      _productionLogger.e(failureMessage, error: error, stackTrace: stackTrace);
    } else {
      _logger.e(failureMessage, error: error, stackTrace: stackTrace);
    }
  }

  /// Log de operação com aviso
  static void operationWarning(String operation, [String? details, dynamic error, StackTrace? stackTrace]) {
    final warningMessage = details != null 
        ? '⚠️ Aviso: $operation - $details'
        : '⚠️ Aviso: $operation';
    if (_isProduction) {
      _productionLogger.w(warningMessage, error: error, stackTrace: stackTrace);
    } else {
      _logger.w(warningMessage, error: error, stackTrace: stackTrace);
    }
  }
}