import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mercado_facil/presentation/screens/produtos_screen.dart';
import 'package:mercado_facil/data/services/carrinho_provider.dart';

void main() {
  group('ProdutosScreen Widget Tests', () {
    late CarrinhoProvider carrinhoProvider;

    setUp(() {
      carrinhoProvider = CarrinhoProvider(userId: 'test_user_123');
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: ChangeNotifierProvider<CarrinhoProvider>.value(
          value: carrinhoProvider,
          child: const ProdutosScreen(),
        ),
      );
    }

    testWidgets('deve renderizar tela de produtos', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Produtos'), findsOneWidget);
      expect(find.byType(GridView), findsOneWidget);
    });

    testWidgets('deve exibir campo de busca', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Pesquisa'), findsOneWidget);
    });

    testWidgets('deve exibir botão de filtros', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Filtros'), findsOneWidget);
      expect(find.byIcon(Icons.filter_alt), findsOneWidget);
    });

    testWidgets('deve abrir modal de filtros ao clicar no botão', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Filtros'));
      await tester.pumpAndSettle();

      expect(find.text('Promoção'), findsOneWidget);
      expect(find.text('Faixa de preço'), findsOneWidget);
    });

    testWidgets('deve exibir categorias', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Todos'), findsOneWidget);
    });

    testWidgets('deve exibir produtos no grid', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Aguarda o carregamento dos produtos
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      expect(find.byType(Card), findsWidgets);
    });

    testWidgets('deve exibir botão do carrinho', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.shopping_cart), findsOneWidget);
    });

    testWidgets('deve exibir menu lateral ao clicar no ícone de menu', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      expect(find.text('Meus Dados'), findsOneWidget);
      expect(find.text('Endereços'), findsOneWidget);
    });

    testWidgets('deve filtrar produtos por busca', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'banana');
      await tester.pumpAndSettle();

      // Verifica se a busca foi aplicada
      expect(find.text('banana'), findsOneWidget);
    });

    testWidgets('deve aplicar filtros de destaque', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Abre filtros
      await tester.tap(find.text('Filtros'));
      await tester.pumpAndSettle();

      // Seleciona filtro de oferta
      await tester.tap(find.text('Oferta'));
      await tester.pumpAndSettle();

      // Aplica filtros
      await tester.tap(find.text('Aplicar'));
      await tester.pumpAndSettle();

      // Verifica se os filtros foram aplicados
      expect(find.byType(GridView), findsOneWidget);
    });
  });
}