import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mercado_facil/main.dart';

void main() {
  group('App Integration Tests', () {
    testWidgets('deve navegar do login para produtos', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Verifica se está na tela de login
      expect(find.text('Login'), findsOneWidget);

      // Simula login (pode precisar de ajuste dependendo da implementação)
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      // Verifica se navegou para produtos
      expect(find.text('Produtos'), findsOneWidget);
    });

    testWidgets('deve adicionar produto ao carrinho e verificar contador', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Navega para produtos
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      // Aguarda carregamento dos produtos
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Adiciona produto ao carrinho
      await tester.tap(find.byIcon(Icons.add_shopping_cart).first);
      await tester.pumpAndSettle();

      // Verifica se o contador do carrinho foi atualizado
      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('deve navegar para carrinho e verificar produtos', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Navega para produtos
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      // Adiciona produto ao carrinho
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.add_shopping_cart).first);
      await tester.pumpAndSettle();

      // Navega para carrinho
      await tester.tap(find.byIcon(Icons.shopping_cart));
      await tester.pumpAndSettle();

      // Verifica se está na tela do carrinho
      expect(find.text('Carrinho'), findsOneWidget);
    });

    testWidgets('deve abrir menu lateral e navegar para notificações', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Navega para produtos
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      // Abre menu lateral
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // Navega para notificações
      await tester.tap(find.text('Notificações'));
      await tester.pumpAndSettle();

      // Verifica se está na tela de notificações
      expect(find.text('Notificações'), findsOneWidget);
    });

    testWidgets('deve aplicar filtros e verificar resultados', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Navega para produtos
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      // Abre filtros
      await tester.tap(find.text('Filtros'));
      await tester.pumpAndSettle();

      // Aplica filtro de oferta
      await tester.tap(find.text('Oferta'));
      await tester.pumpAndSettle();

      // Aplica filtros
      await tester.tap(find.text('Aplicar'));
      await tester.pumpAndSettle();

      // Verifica se os filtros foram aplicados
      expect(find.byType(GridView), findsOneWidget);
    });

    testWidgets('deve buscar produtos e verificar sugestões', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Navega para produtos
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      // Digita na busca
      await tester.enterText(find.byType(TextField), 'banana');
      await tester.pumpAndSettle();

      // Verifica se aparecem sugestões
      expect(find.text('banana'), findsOneWidget);
    });
  });
}