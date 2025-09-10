import 'package:flutter/material.dart';

/// Enum que define os tipos de exceções da aplicação
enum ExceptionType {
  // Exceções de rede
  networkError,
  timeoutError,
  connectionError,
  
  // Exceções de autenticação
  authenticationError,
  authorizationError,
  sessionExpired,
  
  // Exceções de dados
  dataNotFound,
  invalidData,
  validationError,
  
  // Exceções do Firebase
  firebaseError,
  firestoreError,
  storageError,
  
  // Exceções de negócio
  businessLogicError,
  insufficientStock,
  paymentError,
  
  // Exceções genéricas
  unknownError,
  serverError,
  clientError,
}

/// Classe centralizada para exceções da aplicação
class AppException implements Exception {
  final ExceptionType type;
  final String message;
  final String? userMessage;
  final String? code;
  final dynamic originalError;
  final StackTrace? stackTrace;
  final Map<String, dynamic>? additionalData;

  const AppException({
    required this.type,
    required this.message,
    this.userMessage,
    this.code,
    this.originalError,
    this.stackTrace,
    this.additionalData,
  });

  /// Construtor para erro de rede
  factory AppException.networkError({
    String? message,
    String? userMessage,
    dynamic originalError,
    StackTrace? stackTrace,
  }) {
    return AppException(
      type: ExceptionType.networkError,
      message: message ?? 'Erro de conexão com a internet',
      userMessage: userMessage ?? 'Verifique sua conexão com a internet e tente novamente',
      code: 'NETWORK_ERROR',
      originalError: originalError,
      stackTrace: stackTrace,
    );
  }

  /// Construtor para erro de timeout
  factory AppException.timeoutError({
    String? message,
    String? userMessage,
    dynamic originalError,
    StackTrace? stackTrace,
  }) {
    return AppException(
      type: ExceptionType.timeoutError,
      message: message ?? 'Tempo limite de conexão excedido',
      userMessage: userMessage ?? 'A operação demorou muito para responder. Tente novamente',
      code: 'TIMEOUT_ERROR',
      originalError: originalError,
      stackTrace: stackTrace,
    );
  }

  /// Construtor para erro de autenticação
  factory AppException.authenticationError({
    String? message,
    String? userMessage,
    dynamic originalError,
    StackTrace? stackTrace,
  }) {
    return AppException(
      type: ExceptionType.authenticationError,
      message: message ?? 'Erro de autenticação',
      userMessage: userMessage ?? 'Sessão expirada. Faça login novamente',
      code: 'AUTH_ERROR',
      originalError: originalError,
      stackTrace: stackTrace,
    );
  }

  /// Construtor para erro de autorização
  factory AppException.authorizationError({
    String? message,
    String? userMessage,
    dynamic originalError,
    StackTrace? stackTrace,
  }) {
    return AppException(
      type: ExceptionType.authorizationError,
      message: message ?? 'Acesso negado',
      userMessage: userMessage ?? 'Você não tem permissão para realizar esta ação',
      code: 'FORBIDDEN',
      originalError: originalError,
      stackTrace: stackTrace,
    );
  }

  /// Construtor para erro de dados não encontrados
  factory AppException.dataNotFound({
    String? message,
    String? userMessage,
    String? resource,
    dynamic originalError,
    StackTrace? stackTrace,
  }) {
    return AppException(
      type: ExceptionType.dataNotFound,
      message: message ?? 'Dados não encontrados',
      userMessage: userMessage ?? 'O item solicitado não foi encontrado',
      code: 'NOT_FOUND',
      originalError: originalError,
      stackTrace: stackTrace,
      additionalData: resource != null ? {'resource': resource} : null,
    );
  }

  /// Construtor para erro de validação
  factory AppException.validationError({
    String? message,
    String? userMessage,
    Map<String, String>? fieldErrors,
    dynamic originalError,
    StackTrace? stackTrace,
  }) {
    return AppException(
      type: ExceptionType.validationError,
      message: message ?? 'Erro de validação',
      userMessage: userMessage ?? 'Verifique os dados informados e tente novamente',
      code: 'VALIDATION_ERROR',
      originalError: originalError,
      stackTrace: stackTrace,
      additionalData: fieldErrors != null ? {'fieldErrors': fieldErrors} : null,
    );
  }

  /// Construtor para erro do Firebase
  factory AppException.firebaseError({
    String? message,
    String? userMessage,
    dynamic originalError,
    StackTrace? stackTrace,
  }) {
    return AppException(
      type: ExceptionType.firebaseError,
      message: message ?? 'Erro no Firebase',
      userMessage: userMessage ?? 'Erro interno do sistema. Tente novamente',
      code: 'FIREBASE_ERROR',
      originalError: originalError,
      stackTrace: stackTrace,
    );
  }

