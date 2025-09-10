import 'package:flutter_test/flutter_test.dart';
import 'package:mercado_facil/core/utils/validators.dart';

void main() {
  group('Validators', () {
    group('email', () {
      test('deve retornar null para email válido', () {
        expect(Validators.email('teste@email.com'), isNull);
        expect(Validators.email('usuario123@dominio.com.br'), isNull);
        expect(Validators.email('teste+tag@email.org'), isNull);
      });

      test('deve retornar mensagem de erro para email vazio', () {
        expect(Validators.email(''), equals('E-mail obrigatório'));
        expect(Validators.email('   '), equals('E-mail obrigatório'));
        expect(Validators.email(null), equals('E-mail obrigatório'));
      });

      test('deve retornar mensagem de erro para email inválido', () {
        expect(Validators.email('email_invalido'), equals('E-mail inválido'));
        expect(Validators.email('email@'), equals('E-mail inválido'));
        expect(Validators.email('@dominio.com'), equals('E-mail inválido'));
        expect(Validators.email('email@dominio'), equals('E-mail inválido'));
        expect(Validators.email('email..teste@dominio.com'), equals('E-mail inválido'));
      });
    });

    group('senha', () {
      test('deve retornar null para senha forte', () {
        expect(Validators.senha('Senha123!@'), isNull);
        expect(Validators.senha('MinhaSenha@2024'), isNull);
        expect(Validators.senha('Abc123#@'), isNull);
      });

      test('deve retornar mensagem de erro para senha vazia', () {
        expect(Validators.senha(''), equals('Senha obrigatória'));
        expect(Validators.senha(null), equals('Senha obrigatória'));
      });

      test('deve retornar erro para senha muito curta', () {
        expect(Validators.senha('123'), equals('A senha deve ter pelo menos 8 caracteres'));
        expect(Validators.senha('abc'), equals('A senha deve ter pelo menos 8 caracteres'));
      });

      test('deve retornar erro para senha sem letra maiúscula', () {
        expect(Validators.senha('senha123!'), equals('A senha deve conter pelo menos uma letra maiúscula'));
      });

      test('deve retornar erro para senha sem letra minúscula', () {
        expect(Validators.senha('SENHA123!'), equals('A senha deve conter pelo menos uma letra minúscula'));
      });

      test('deve retornar erro para senha sem número', () {
        expect(Validators.senha('SenhaTeste!'), equals('A senha deve conter pelo menos um número'));
      });

      test('deve retornar erro para senha sem caractere especial', () {
        expect(Validators.senha('Senha123'), equals('A senha deve conter pelo menos um caractere especial'));
      });
    });

    group('cpf', () {
      test('deve retornar null para CPF válido', () {
        expect(Validators.cpf('123.456.789-09'), isNull);
        expect(Validators.cpf('12345678909'), isNull);
        expect(Validators.cpf('111.444.777-35'), isNull);
      });

      test('deve retornar mensagem de erro para CPF vazio', () {
        expect(Validators.cpf(''), equals('CPF obrigatório'));
        expect(Validators.cpf('   '), equals('CPF obrigatório'));
        expect(Validators.cpf(null), equals('CPF obrigatório'));
      });

      test('deve retornar erro para CPF com tamanho incorreto', () {
        expect(Validators.cpf('123'), equals('CPF deve ter 11 dígitos'));
        expect(Validators.cpf('123456789012'), equals('CPF deve ter 11 dígitos'));
      });

      test('deve retornar erro para CPF com dígitos iguais', () {
        expect(Validators.cpf('11111111111'), equals('CPF inválido'));
        expect(Validators.cpf('00000000000'), equals('CPF inválido'));
      });

      test('deve retornar erro para CPF inválido', () {
        expect(Validators.cpf('12345678901'), equals('CPF inválido'));
        expect(Validators.cpf('11111111112'), equals('CPF inválido'));
      });
    });

    group('telefone', () {
      test('deve retornar null para telefone válido', () {
        expect(Validators.telefone('(11) 99999-9999'), isNull);
        expect(Validators.telefone('11999999999'), isNull);
        expect(Validators.telefone('(21) 3333-3333'), isNull);
        expect(Validators.telefone('2133333333'), isNull);
      });

      test('deve retornar mensagem de erro para telefone vazio', () {
        expect(Validators.telefone(''), equals('Telefone obrigatório'));
        expect(Validators.telefone('   '), equals('Telefone obrigatório'));
        expect(Validators.telefone(null), equals('Telefone obrigatório'));
      });

      test('deve retornar erro para telefone com tamanho incorreto', () {
        expect(Validators.telefone('123'), equals('Telefone deve ter 10 ou 11 dígitos'));
        expect(Validators.telefone('123456789012'), equals('Telefone deve ter 10 ou 11 dígitos'));
      });

      test('deve retornar erro para telefone inválido', () {
        expect(Validators.telefone('00123456789'), equals('Telefone inválido'));
        expect(Validators.telefone('0000000000'), equals('Telefone inválido'));
      });
    });

    group('cep', () {
      test('deve retornar null para CEP válido', () {
        expect(Validators.cep('12345-678'), isNull);
        expect(Validators.cep('12345678'), isNull);
        expect(Validators.cep('00000-000'), isNull);
      });

      test('deve retornar mensagem de erro para CEP vazio', () {
        expect(Validators.cep(''), equals('CEP obrigatório'));
        expect(Validators.cep('   '), equals('CEP obrigatório'));
        expect(Validators.cep(null), equals('CEP obrigatório'));
      });

      test('deve retornar erro para CEP com tamanho incorreto', () {
        expect(Validators.cep('123'), equals('CEP deve ter 8 dígitos'));
        expect(Validators.cep('123456789'), equals('CEP deve ter 8 dígitos'));
      });

      test('deve retornar erro para CEP inválido', () {
        expect(Validators.cep('abcdefgh'), equals('CEP deve ter 8 dígitos'));
        expect(Validators.cep('12-34-56'), equals('CEP deve ter 8 dígitos'));
      });
    });
  });
} 