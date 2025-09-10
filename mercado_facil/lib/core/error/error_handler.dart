import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../exceptions/app_exception.dart';
import '../utils/logger.dart';

/// Handler global para tratamento de erros da aplicação
class ErrorHandler {
  static final ErrorHandler _instance = ErrorHandler._internal();
  factory ErrorHandler() => _instance;
  ErrorHandler._internal();

  /// Callback para exibir mensagens de erro para o usuário
  static Function(String message, {String? title, IconData? icon, Color? color})? _showErrorCallback;

  /// Callback para exibir loading
  static Function(bool show)? _showLoadingCallback;

  /// Callback para navegação
  static Function(String route, {Object? arguments})? _navigateCallback;

  /// Configura os callbacks necessários
  static void configure({
    required Function(String message, {String? title, IconData? icon, Color? color}) showError,
    required Function(bool show) showLoading,
    required Function(String route, {Object? arguments}) navigate,
  }) {
    _showErrorCallback = showError;
    _showLoadingCallback = showLoading;
    _navigateCallback = navigate;
  }

  /// Trata uma exceção da aplicação
  static Future<void> handleException(
    AppException exception, {
    String? context,
    bool showToUser = true,
    bool logError = true,
  }) async {
    if (logError) {
      _logException(exception, context);
    }

    if (showToUser) {
      _showErrorToUser(exception);
    }

    // Ações específicas baseadas no tipo de erro
    await _handleSpecificActions(exception);
  }

  /// Trata erros genéricos (não AppException)
  static Future<void> handleError(
    dynamic error, {
    StackTrace? stackTrace,
    String? context,
    bool showToUser = true,
    bool logError = true,
  }) async {
    // Converte erro genérico para AppException
    final appException = convertToAppException(error, stackTrace, context);

    await handleException(
      appException,
      context: context,
      showToUser: showToUser,
      logError: logError,
    );
  }

  /// Executa uma operação com retry automático
  static Future<T> executeWithRetry<T>({
    required Future<T> Function() operation,
    int maxRetries = 3,
    Duration delay = const Duration(seconds: 2),
    String? operationName,
    bool showLoading = true,
  }) async {
    int attempts = 0;
    Exception? lastException;

    while (attempts < maxRetries) {
      try {
        if (showLoading && attempts == 0) {
          _showLoadingCallback?.call(true);
        }

        AppLogger.startOperation(operationName ?? 'Operação com retry');
        
        final result = await operation();
        
        AppLogger.success(operationName ?? 'Operação com retry');
        _showLoadingCallback?.call(false);
        
        return result;
      } catch (error, stackTrace) {
        attempts++;
        lastException = error is Exception ? error : Exception(error.toString());

        AppLogger.failure(
          operationName ?? 'Operação com retry',
          'Tentativa $attempts de $maxRetries',
          error,
          stackTrace,
        );

        // Se não é o último retry, aguarda antes de tentar novamente
        if (attempts < maxRetries) {
          await Future.delayed(delay * attempts); // Delay progressivo
          
          // Mostra mensagem de retry para o usuário
          if (attempts == 1) {
            _showErrorCallback?.call(
              'Tentando novamente...',
              title: 'Erro de conexão',
              icon: Icons.wifi_off,
              color: Colors.orange,
            );
          }
        }
      }
    }

    _showLoadingCallback?.call(false);

    // Se chegou aqui, todas as tentativas falharam
    final appException = convertToAppException(lastException, null, operationName);
    
    AppLogger.failure(
      operationName ?? 'Operação com retry',
      'Todas as $maxRetries tentativas falharam',
      lastException,
    );

    throw appException;
  }

  /// Executa operações críticas com fallback
  static Future<T> executeWithFallback<T>({
    required Future<T> Function() primaryOperation,
    required Future<T> Function() fallbackOperation,
    String? operationName,
  }) async {
    try {
      AppLogger.startOperation('$operationName (operação primária)');
      final result = await primaryOperation();
      AppLogger.success('$operationName (operação primária)');
      return result;
    } catch (error, stackTrace) {
      AppLogger.operationWarning(
        '$operationName (operação primária)',
        'Falhou, tentando fallback',
        error,
        stackTrace,
      );

      try {
        AppLogger.startOperation('$operationName (fallback)');
        final result = await fallbackOperation();
        AppLogger.success('$operationName (fallback)');
        return result;
      } catch (fallbackError, fallbackStackTrace) {
        AppLogger.failure(
          '$operationName (fallback)',
          'Fallback também falhou',
          fallbackError,
          fallbackStackTrace,
        );
        rethrow;
      }
    }
  }

