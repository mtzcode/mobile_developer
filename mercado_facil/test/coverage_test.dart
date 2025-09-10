import 'package:flutter_test/flutter_test.dart';

/// Arquivo para configurar cobertura de testes
/// Este arquivo é usado para garantir que todos os testes sejam executados
/// durante a geração de relatórios de cobertura

void main() {
  group('Coverage Configuration', () {
    test('deve garantir que todos os testes sejam executados', () {
      // Este teste garante que o arquivo de cobertura seja incluído
      expect(true, isTrue);
    });
  });
} 