  /// Construtor para erro de estoque insuficiente
  factory AppException.insufficientStock({
    String? message,
    String? userMessage,
    String? productName,
    int? availableQuantity,
    dynamic originalError,
    StackTrace? stackTrace,
  }) {
    return AppException(
      type: ExceptionType.insufficientStock,
      message: message ?? 'Estoque insuficiente',
      userMessage: userMessage ?? 'Quantidade solicitada não disponível em estoque',
      code: 'INSUFFICIENT_STOCK',
      originalError: originalError,
      stackTrace: stackTrace,
      additionalData: {
        if (productName != null) 'productName': productName,
        if (availableQuantity != null) 'availableQuantity': availableQuantity,
      },
    );
  }

  /// Construtor para erro de pagamento
  factory AppException.paymentError({
    String? message,
    String? userMessage,
    dynamic originalError,
    StackTrace? stackTrace,
  }) {
    return AppException(
      type: ExceptionType.paymentError,
      message: message ?? 'Erro no processamento do pagamento',
      userMessage: userMessage ?? 'Erro ao processar pagamento. Verifique os dados e tente novamente',
      code: 'PAYMENT_ERROR',
      originalError: originalError,
      stackTrace: stackTrace,
    );
  }

  /// Construtor para erro desconhecido
  factory AppException.unknownError({
    String? message,
    String? userMessage,
    dynamic originalError,
    StackTrace? stackTrace,
  }) {
    return AppException(
      type: ExceptionType.unknownError,
      message: message ?? 'Erro desconhecido',
      userMessage: userMessage ?? 'Ocorreu um erro inesperado. Tente novamente',
      code: 'UNKNOWN_ERROR',
      originalError: originalError,
      stackTrace: stackTrace,
    );
  }

  /// Verifica se é um erro de rede
  bool get isNetworkError => type == ExceptionType.networkError || 
                           type == ExceptionType.timeoutError || 
                           type == ExceptionType.connectionError;

  /// Verifica se é um erro de autenticação
  bool get isAuthError => type == ExceptionType.authenticationError || 
                         type == ExceptionType.authorizationError || 
                         type == ExceptionType.sessionExpired;

  /// Verifica se é um erro que pode ser tentado novamente
  bool get isRetryable => isNetworkError || type == ExceptionType.serverError;

  /// Retorna a mensagem para o usuário
  String get displayMessage => userMessage ?? message;

  /// Retorna o ícone baseado no tipo de erro
  IconData get icon {
    switch (type) {
      case ExceptionType.networkError:
      case ExceptionType.timeoutError:
      case ExceptionType.connectionError:
        return Icons.wifi_off;
      case ExceptionType.authenticationError:
      case ExceptionType.authorizationError:
      case ExceptionType.sessionExpired:
        return Icons.lock;
      case ExceptionType.dataNotFound:
        return Icons.search_off;
      case ExceptionType.validationError:
        return Icons.error_outline;
      case ExceptionType.insufficientStock:
        return Icons.inventory_2;
      case ExceptionType.paymentError:
        return Icons.payment;
      default:
        return Icons.error;
    }
  }

  /// Retorna a cor baseada no tipo de erro
  Color get color {
    switch (type) {
      case ExceptionType.networkError:
      case ExceptionType.timeoutError:
      case ExceptionType.connectionError:
        return Colors.orange;
      case ExceptionType.authenticationError:
      case ExceptionType.authorizationError:
      case ExceptionType.sessionExpired:
        return Colors.red;
      case ExceptionType.dataNotFound:
        return Colors.grey;
      case ExceptionType.validationError:
        return Colors.amber;
      case ExceptionType.insufficientStock:
        return Colors.blue;
      case ExceptionType.paymentError:
        return Colors.red;
      default:
        return Colors.red;
    }
  }

  @override
  String toString() {
    return 'AppException{type: $type, message: $message, code: $code}';
  }

  /// Converte para Map para serialização
  Map<String, dynamic> toMap() {
    return {
      'type': type.name,
      'message': message,
      'userMessage': userMessage,
      'code': code,
      'additionalData': additionalData,
    };
  }

  /// Cria uma cópia com novos valores
  AppException copyWith({
    ExceptionType? type,
    String? message,
    String? userMessage,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
    Map<String, dynamic>? additionalData,
  }) {
    return AppException(
      type: type ?? this.type,
      message: message ?? this.message,
      userMessage: userMessage ?? this.userMessage,
      code: code ?? this.code,
      originalError: originalError ?? this.originalError,
      stackTrace: stackTrace ?? this.stackTrace,
      additionalData: additionalData ?? this.additionalData,
    );
  }
} 