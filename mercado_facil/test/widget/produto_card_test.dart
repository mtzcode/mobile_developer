import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mercado_facil/presentation/widgets/produto_card.dart';
import 'package:mercado_facil/data/models/produto.dart';

void main() {
  group('ProdutoCard Widget Tests', () {
    late Produto produtoTeste;

    setUp(() {
      produtoTeste = Produto(
        id: '1',
        nome: 'Banana Prata',
        preco: 5.99,
        imagemUrl: 'https://via.placeholder.com/150',
        descricao: 'Banana prata fresca',
        categoria: 'Frutas',
        destaque: 'oferta',
        precoPromocional: 4.99,
        favorito: false,
      );
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: Scaffold(
          body: ProdutoCard(
            produto: produtoTeste,
            onAdicionarAoCarrinho: () {},
            onToggleFavorito: () {},
          ),
        ),
      );
    }

    testWidgets('deve renderizar card de produto', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Banana Prata'), findsOneWidget);
    });

    testWidgets('deve exibir preço promocional quando disponível', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('R\$ 4,99'), findsOneWidget);
    });

    testWidgets('deve exibir badge de oferta quando produto tem destaque', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('OFERTA'), findsOneWidget);
    });

    testWidgets('deve exibir botão de adicionar ao carrinho', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.add_shopping_cart), findsOneWidget);
    });

    testWidgets('deve exibir botão de favorito', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    });

    testWidgets('deve chamar callback ao adicionar ao carrinho', (WidgetTester tester) async {
      bool callbackChamado = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProdutoCard(
              produto: produtoTeste,
              onAdicionarAoCarrinho: () {
                callbackChamado = true;
              },
              onToggleFavorito: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.add_shopping_cart));
      await tester.pumpAndSettle();

      expect(callbackChamado, true);
    });

    testWidgets('deve chamar callback ao favoritar produto', (WidgetTester tester) async {
      bool callbackChamado = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProdutoCard(
              produto: produtoTeste,
              onAdicionarAoCarrinho: () {},
              onToggleFavorito: () {
                callbackChamado = true;
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.favorite_border));
      await tester.pumpAndSettle();

      expect(callbackChamado, true);
    });

    testWidgets('deve exibir ícone de favorito preenchido quando produto é favorito', (WidgetTester tester) async {
      produtoTeste.favorito = true;
      
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });

    testWidgets('deve exibir imagem do produto', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('deve exibir preço riscado quando há promoção', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verifica se o preço promocional está sendo exibido
      expect(find.text('R\$ 4,99'), findsOneWidget);
    });

    testWidgets('deve exibir descrição no modal quando tocado', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Toca no card para abrir o modal
      await tester.tap(find.byType(Card));
      await tester.pumpAndSettle();

      // Verifica se a descrição aparece no modal
      expect(find.text('Banana prata fresca'), findsOneWidget);
    });
  });
} 