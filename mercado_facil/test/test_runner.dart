import 'package:flutter_test/flutter_test.dart';

// Importar todos os testes unitários
import 'unit/validators_test.dart' as validators_test;
import 'unit/app_exception_test.dart' as app_exception_test;
import 'unit/error_handler_test.dart' as error_handler_test;

void main() {
  group('🧪 Testes Unitários - Mercado Fácil', () {
    group('Validators', () {
      validators_test.main();
    });

    group('AppException', () {
      app_exception_test.main();
    });

    group('ErrorHandler', () {
      error_handler_test.main();
    });
  });
} 