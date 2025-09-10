import 'package:flutter_test/flutter_test.dart';

// Testes para validações de autenticação
void main() {
  group('🔐 Testes de Validação de Autenticação', () {
    
    // Regex para validação de email
    final RegExp emailRegex = RegExp(
      r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
    );

    group('📧 Validação de Email', () {
      test('Email válido deve passar na validação', () {
        expect(emailRegex.hasMatch('teste@email.com'), true);
        expect(emailRegex.hasMatch('usuario123@gmail.com'), true);
        expect(emailRegex.hasMatch('nome.sobrenome@empresa.com.br'), true);
      });

      test('Email inválido deve falhar na validação', () {
        expect(emailRegex.hasMatch('teste'), false);
        expect(emailRegex.hasMatch('teste@'), false);
        expect(emailRegex.hasMatch('@email.com'), false);
        expect(emailRegex.hasMatch('teste.email'), false);
        expect(emailRegex.hasMatch(''), false);
      });
    });

    group('👤 Validação de Nome', () {
      test('Nome completo deve ser válido', () {
        expect(_validarNome('João Silva'), true);
        expect(_validarNome('Maria Santos Costa'), true);
        expect(_validarNome('José da Silva'), true);
      });

      test('Nome incompleto deve ser inválido', () {
        expect(_validarNome('João'), false);
        expect(_validarNome(''), false);
        expect(_validarNome('A'), false);
      });

      test('Nome muito curto deve ser inválido', () {
        expect(_validarNome('Jo'), false);
        expect(_validarNome('A B'), false);
      });
    });

    group('📱 Validação de WhatsApp', () {
      test('WhatsApp válido deve passar na validação', () {
        expect(_validarWhatsApp('11999999999'), true);
        expect(_validarWhatsApp('(11) 99999-9999'), true);
        expect(_validarWhatsApp('11 99999 9999'), true);
      });

      test('WhatsApp inválido deve falhar na validação', () {
        expect(_validarWhatsApp('1199999999'), false); // Menos de 10 dígitos
        expect(_validarWhatsApp(''), false);
        expect(_validarWhatsApp('abc'), false);
      });
    });

    group('🔒 Validação de Senha', () {
      test('Senha forte deve passar na validação', () {
        expect(_validarForcaSenha('Senha123!'), true);
        expect(_validarForcaSenha('MinhaSenha@2024'), true);
        expect(_validarForcaSenha('Abc123!@#'), true);
      });

      test('Senha fraca deve falhar na validação', () {
        expect(_validarForcaSenha('senha'), false); // Muito curta
        expect(_validarForcaSenha('senha123'), false); // Sem maiúscula
        expect(_validarForcaSenha('SENHA123'), false); // Sem minúscula
        expect(_validarForcaSenha('Senha'), false); // Sem número
        expect(_validarForcaSenha(''), false);
      });

      test('Senha deve ter pelo menos 8 caracteres', () {
        expect(_validarForcaSenha('Senh1!'), false); // 6 caracteres
        expect(_validarForcaSenha('Senha12'), false); // 7 caracteres
        expect(_validarForcaSenha('Senha123'), true); // 8 caracteres
      });
    });

    group('🔄 Formatação de WhatsApp', () {
      test('Formatação automática deve funcionar', () {
        expect(_formatarWhatsApp('11999999999'), '(11) 99999-9999');
        expect(_formatarWhatsApp('1199999999'), '(11) 99999-9999');
        expect(_formatarWhatsApp('11'), '11');
        expect(_formatarWhatsApp('119999'), '(11) 9999');
      });
    });
  });
}

// Funções auxiliares para testes
bool _validarNome(String nome) {
  if (nome.trim().isEmpty) return false;
  if (nome.trim().split(' ').length < 2) return false;
  if (nome.trim().length < 3) return false;
  return true;
}

bool _validarWhatsApp(String whatsapp) {
  String numeros = whatsapp.replaceAll(RegExp(r'[^\d]'), '');
  return numeros.length >= 10;
}

bool _validarForcaSenha(String senha) {
  if (senha.isEmpty || senha.length < 8) return false;
  
  bool temMaiuscula = senha.contains(RegExp(r'[A-Z]'));
  bool temMinuscula = senha.contains(RegExp(r'[a-z]'));
  bool temNumero = senha.contains(RegExp(r'[0-9]'));
  bool temCaractereEspecial = senha.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
  
  int forca = 0;
  if (temMaiuscula) forca++;
  if (temMinuscula) forca++;
  if (temNumero) forca++;
  if (temCaractereEspecial) forca++;
  
  return forca >= 3;
}

String _formatarWhatsApp(String value) {
  String numeros = value.replaceAll(RegExp(r'[^\d]'), '');
  
  if (numeros.length <= 2) {
    return numeros;
  } else if (numeros.length <= 6) {
    return '(${numeros.substring(0, 2)}) ${numeros.substring(2)}';
  } else if (numeros.length <= 10) {
    return '(${numeros.substring(0, 2)}) ${numeros.substring(2, 6)}-${numeros.substring(6)}';
  } else {
    return '(${numeros.substring(0, 2)}) ${numeros.substring(2, 7)}-${numeros.substring(7, 11)}';
  }
} 