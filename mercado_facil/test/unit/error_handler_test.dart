import 'dart:async';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:mercado_facil/core/error/error_handler.dart';
import 'package:mercado_facil/core/exceptions/app_exception.dart';

void main() {
  group('ErrorHandler', () {
    setUp(() {
      // Limpar callbacks antes de cada teste
      ErrorHandler.clearCallbacks();
    });

    group('Conversão de Exceções', () {
      test('deve converter SocketException para NetworkError', () {
        final exception = ErrorHandler.convertToAppException(const SocketException('Sem conexão'), null, 'teste');
        expect(exception.type, equals(ExceptionType.networkError));
        expect(exception.message, contains('Sem conexão'));
      });

      test('deve converter TimeoutException para NetworkError', () {
        final exception = ErrorHandler.convertToAppException(TimeoutException('Timeout', const Duration(seconds: 30)), null, 'teste');
        expect(exception.type, equals(ExceptionType.timeoutError));
        expect(exception.message, contains('Timeout'));
      });

      test('deve converter HttpException para NetworkError', () {
        final exception = ErrorHandler.convertToAppException(const HttpException('HTTP Error'), null, 'teste');
        expect(exception.type, equals(ExceptionType.networkError));
        expect(exception.message, contains('HTTP Error'));
      });

      test('deve converter FormatException para ValidationError', () {
        final exception = ErrorHandler.convertToAppException(const FormatException('Formato inválido'), null, 'teste');
        expect(exception.type, equals(ExceptionType.validationError));
        expect(exception.message, contains('Formato inválido'));
      });

      test('deve converter FirebaseException para FirebaseError', () {
        final exception = ErrorHandler.convertToAppException(FirebaseException(plugin: 'test', code: 'test-error'), null, 'teste');
        expect(exception.type, equals(ExceptionType.firebaseError));
        expect(exception.message, contains('test-error'));
      });

      test('deve converter PlatformException para FirebaseError', () {
        final exception = ErrorHandler.convertToAppException(PlatformException(code: 'test-error', message: 'Test error'), null, 'teste');
        expect(exception.type, equals(ExceptionType.firebaseError));
        expect(exception.message, contains('Test error'));
      });

      test('deve converter erro genérico para UnknownError', () {
        final exception = ErrorHandler.convertToAppException(Exception('Erro genérico'), null, 'teste');
        expect(exception.type, equals(ExceptionType.unknownError));
        expect(exception.message, contains('Erro genérico'));
      });
    });

    group('Títulos de Erro', () {
      test('deve retornar títulos apropriados', () {
        expect(ErrorHandler.getErrorTitle(ExceptionType.networkError), equals('Erro de Conexão'));
        expect(ErrorHandler.getErrorTitle(ExceptionType.authenticationError), equals('Erro de Autenticação'));
        expect(ErrorHandler.getErrorTitle(ExceptionType.dataNotFound), equals('Item Não Encontrado'));
        expect(ErrorHandler.getErrorTitle(ExceptionType.validationError), equals('Dados Inválidos'));
        expect(ErrorHandler.getErrorTitle(ExceptionType.insufficientStock), equals('Estoque Insuficiente'));
        expect(ErrorHandler.getErrorTitle(ExceptionType.paymentError), equals('Erro no Pagamento'));
        expect(ErrorHandler.getErrorTitle(ExceptionType.firebaseError), equals('Erro do Sistema'));
        expect(ErrorHandler.getErrorTitle(ExceptionType.unknownError), equals('Erro'));
      });
    });

    group('Retry Mechanism', () {
      test('deve executar operação com sucesso na primeira tentativa', () async {
        int attempts = 0;
        final result = await ErrorHandler.executeWithRetry(
          operation: () async {
            attempts++;
            return 'sucesso';
          },
          operationName: 'teste',
          maxRetries: 3,
          showLoading: false,
        );

        expect(result, equals('sucesso'));
        expect(attempts, equals(1));
      });

      test('deve tentar novamente após falha', () async {
        int attempts = 0;
        final result = await ErrorHandler.executeWithRetry(
          operation: () async {
            attempts++;
            if (attempts < 3) {
              throw Exception('Erro temporário');
            }
            return 'sucesso';
          },
          operationName: 'teste',
          maxRetries: 3,
          showLoading: false,
        );

        expect(result, equals('sucesso'));
        expect(attempts, equals(3));
      });

      test('deve falhar após todas as tentativas', () async {
        int attempts = 0;
        
        expect(
          () => ErrorHandler.executeWithRetry(
            operation: () async {
              attempts++;
              throw Exception('Erro persistente');
            },
            operationName: 'teste',
            maxRetries: 2,
            showLoading: false,
          ),
          throwsA(isA<AppException>()),
        );

        expect(attempts, equals(2));
      });

      test('deve usar delay progressivo', () async {
        int attempts = 0;
        final stopwatch = Stopwatch()..start();
        
        await ErrorHandler.executeWithRetry(
          operation: () async {
            attempts++;
            if (attempts < 3) {
              throw Exception('Erro temporário');
            }
            return 'sucesso';
          },
          operationName: 'teste',
          maxRetries: 3,
          delay: Duration(milliseconds: 100),
          showLoading: false,
        );

        stopwatch.stop();
        
        // Deve ter pelo menos 300ms de delay (100 + 200)
        expect(stopwatch.elapsedMilliseconds, greaterThan(300));
        expect(attempts, equals(3));
      });
    });

    group('Fallback Operations', () {
      test('deve executar operação primária com sucesso', () async {
        int primaryAttempts = 0;
        int fallbackAttempts = 0;
        
        final result = await ErrorHandler.executeWithFallback(
          primaryOperation: () async {
            primaryAttempts++;
            return 'primário';
          },
          fallbackOperation: () async {
            fallbackAttempts++;
            return 'fallback';
          },
          operationName: 'teste',
        );

        expect(result, equals('primário'));
        expect(primaryAttempts, equals(1));
        expect(fallbackAttempts, equals(0));
      });

      test('deve executar fallback quando primário falha', () async {
        int primaryAttempts = 0;
        int fallbackAttempts = 0;
        
        final result = await ErrorHandler.executeWithFallback(
          primaryOperation: () async {
            primaryAttempts++;
            throw Exception('Erro primário');
          },
          fallbackOperation: () async {
            fallbackAttempts++;
            return 'fallback';
          },
          operationName: 'teste',
        );

        expect(result, equals('fallback'));
        expect(primaryAttempts, equals(1));
        expect(fallbackAttempts, equals(1));
      });

      test('deve falhar quando ambos falham', () async {
        int primaryAttempts = 0;
        int fallbackAttempts = 0;
        
        expect(
          () => ErrorHandler.executeWithFallback(
            primaryOperation: () async {
              primaryAttempts++;
              throw Exception('Erro primário');
            },
            fallbackOperation: () async {
              fallbackAttempts++;
              throw Exception('Erro fallback');
            },
            operationName: 'teste',
          ),
          throwsA(isA<Exception>()),
        );

        expect(primaryAttempts, equals(1));
        expect(fallbackAttempts, equals(1));
      });
    });

    group('Configuração', () {
      test('deve configurar callbacks corretamente', () {
        bool showErrorCalled = false;
        bool showLoadingCalled = false;
        bool navigateCalled = false;

        ErrorHandler.configure(
          showError: (message, {title, icon, color}) {
            showErrorCalled = true;
          },
          showLoading: (show) {
            showLoadingCalled = true;
          },
          navigate: (route, {arguments}) {
            navigateCalled = true;
          },
        );

        // Simular chamadas
        ErrorHandler.showErrorCallback?.call('teste');
        ErrorHandler.showLoadingCallback?.call(true);
        ErrorHandler.navigateCallback?.call('/teste');

        expect(showErrorCalled, isTrue);
        expect(showLoadingCalled, isTrue);
        expect(navigateCalled, isTrue);
      });

      test('deve limpar callbacks', () {
        ErrorHandler.configure(
          showError: (message, {title, icon, color}) {},
          showLoading: (show) {},
          navigate: (route, {arguments}) {},
        );

        ErrorHandler.clearCallbacks();

        expect(ErrorHandler.showErrorCallback, isNull);
        expect(ErrorHandler.showLoadingCallback, isNull);
        expect(ErrorHandler.navigateCallback, isNull);
      });
    });
  });
}