  /// Loga a exceção
  static void _logException(AppException exception, String? context) {
    final contextInfo = context != null ? 'Contexto: $context' : '';
    
    switch (exception.type) {
      case ExceptionType.networkError:
      case ExceptionType.timeoutError:
      case ExceptionType.connectionError:
        AppLogger.api('$contextInfo - ${exception.message}', exception.originalError, exception.stackTrace);
        break;
      case ExceptionType.authenticationError:
      case ExceptionType.authorizationError:
      case ExceptionType.sessionExpired:
        AppLogger.auth('$contextInfo - ${exception.message}', exception.originalError, exception.stackTrace);
        break;
      case ExceptionType.dataNotFound:
        AppLogger.info('$contextInfo - ${exception.message}', exception.originalError, exception.stackTrace);
        break;
      case ExceptionType.validationError:
        AppLogger.operationWarning('$contextInfo - ${exception.message}', null, exception.originalError, exception.stackTrace);
        break;
      case ExceptionType.firebaseError:
      case ExceptionType.firestoreError:
      case ExceptionType.storageError:
        AppLogger.error('$contextInfo - ${exception.message}', exception.originalError, exception.stackTrace);
        break;
      case ExceptionType.insufficientStock:
        AppLogger.order('$contextInfo - ${exception.message}', exception.originalError, exception.stackTrace);
        break;
      case ExceptionType.paymentError:
        AppLogger.error('$contextInfo - ${exception.message}', exception.originalError, exception.stackTrace);
        break;
      default:
        AppLogger.error('$contextInfo - ${exception.message}', exception.originalError, exception.stackTrace);
    }
  }

  /// Exibe erro para o usuário
  static void _showErrorToUser(AppException exception) {
    _showErrorCallback?.call(
      exception.displayMessage,
      title: getErrorTitle(exception.type),
      icon: exception.icon,
      color: exception.color,
    );
  }

  /// Executa ações específicas baseadas no tipo de erro
  static Future<void> _handleSpecificActions(AppException exception) async {
    switch (exception.type) {
      case ExceptionType.authenticationError:
      case ExceptionType.sessionExpired:
        // Redireciona para login
        await Future.delayed(const Duration(seconds: 2));
        _navigateCallback?.call('/login');
        break;
      case ExceptionType.authorizationError:
        // Redireciona para tela de acesso negado
        _navigateCallback?.call('/access-denied');
        break;
      case ExceptionType.networkError:
      case ExceptionType.timeoutError:
        // Vibra para alertar sobre problema de rede
        HapticFeedback.mediumImpact();
        break;
      default:
        // Nenhuma ação específica
        break;
    }
  }

  /// Converte erro genérico para AppException
  static AppException convertToAppException(
    dynamic error,
    StackTrace? stackTrace,
    String? context,
  ) {
    if (error is AppException) {
      return error;
    }

    final errorString = error.toString().toLowerCase();
    final contextInfo = context != null ? 'Contexto: $context' : '';

    // Tenta identificar o tipo de erro baseado na mensagem
    if (errorString.contains('network') || 
        errorString.contains('connection') || 
        errorString.contains('internet')) {
      return AppException.networkError(
        message: '$contextInfo - $error',
        originalError: error,
        stackTrace: stackTrace,
      );
    }

    if (errorString.contains('timeout') || errorString.contains('timed out')) {
      return AppException.timeoutError(
        message: '$contextInfo - $error',
        originalError: error,
        stackTrace: stackTrace,
      );
    }

    if (errorString.contains('auth') || 
        errorString.contains('login') || 
        errorString.contains('session')) {
      return AppException.authenticationError(
        message: '$contextInfo - $error',
        originalError: error,
        stackTrace: stackTrace,
      );
    }

    if (errorString.contains('firebase') || 
        errorString.contains('firestore') || 
        errorString.contains('storage')) {
      return AppException.firebaseError(
        message: '$contextInfo - $error',
        originalError: error,
        stackTrace: stackTrace,
      );
    }

    if (errorString.contains('validation') || 
        errorString.contains('invalid') || 
        errorString.contains('required')) {
      return AppException.validationError(
        message: '$contextInfo - $error',
        originalError: error,
        stackTrace: stackTrace,
      );
    }

    // Erro desconhecido
    return AppException.unknownError(
      message: '$contextInfo - $error',
      originalError: error,
      stackTrace: stackTrace,
    );
  }

  /// Retorna o título do erro baseado no tipo
  static String getErrorTitle(ExceptionType type) {
    switch (type) {
      case ExceptionType.networkError:
      case ExceptionType.timeoutError:
      case ExceptionType.connectionError:
        return 'Erro de Conexão';
      case ExceptionType.authenticationError:
      case ExceptionType.authorizationError:
      case ExceptionType.sessionExpired:
        return 'Erro de Autenticação';
      case ExceptionType.dataNotFound:
        return 'Item Não Encontrado';
      case ExceptionType.validationError:
        return 'Dados Inválidos';
      case ExceptionType.insufficientStock:
        return 'Estoque Insuficiente';
      case ExceptionType.paymentError:
        return 'Erro no Pagamento';
      case ExceptionType.firebaseError:
      case ExceptionType.firestoreError:
      case ExceptionType.storageError:
        return 'Erro do Sistema';
      default:
        return 'Erro';
    }
  }

  /// Limpa os callbacks (útil para testes)
  static void clearCallbacks() {
    _showErrorCallback = null;
    _showLoadingCallback = null;
    _navigateCallback = null;
  }

  /// Getters para testes
  static Function(String message, {String? title, IconData? icon, Color? color})? get showErrorCallback => _showErrorCallback;
  static Function(bool show)? get showLoadingCallback => _showLoadingCallback;
  static Function(String route, {Object? arguments})? get navigateCallback => _navigateCallback;
}