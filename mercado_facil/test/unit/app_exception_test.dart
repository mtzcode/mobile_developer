import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mercado_facil/core/exceptions/app_exception.dart';

void main() {
  group('AppException', () {
    group('Construtores Factory', () {
      test('networkError deve criar exceção de rede', () {
        final exception = AppException.networkError(
          message: 'Erro de conexão',
          userMessage: 'Verifique sua internet',
        );

        expect(exception.type, equals(ExceptionType.networkError));
        expect(exception.message, equals('Erro de conexão'));
        expect(exception.userMessage, equals('Verifique sua internet'));
        expect(exception.code, equals('NETWORK_ERROR'));
        expect(exception.isNetworkError, isTrue);
        expect(exception.isRetryable, isTrue);
      });

      test('timeoutError deve criar exceção de timeout', () {
        final exception = AppException.timeoutError(
          message: 'Timeout na operação',
          userMessage: 'Tente novamente',
        );

        expect(exception.type, equals(ExceptionType.timeoutError));
        expect(exception.message, equals('Timeout na operação'));
        expect(exception.userMessage, equals('Tente novamente'));
        expect(exception.code, equals('TIMEOUT_ERROR'));
        expect(exception.isNetworkError, isTrue);
        expect(exception.isRetryable, isTrue);
      });

      test('authenticationError deve criar exceção de autenticação', () {
        final exception = AppException.authenticationError(
          message: 'Erro de login',
          userMessage: 'Faça login novamente',
        );

        expect(exception.type, equals(ExceptionType.authenticationError));
        expect(exception.message, equals('Erro de login'));
        expect(exception.userMessage, equals('Faça login novamente'));
        expect(exception.code, equals('AUTH_ERROR'));
        expect(exception.isAuthError, isTrue);
        expect(exception.isRetryable, isFalse);
      });

      test('validationError deve criar exceção de validação', () {
        final fieldErrors = {'email': 'Email inválido'};
        final exception = AppException.validationError(
          message: 'Dados inválidos',
          userMessage: 'Corrija os campos',
          fieldErrors: fieldErrors,
        );

        expect(exception.type, equals(ExceptionType.validationError));
        expect(exception.message, equals('Dados inválidos'));
        expect(exception.userMessage, equals('Corrija os campos'));
        expect(exception.code, equals('VALIDATION_ERROR'));
        expect(exception.additionalData?['fieldErrors'], equals(fieldErrors));
        expect(exception.isRetryable, isFalse);
      });

      test('dataNotFound deve criar exceção de dados não encontrados', () {
        final exception = AppException.dataNotFound(
          message: 'Produto não encontrado',
          userMessage: 'Produto indisponível',
          resource: 'produto',
        );

        expect(exception.type, equals(ExceptionType.dataNotFound));
        expect(exception.message, equals('Produto não encontrado'));
        expect(exception.userMessage, equals('Produto indisponível'));
        expect(exception.code, equals('NOT_FOUND'));
        expect(exception.additionalData?['resource'], equals('produto'));
        expect(exception.isRetryable, isFalse);
      });

      test('insufficientStock deve criar exceção de estoque', () {
        final exception = AppException.insufficientStock(
          message: 'Estoque insuficiente',
          userMessage: 'Quantidade não disponível',
          productName: 'Arroz',
          availableQuantity: 5,
        );

        expect(exception.type, equals(ExceptionType.insufficientStock));
        expect(exception.message, equals('Estoque insuficiente'));
        expect(exception.userMessage, equals('Quantidade não disponível'));
        expect(exception.code, equals('INSUFFICIENT_STOCK'));
        expect(exception.additionalData?['productName'], equals('Arroz'));
        expect(exception.additionalData?['availableQuantity'], equals(5));
        expect(exception.isRetryable, isFalse);
      });

      test('paymentError deve criar exceção de pagamento', () {
        final exception = AppException.paymentError(
          message: 'Erro no pagamento',
          userMessage: 'Tente outro método',
        );

        expect(exception.type, equals(ExceptionType.paymentError));
        expect(exception.message, equals('Erro no pagamento'));
        expect(exception.userMessage, equals('Tente outro método'));
        expect(exception.code, equals('PAYMENT_ERROR'));
        expect(exception.isRetryable, isFalse);
      });

      test('unknownError deve criar exceção desconhecida', () {
        final exception = AppException.unknownError(
          message: 'Erro desconhecido',
          userMessage: 'Tente novamente',
        );

        expect(exception.type, equals(ExceptionType.unknownError));
        expect(exception.message, equals('Erro desconhecido'));
        expect(exception.userMessage, equals('Tente novamente'));
        expect(exception.code, equals('UNKNOWN_ERROR'));
        expect(exception.isRetryable, isFalse);
      });
    });

    group('Propriedades', () {
      test('displayMessage deve retornar userMessage ou message', () {
        final exception1 = AppException.networkError(
          message: 'Erro técnico',
          userMessage: 'Mensagem para usuário',
        );
        expect(exception1.displayMessage, equals('Mensagem para usuário'));

        final exception2 = AppException.networkError(
          message: 'Erro técnico',
        );
        expect(exception2.displayMessage, equals('Erro técnico'));
      });

      test('isNetworkError deve identificar erros de rede', () {
        expect(AppException.networkError().isNetworkError, isTrue);
        expect(AppException.timeoutError().isNetworkError, isTrue);
        expect(AppException.connectionError().isNetworkError, isTrue);
        expect(AppException.authenticationError().isNetworkError, isFalse);
      });

      test('isAuthError deve identificar erros de autenticação', () {
        expect(AppException.authenticationError().isAuthError, isTrue);
        expect(AppException.authorizationError().isAuthError, isTrue);
        expect(AppException.sessionExpired().isAuthError, isTrue);
        expect(AppException.networkError().isAuthError, isFalse);
      });

      test('isRetryable deve identificar erros que podem ser tentados novamente', () {
        expect(AppException.networkError().isRetryable, isTrue);
        expect(AppException.timeoutError().isRetryable, isTrue);
        expect(AppException.serverError().isRetryable, isTrue);
        expect(AppException.validationError().isRetryable, isFalse);
        expect(AppException.authenticationError().isRetryable, isFalse);
      });
    });

    group('Ícones e Cores', () {
      test('deve retornar ícones apropriados para cada tipo', () {
        expect(AppException.networkError().icon, equals(Icons.wifi_off));
        expect(AppException.authenticationError().icon, equals(Icons.lock));
        expect(AppException.dataNotFound().icon, equals(Icons.search_off));
        expect(AppException.validationError().icon, equals(Icons.error_outline));
        expect(AppException.insufficientStock().icon, equals(Icons.inventory_2));
        expect(AppException.paymentError().icon, equals(Icons.payment));
        expect(AppException.unknownError().icon, equals(Icons.error));
      });

      test('deve retornar cores apropriadas para cada tipo', () {
        expect(AppException.networkError().color, equals(Colors.orange));
        expect(AppException.authenticationError().color, equals(Colors.red));
        expect(AppException.dataNotFound().color, equals(Colors.grey));
        expect(AppException.validationError().color, equals(Colors.amber));
        expect(AppException.insufficientStock().color, equals(Colors.blue));
        expect(AppException.paymentError().color, equals(Colors.red));
        expect(AppException.unknownError().color, equals(Colors.red));
      });
    });

    group('Métodos', () {
      test('toString deve retornar representação string', () {
        final exception = AppException.networkError(
          message: 'Erro de conexão',
          code: 'NETWORK_ERROR',
        );

        expect(exception.toString(), contains('AppException'));
        expect(exception.toString(), contains('networkError'));
        expect(exception.toString(), contains('Erro de conexão'));
        expect(exception.toString(), contains('NETWORK_ERROR'));
      });

      test('toMap deve converter para Map', () {
        final exception = AppException.validationError(
          message: 'Dados inválidos',
          userMessage: 'Corrija os campos',
          fieldErrors: {'email': 'Email inválido'},
        );

        final map = exception.toMap();
        expect(map['type'], equals('validationError'));
        expect(map['message'], equals('Dados inválidos'));
        expect(map['userMessage'], equals('Corrija os campos'));
        expect(map['code'], equals('VALIDATION_ERROR'));
        expect(map['additionalData']['fieldErrors']['email'], equals('Email inválido'));
      });

      test('copyWith deve criar cópia modificada', () {
        final original = AppException.networkError(
          message: 'Erro original',
          userMessage: 'Mensagem original',
        );

        final modified = original.copyWith(
          message: 'Erro modificado',
          userMessage: 'Mensagem modificada',
        );

        expect(modified.type, equals(original.type));
        expect(modified.message, equals('Erro modificado'));
        expect(modified.userMessage, equals('Mensagem modificada'));
        expect(modified.code, equals(original.code));
      });
    });
  });
} 