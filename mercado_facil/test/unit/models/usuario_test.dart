import 'package:flutter_test/flutter_test.dart';
import 'package:mercado_facil/data/models/usuario.dart';

void main() {
  group('Usuario Model Tests', () {
    late Usuario usuario;
    late DateTime dataCadastro;

    setUp(() {
      dataCadastro = DateTime(2024, 1, 1, 12, 0, 0);
      usuario = Usuario(
        id: 'user_123',
        nome: 'João Silva',
        email: 'joao@example.com',
        whatsapp: '11999999999',
        senhaHash: 'hash_da_senha',
        endereco: {
          'rua': 'Rua das Flores',
          'numero': '123',
          'bairro': 'Centro',
          'cidade': 'São Paulo',
          'estado': 'SP',
          'cep': '01234567',
        },
        enderecos: [
          {
            'rua': 'Rua das Flores',
            'numero': '123',
            'bairro': 'Centro',
            'cidade': 'São Paulo',
            'estado': 'SP',
            'cep': '01234567',
          },
          {
            'rua': 'Rua do Comércio',
            'numero': '456',
            'bairro': 'Vila Nova',
            'cidade': 'São Paulo',
            'estado': 'SP',
            'cep': '01234568',
          },
        ],
        fotoUrl: 'https://example.com/foto.jpg',
        dataCadastro: dataCadastro,
        ativo: true,
        cadastroCompleto: true,
      );
    });

    group('Constructor', () {
      test('deve criar usuário com todos os campos obrigatórios', () {
        final usuario = Usuario(
          id: 'user_123',
          nome: 'João Silva',
          email: 'joao@example.com',
          whatsapp: '11999999999',
          senhaHash: 'hash_da_senha',
          dataCadastro: dataCadastro,
        );

        expect(usuario.id, equals('user_123'));
        expect(usuario.nome, equals('João Silva'));
        expect(usuario.email, equals('joao@example.com'));
        expect(usuario.whatsapp, equals('11999999999'));
        expect(usuario.senhaHash, equals('hash_da_senha'));
        expect(usuario.dataCadastro, equals(dataCadastro));
        expect(usuario.endereco, isNull);
        expect(usuario.enderecos, isNull);
        expect(usuario.fotoUrl, isNull);
        expect(usuario.ativo, isTrue);
        expect(usuario.cadastroCompleto, isFalse);
      });

      test('deve criar usuário com todos os campos opcionais', () {
        final usuario = Usuario(
          id: 'user_123',
          nome: 'João Silva',
          email: 'joao@example.com',
          whatsapp: '11999999999',
          senhaHash: 'hash_da_senha',
          endereco: {'rua': 'Rua das Flores'},
          enderecos: [{'rua': 'Rua das Flores'}],
          fotoUrl: 'https://example.com/foto.jpg',
          dataCadastro: dataCadastro,
          ativo: false,
          cadastroCompleto: true,
        );

        expect(usuario.endereco, equals({'rua': 'Rua das Flores'}));
        expect(usuario.enderecos, equals([{'rua': 'Rua das Flores'}]));
        expect(usuario.fotoUrl, equals('https://example.com/foto.jpg'));
        expect(usuario.ativo, isFalse);
        expect(usuario.cadastroCompleto, isTrue);
      });

      test('deve definir valores padrão para ativo e cadastroCompleto', () {
        final usuario = Usuario(
          id: 'user_123',
          nome: 'João Silva',
          email: 'joao@example.com',
          whatsapp: '11999999999',
          senhaHash: 'hash_da_senha',
          dataCadastro: dataCadastro,
        );

        expect(usuario.ativo, isTrue);
        expect(usuario.cadastroCompleto, isFalse);
      });
    });

    group('toMap', () {
      test('deve converter usuário para Map com todos os campos', () {
        final map = usuario.toMap();

        expect(map['nome'], equals('João Silva'));
        expect(map['email'], equals('joao@example.com'));
        expect(map['whatsapp'], equals('11999999999'));
        expect(map['senhaHash'], equals('hash_da_senha'));
        expect(map['endereco'], equals({
          'rua': 'Rua das Flores',
          'numero': '123',
          'bairro': 'Centro',
          'cidade': 'São Paulo',
          'estado': 'SP',
          'cep': '01234567',
        }));
        expect(map['enderecos'], equals([
          {
            'rua': 'Rua das Flores',
            'numero': '123',
            'bairro': 'Centro',
            'cidade': 'São Paulo',
            'estado': 'SP',
            'cep': '01234567',
          },
          {
            'rua': 'Rua do Comércio',
            'numero': '456',
            'bairro': 'Vila Nova',
            'cidade': 'São Paulo',
            'estado': 'SP',
            'cep': '01234568',
          },
        ]));
        expect(map['fotoUrl'], equals('https://example.com/foto.jpg'));
        expect(map['dataCadastro'], equals(dataCadastro.toIso8601String()));
        expect(map['ativo'], isTrue);
        expect(map['cadastroCompleto'], isTrue);
      });

      test('deve converter usuário sem campos opcionais', () {
        final usuarioSimples = Usuario(
          id: 'user_123',
          nome: 'João Silva',
          email: 'joao@example.com',
          whatsapp: '11999999999',
          senhaHash: 'hash_da_senha',
          dataCadastro: dataCadastro,
        );

        final map = usuarioSimples.toMap();

        expect(map['nome'], equals('João Silva'));
        expect(map['email'], equals('joao@example.com'));
        expect(map['whatsapp'], equals('11999999999'));
        expect(map['senhaHash'], equals('hash_da_senha'));
        expect(map['dataCadastro'], equals(dataCadastro.toIso8601String()));
        expect(map['ativo'], isTrue);
        expect(map['cadastroCompleto'], isFalse);
        expect(map['endereco'], isNull);
        expect(map['enderecos'], isNull);
        expect(map['fotoUrl'], isNull);
      });
    });

    group('fromMap', () {
      test('deve criar usuário a partir de Map completo', () {
        final map = {
          'nome': 'João Silva',
          'email': 'joao@example.com',
          'whatsapp': '11999999999',
          'senhaHash': 'hash_da_senha',
          'endereco': {
            'rua': 'Rua das Flores',
            'numero': '123',
          },
          'enderecos': [
            {
              'rua': 'Rua das Flores',
              'numero': '123',
            },
          ],
          'fotoUrl': 'https://example.com/foto.jpg',
          'dataCadastro': dataCadastro.toIso8601String(),
          'ativo': false,
          'cadastroCompleto': true,
        };

        final usuario = Usuario.fromMap('user_123', map);

        expect(usuario.id, equals('user_123'));
        expect(usuario.nome, equals('João Silva'));
        expect(usuario.email, equals('joao@example.com'));
        expect(usuario.whatsapp, equals('11999999999'));
        expect(usuario.senhaHash, equals('hash_da_senha'));
        expect(usuario.endereco, equals({
          'rua': 'Rua das Flores',
          'numero': '123',
        }));
        expect(usuario.enderecos, equals([
          {
            'rua': 'Rua das Flores',
            'numero': '123',
          },
        ]));
        expect(usuario.fotoUrl, equals('https://example.com/foto.jpg'));
        expect(usuario.dataCadastro, equals(dataCadastro));
        expect(usuario.ativo, isFalse);
        expect(usuario.cadastroCompleto, isTrue);
      });

      test('deve criar usuário a partir de Map com campos ausentes', () {
        final map = {
          'nome': 'João Silva',
          'email': 'joao@example.com',
          'whatsapp': '11999999999',
          'senhaHash': 'hash_da_senha',
        };

        final usuario = Usuario.fromMap('user_123', map);

        expect(usuario.id, equals('user_123'));
        expect(usuario.nome, equals('João Silva'));
        expect(usuario.email, equals('joao@example.com'));
        expect(usuario.whatsapp, equals('11999999999'));
        expect(usuario.senhaHash, equals('hash_da_senha'));
        expect(usuario.endereco, isNull);
        expect(usuario.enderecos, isNull);
        expect(usuario.fotoUrl, isNull);
        expect(usuario.ativo, isTrue);
        expect(usuario.cadastroCompleto, isFalse);
      });

      test('deve lidar com valores nulos no Map', () {
        final map = {
          'nome': 'João Silva',
          'email': 'joao@example.com',
          'whatsapp': '11999999999',
          'senhaHash': 'hash_da_senha',
          'endereco': null,
          'enderecos': null,
          'fotoUrl': null,
          'ativo': null,
          'cadastroCompleto': null,
        };

        final usuario = Usuario.fromMap('user_123', map);

        expect(usuario.endereco, isNull);
        expect(usuario.enderecos, isNull);
        expect(usuario.fotoUrl, isNull);
        expect(usuario.ativo, isTrue);
        expect(usuario.cadastroCompleto, isFalse);
      });

      test('deve usar valores padrão para campos ausentes', () {
        final map = <String, dynamic>{};

        final usuario = Usuario.fromMap('user_123', map);

        expect(usuario.id, equals('user_123'));
        expect(usuario.nome, equals(''));
        expect(usuario.email, equals(''));
        expect(usuario.whatsapp, equals(''));
        expect(usuario.senhaHash, equals(''));
        expect(usuario.endereco, isNull);
        expect(usuario.enderecos, isNull);
        expect(usuario.fotoUrl, isNull);
        expect(usuario.ativo, isTrue);
        expect(usuario.cadastroCompleto, isFalse);
      });

      test('deve converter enderecos de List para List<Map<String, dynamic>>', () {
        final map = {
          'nome': 'João Silva',
          'email': 'joao@example.com',
          'whatsapp': '11999999999',
          'senhaHash': 'hash_da_senha',
          'enderecos': [
            {'rua': 'Rua A'},
            {'rua': 'Rua B'},
          ],
        };

        final usuario = Usuario.fromMap('user_123', map);

        expect(usuario.enderecos, isA<List<Map<String, dynamic>>>());
        expect(usuario.enderecos!.length, equals(2));
        expect(usuario.enderecos![0]['rua'], equals('Rua A'));
        expect(usuario.enderecos![1]['rua'], equals('Rua B'));
      });
    });

    group('copyWith', () {
      test('deve criar cópia idêntica quando nenhum parâmetro é fornecido', () {
        final copia = usuario.copyWith();

        expect(copia.id, equals(usuario.id));
        expect(copia.nome, equals(usuario.nome));
        expect(copia.email, equals(usuario.email));
        expect(copia.whatsapp, equals(usuario.whatsapp));
        expect(copia.senhaHash, equals(usuario.senhaHash));
        expect(copia.endereco, equals(usuario.endereco));
        expect(copia.enderecos, equals(usuario.enderecos));
        expect(copia.fotoUrl, equals(usuario.fotoUrl));
        expect(copia.dataCadastro, equals(usuario.dataCadastro));
        expect(copia.ativo, equals(usuario.ativo));
        expect(copia.cadastroCompleto, equals(usuario.cadastroCompleto));
      });

      test('deve modificar apenas os campos especificados', () {
        final copia = usuario.copyWith(
          nome: 'Maria Silva',
          email: 'maria@example.com',
          ativo: false,
        );

        expect(copia.id, equals(usuario.id));
        expect(copia.nome, equals('Maria Silva'));
        expect(copia.email, equals('maria@example.com'));
        expect(copia.whatsapp, equals(usuario.whatsapp));
        expect(copia.senhaHash, equals(usuario.senhaHash));
        expect(copia.endereco, equals(usuario.endereco));
        expect(copia.enderecos, equals(usuario.enderecos));
        expect(copia.fotoUrl, equals(usuario.fotoUrl));
        expect(copia.dataCadastro, equals(usuario.dataCadastro));
        expect(copia.ativo, isFalse);
        expect(copia.cadastroCompleto, equals(usuario.cadastroCompleto));
      });

      test('deve permitir definir campos como null', () {
        final copia = usuario.copyWith(
          endereco: null,
          enderecos: null,
          fotoUrl: null,
        );

        expect(copia.endereco, isNull);
        expect(copia.enderecos, isNull);
        expect(copia.fotoUrl, isNull);
      });
    });
  });
} 