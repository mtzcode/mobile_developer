import 'package:flutter_test/flutter_test.dart';
import 'package:mercado_facil/data/models/produto.dart';

void main() {
  group('Produto Model Tests', () {
    late Produto produto;

    setUp(() {
      produto = Produto(
        id: 'test_123',
        nome: 'Arroz Integral',
        preco: 6.99,
        imagemUrl: 'https://example.com/arroz.jpg',
        descricao: 'Arroz integral orgânico',
        categoria: 'Cereais',
        destaque: 'mais vendido',
        precoPromocional: 5.99,
        favorito: false,
      );
    });

    group('Constructor', () {
      test('deve criar produto com todos os campos obrigatórios', () {
        final produto = Produto(
          id: 'test_123',
          nome: 'Arroz',
          preco: 6.99,
          imagemUrl: 'https://example.com/arroz.jpg',
        );

        expect(produto.id, equals('test_123'));
        expect(produto.nome, equals('Arroz'));
        expect(produto.preco, equals(6.99));
        expect(produto.imagemUrl, equals('https://example.com/arroz.jpg'));
        expect(produto.descricao, isNull);
        expect(produto.categoria, isNull);
        expect(produto.destaque, isNull);
        expect(produto.precoPromocional, isNull);
        expect(produto.favorito, isFalse);
      });

      test('deve criar produto com todos os campos opcionais', () {
        final produto = Produto(
          id: 'test_123',
          nome: 'Arroz',
          preco: 6.99,
          imagemUrl: 'https://example.com/arroz.jpg',
          descricao: 'Arroz integral',
          categoria: 'Cereais',
          destaque: 'mais vendido',
          precoPromocional: 5.99,
          favorito: true,
        );

        expect(produto.descricao, equals('Arroz integral'));
        expect(produto.categoria, equals('Cereais'));
        expect(produto.destaque, equals('mais vendido'));
        expect(produto.precoPromocional, equals(5.99));
        expect(produto.favorito, isTrue);
      });

      test('deve definir favorito como false por padrão', () {
        final produto = Produto(
          id: 'test_123',
          nome: 'Arroz',
          preco: 6.99,
          imagemUrl: 'https://example.com/arroz.jpg',
        );

        expect(produto.favorito, isFalse);
      });
    });

    group('copyWith', () {
      test('deve criar cópia idêntica quando nenhum parâmetro é fornecido', () {
        final copia = produto.copyWith();

        expect(copia.id, equals(produto.id));
        expect(copia.nome, equals(produto.nome));
        expect(copia.preco, equals(produto.preco));
        expect(copia.imagemUrl, equals(produto.imagemUrl));
        expect(copia.descricao, equals(produto.descricao));
        expect(copia.categoria, equals(produto.categoria));
        expect(copia.destaque, equals(produto.destaque));
        expect(copia.precoPromocional, equals(produto.precoPromocional));
        expect(copia.favorito, equals(produto.favorito));
      });

      test('deve modificar apenas os campos especificados', () {
        final copia = produto.copyWith(
          nome: 'Feijão',
          preco: 7.99,
          favorito: true,
        );

        expect(copia.id, equals(produto.id));
        expect(copia.nome, equals('Feijão'));
        expect(copia.preco, equals(7.99));
        expect(copia.imagemUrl, equals(produto.imagemUrl));
        expect(copia.descricao, equals(produto.descricao));
        expect(copia.categoria, equals(produto.categoria));
        expect(copia.destaque, equals(produto.destaque));
        expect(copia.precoPromocional, equals(produto.precoPromocional));
        expect(copia.favorito, isTrue);
      });

      test('deve permitir definir campos como null', () {
        final copia = produto.copyWith(
          descricao: null,
          categoria: null,
          destaque: null,
          precoPromocional: null,
        );

        expect(copia.descricao, isNull);
        expect(copia.categoria, isNull);
        expect(copia.destaque, isNull);
        expect(copia.precoPromocional, isNull);
      });
    });

    group('toMap', () {
      test('deve converter produto para Map com todos os campos', () {
        final map = produto.toMap();

        expect(map['id'], equals('test_123'));
        expect(map['nome'], equals('Arroz Integral'));
        expect(map['preco'], equals(6.99));
        expect(map['imagemUrl'], equals('https://example.com/arroz.jpg'));
        expect(map['descricao'], equals('Arroz integral orgânico'));
        expect(map['categoria'], equals('Cereais'));
        expect(map['destaque'], equals('mais vendido'));
        expect(map['precoPromocional'], equals(5.99));
        expect(map['favorito'], isFalse);
      });

      test('deve converter produto sem campos opcionais', () {
        final produtoSimples = Produto(
          id: 'test_123',
          nome: 'Arroz',
          preco: 6.99,
          imagemUrl: 'https://example.com/arroz.jpg',
        );

        final map = produtoSimples.toMap();

        expect(map['id'], equals('test_123'));
        expect(map['nome'], equals('Arroz'));
        expect(map['preco'], equals(6.99));
        expect(map['imagemUrl'], equals('https://example.com/arroz.jpg'));
        expect(map['descricao'], isNull);
        expect(map['categoria'], isNull);
        expect(map['destaque'], isNull);
        expect(map['precoPromocional'], isNull);
        expect(map['favorito'], isFalse);
      });
    });

    group('fromMap', () {
      test('deve criar produto a partir de Map completo', () {
        final map = {
          'id': 'test_123',
          'nome': 'Arroz Integral',
          'preco': 6.99,
          'imagemUrl': 'https://example.com/arroz.jpg',
          'descricao': 'Arroz integral orgânico',
          'categoria': 'Cereais',
          'destaque': 'mais vendido',
          'precoPromocional': 5.99,
          'favorito': true,
        };

        final produto = Produto.fromMap(map);

        expect(produto.id, equals('test_123'));
        expect(produto.nome, equals('Arroz Integral'));
        expect(produto.preco, equals(6.99));
        expect(produto.imagemUrl, equals('https://example.com/arroz.jpg'));
        expect(produto.descricao, equals('Arroz integral orgânico'));
        expect(produto.categoria, equals('Cereais'));
        expect(produto.destaque, equals('mais vendido'));
        expect(produto.precoPromocional, equals(5.99));
        expect(produto.favorito, isTrue);
      });

      test('deve criar produto a partir de Map com campos ausentes', () {
        final map = {
          'id': 'test_123',
          'nome': 'Arroz',
          'preco': 6.99,
          'imagemUrl': 'https://example.com/arroz.jpg',
        };

        final produto = Produto.fromMap(map);

        expect(produto.id, equals('test_123'));
        expect(produto.nome, equals('Arroz'));
        expect(produto.preco, equals(6.99));
        expect(produto.imagemUrl, equals('https://example.com/arroz.jpg'));
        expect(produto.descricao, isNull);
        expect(produto.categoria, isNull);
        expect(produto.destaque, isNull);
        expect(produto.precoPromocional, isNull);
        expect(produto.favorito, isFalse);
      });

      test('deve lidar com valores nulos no Map', () {
        final map = {
          'id': 'test_123',
          'nome': 'Arroz',
          'preco': 6.99,
          'imagemUrl': 'https://example.com/arroz.jpg',
          'descricao': null,
          'categoria': null,
          'destaque': null,
          'precoPromocional': null,
          'favorito': null,
        };

        final produto = Produto.fromMap(map);

        expect(produto.descricao, isNull);
        expect(produto.categoria, isNull);
        expect(produto.destaque, isNull);
        expect(produto.precoPromocional, isNull);
        expect(produto.favorito, isFalse);
      });

      test('deve converter precoPromocional de int para double', () {
        final map = {
          'id': 'test_123',
          'nome': 'Arroz',
          'preco': 6.99,
          'imagemUrl': 'https://example.com/arroz.jpg',
          'precoPromocional': 5,
        };

        final produto = Produto.fromMap(map);

        expect(produto.precoPromocional, equals(5.0));
        expect(produto.precoPromocional.runtimeType, equals(double));
      });

      test('deve usar valores padrão para campos ausentes', () {
        final map = <String, dynamic>{};

        final produto = Produto.fromMap(map);

        expect(produto.id, equals(''));
        expect(produto.nome, equals(''));
        expect(produto.preco, equals(0.0));
        expect(produto.imagemUrl, equals(''));
        expect(produto.descricao, isNull);
        expect(produto.categoria, isNull);
        expect(produto.destaque, isNull);
        expect(produto.precoPromocional, isNull);
        expect(produto.favorito, isFalse);
      });
    });

    group('toString', () {
      test('deve retornar representação string do produto', () {
        final string = produto.toString();

        expect(string, contains('Produto'));
        expect(string, contains('test_123'));
        expect(string, contains('Arroz Integral'));
        expect(string, contains('6.99'));
        expect(string, contains('Cereais'));
      });
    });

    group('Equality', () {
      test('deve ser igual a outro produto com mesmo id', () {
        final produto2 = Produto(
          id: 'test_123',
          nome: 'Feijão',
          preco: 7.99,
          imagemUrl: 'https://example.com/feijao.jpg',
        );

        expect(produto, equals(produto2));
      });

      test('não deve ser igual a produto com id diferente', () {
        final produto2 = Produto(
          id: 'test_456',
          nome: 'Arroz Integral',
          preco: 6.99,
          imagemUrl: 'https://example.com/arroz.jpg',
        );

        expect(produto, isNot(equals(produto2)));
      });

      test('deve ser igual a si mesmo', () {
        expect(produto, equals(produto));
      });

      test('não deve ser igual a objeto de tipo diferente', () {
        expect(produto, isNot(equals('string')));
      });
    });

    group('hashCode', () {
      test('deve retornar hashCode baseado no id', () {
        final produto2 = Produto(
          id: 'test_123',
          nome: 'Feijão',
          preco: 7.99,
          imagemUrl: 'https://example.com/feijao.jpg',
        );

        expect(produto.hashCode, equals(produto2.hashCode));
      });

      test('deve retornar hashCode diferente para ids diferentes', () {
        final produto2 = Produto(
          id: 'test_456',
          nome: 'Arroz Integral',
          preco: 6.99,
          imagemUrl: 'https://example.com/arroz.jpg',
        );

        expect(produto.hashCode, isNot(equals(produto2.hashCode)));
      });
    });

    group('produtosMock', () {
      test('deve conter lista de produtos válidos', () {
        expect(produtosMock, isNotEmpty);
        expect(produtosMock.length, equals(10));
      });

      test('deve ter produtos com diferentes destaques', () {
        final destaques = produtosMock
            .map((p) => p.destaque)
            .where((d) => d != null)
            .toSet();

        expect(destaques, contains('oferta'));
        expect(destaques, contains('mais vendido'));
        expect(destaques, contains('novo'));
      });

      test('deve ter produtos com e sem preço promocional', () {
        final comPromocao = produtosMock.where((p) => p.precoPromocional != null);
        final semPromocao = produtosMock.where((p) => p.precoPromocional == null);

        expect(comPromocao, isNotEmpty);
        expect(semPromocao, isNotEmpty);
      });

      test('deve ter produtos favoritos e não favoritos', () {
        final favoritos = produtosMock.where((p) => p.favorito);
        final naoFavoritos = produtosMock.where((p) => !p.favorito);

        expect(favoritos, isNotEmpty);
        expect(naoFavoritos, isNotEmpty);
      });
    });
  });
} 