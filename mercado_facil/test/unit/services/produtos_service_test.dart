import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:mercado_facil/data/services/produtos_service.dart';
import 'package:mercado_facil/data/services/firestore_service.dart';
import 'package:mercado_facil/data/models/produto.dart';

// Gerar mocks
@GenerateMocks([FirestoreService])
import 'produtos_service_test.mocks.dart';

void main() {
  group('ProdutosService Tests', () {
    late MockFirestoreService mockFirestoreService;
    late List<Produto> produtosMock;

    setUp(() {
      mockFirestoreService = MockFirestoreService();
      
      produtosMock = [
        Produto(
          id: '1',
          nome: 'Arroz Integral',
          preco: 8.50,
          imagemUrl: 'https://example.com/arroz.jpg',
          descricao: 'Arroz integral orgânico',
          categoria: 'Grãos',
          destaque: 'oferta',
          precoPromocional: 7.50,
          favorito: false,
        ),
        Produto(
          id: '2',
          nome: 'Feijão Preto',
          preco: 6.00,
          imagemUrl: 'https://example.com/feijao.jpg',
          descricao: 'Feijão preto selecionado',
          categoria: 'Grãos',
          destaque: 'novo',
          favorito: true,
        ),
      ];
    });

    group('getProdutosMock', () {
      test('deve retornar lista de produtos mock', () {
        final produtos = ProdutosService.getProdutosMock();

        expect(produtos, isNotEmpty);
        expect(produtos, hasLength(8));
        expect(produtos.first, isA<Produto>());
        expect(produtos.first.id, equals('1'));
        expect(produtos.first.nome, equals('Arroz Integral'));
      });
    });

    group('getProdutos', () {
      test('deve carregar produtos do Firestore', () async {
        when(mockFirestoreService.getProdutos()).thenAnswer((_) async => produtosMock);

        final produtos = await mockFirestoreService.getProdutos();

        expect(produtos, equals(produtosMock));
        verify(mockFirestoreService.getProdutos()).called(1);
      });
    });
  });
}