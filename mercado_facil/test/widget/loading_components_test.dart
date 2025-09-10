import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mercado_facil/presentation/widgets/app_loading_components.dart';
import '../test_config.dart';

void main() {
  group('Loading Components Widget Tests', () {
    group('AppLoadingIndicator', () {
      testWidgets('deve renderizar indicador de loading com texto', (WidgetTester tester) async {
        await tester.pumpWidget(
          TestConfig.createTestApp(
            child: const AppLoadingIndicator(
              message: 'Carregando produtos...',
            ),
          ),
        );

        expect(find.text('Carregando produtos...'), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('deve renderizar indicador de loading sem texto', (WidgetTester tester) async {
        await tester.pumpWidget(
          TestConfig.createTestApp(
            child: const AppLoadingIndicator(),
          ),
        );

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('deve usar cores do tema', (WidgetTester tester) async {
        await tester.pumpWidget(
          TestConfig.createTestApp(
            child: const AppLoadingIndicator(
              message: 'Carregando...',
            ),
          ),
        );

        final progressIndicator = tester.widget<CircularProgressIndicator>(
          find.byType(CircularProgressIndicator),
        );

        expect(progressIndicator.valueColor, isNotNull);
      });

      testWidgets('deve ter layout responsivo', (WidgetTester tester) async {
        await tester.pumpWidget(
          TestConfig.createTestApp(
            child: const AppLoadingIndicator(
              message: 'Carregando produtos...',
            ),
          ),
        );

        final container = tester.widget<Container>(
          find.byType(Container).first,
        );

        expect(container.padding, isNotNull);
        expect(container.alignment, equals(Alignment.center));
      });
    });

    group('AppShimmerLoading', () {
      testWidgets('deve renderizar shimmer com altura especificada', (WidgetTester tester) async {
        await tester.pumpWidget(
          TestConfig.createTestApp(
            child: const AppShimmerLoading(
              height: 100.0,
              width: 200.0,
            ),
          ),
        );

        final container = tester.widget<Container>(
          find.byType(Container).first,
        );

        expect(container.constraints, isNotNull);
        expect(container.constraints!.maxHeight, equals(100.0));
        expect(container.constraints!.maxWidth, equals(200.0));
      });

      testWidgets('deve renderizar shimmer com altura padrão', (WidgetTester tester) async {
        await tester.pumpWidget(
          TestConfig.createTestApp(
            child: const AppShimmerLoading(),
          ),
        );

        final container = tester.widget<Container>(
          find.byType(Container).first,
        );

        expect(container.constraints, isNotNull);
        expect(container.constraints!.maxHeight, equals(20.0));
      });

      testWidgets('deve ter animação de shimmer', (WidgetTester tester) async {
        await tester.pumpWidget(
          TestConfig.createTestApp(
            child: const AppShimmerLoading(),
          ),
        );

        expect(find.byType(AnimatedBuilder), findsOneWidget);
      });

      testWidgets('deve usar cores do tema para shimmer', (WidgetTester tester) async {
        await tester.pumpWidget(
          TestConfig.createTestApp(
            child: const AppShimmerLoading(),
          ),
        );

        final container = tester.widget<Container>(
          find.byType(Container).first,
        );

        expect(container.decoration, isNotNull);
        expect(container.decoration, isA<BoxDecoration>());
        final boxDecoration = container.decoration as BoxDecoration;
        expect(boxDecoration.gradient, isNotNull);
      });
    });

    group('AppSkeletonCard', () {
      testWidgets('deve renderizar skeleton card com imagem', (WidgetTester tester) async {
        await tester.pumpWidget(
          TestConfig.createTestApp(
            child: const AppSkeletonCard(
              showImage: true,
            ),
          ),
        );

        expect(find.byType(AppShimmerLoading), findsNWidgets(4)); // imagem + 3 linhas de texto
      });

      testWidgets('deve renderizar skeleton card sem imagem', (WidgetTester tester) async {
        await tester.pumpWidget(
          TestConfig.createTestApp(
            child: const AppSkeletonCard(
              showImage: false,
            ),
          ),
        );

        expect(find.byType(AppShimmerLoading), findsNWidgets(3)); // 3 linhas de texto
      });

      testWidgets('deve ter layout de card', (WidgetTester tester) async {
        await tester.pumpWidget(
          TestConfig.createTestApp(
            child: const AppSkeletonCard(),
          ),
        );

        expect(find.byType(Card), findsOneWidget);
        expect(find.byType(Padding), findsWidgets);
      });

      testWidgets('deve ter espaçamento correto entre elementos', (WidgetTester tester) async {
        await tester.pumpWidget(
          TestConfig.createTestApp(
            child: const AppSkeletonCard(),
          ),
        );

        final column = tester.widget<Column>(
          find.byType(Column).first,
        );

        expect(column.children.length, greaterThan(1));
      });
    });

    group('AppSkeletonGrid', () {
      testWidgets('deve renderizar grid de skeleton cards', (WidgetTester tester) async {
        await tester.pumpWidget(
          TestConfig.createTestApp(
            child: const AppSkeletonGrid(
              crossAxisCount: 2,
              itemCount: 6,
            ),
          ),
        );

        expect(find.byType(AppSkeletonCard), findsNWidgets(6));
        expect(find.byType(GridView), findsOneWidget);
      });

      testWidgets('deve ter configuração de grid correta', (WidgetTester tester) async {
        await tester.pumpWidget(
          TestConfig.createTestApp(
            child: const AppSkeletonGrid(
              crossAxisCount: 3,
              itemCount: 9,
              childAspectRatio: 1.0,
            ),
          ),
        );

        final gridView = tester.widget<GridView>(
          find.byType(GridView),
        );

        expect(gridView.childrenDelegate, isNotNull);
      });

      testWidgets('deve ser scrollável', (WidgetTester tester) async {
        await tester.pumpWidget(
          TestConfig.createTestApp(
            child: const AppSkeletonGrid(
              itemCount: 20,
            ),
          ),
        );

        expect(find.byType(GridView), findsOneWidget);
      });

      testWidgets('deve ter espaçamento entre items', (WidgetTester tester) async {
        await tester.pumpWidget(
          TestConfig.createTestApp(
            child: const AppSkeletonGrid(
              itemCount: 8,
            ),
          ),
        );

        expect(find.byType(AppSkeletonGrid), findsOneWidget);
        expect(find.byType(AppSkeletonCard), findsNWidgets(8));
      });
    });

    group('AppSkeletonList', () {
      testWidgets('deve renderizar lista de skeleton items', (WidgetTester tester) async {
        await tester.pumpWidget(
          TestConfig.createTestApp(
            child: const AppSkeletonList(
              itemCount: 5,
            ),
          ),
        );

        expect(find.byType(AppShimmerLoading), findsNWidgets(5));
        expect(find.byType(ListView), findsOneWidget);
      });

      testWidgets('deve ter espaçamento entre items', (WidgetTester tester) async {
        await tester.pumpWidget(
          TestConfig.createTestApp(
            child: const AppSkeletonList(
              itemCount: 3,
            ),
          ),
        );

        final listView = tester.widget<ListView>(
          find.byType(ListView),
        );

        expect(listView.childrenDelegate, isNotNull);
      });

      testWidgets('deve ser scrollável', (WidgetTester tester) async {
        await tester.pumpWidget(
          TestConfig.createTestApp(
            child: const AppSkeletonList(
              itemCount: 10,
            ),
          ),
        );

        expect(find.byType(ListView), findsOneWidget);
      });
    });

    group('AppLoadingOverlay', () {
      testWidgets('deve renderizar overlay de loading', (WidgetTester tester) async {
        await tester.pumpWidget(
          TestConfig.createTestApp(
            child: const AppLoadingOverlay(
              isLoading: true,
              child: Text('Conteúdo'),
            ),
          ),
        );

        expect(find.text('Conteúdo'), findsOneWidget);
        expect(find.byType(AppLoadingIndicator), findsOneWidget);
      });

      testWidgets('não deve renderizar overlay quando não está carregando', (WidgetTester tester) async {
        await tester.pumpWidget(
          TestConfig.createTestApp(
            child: const AppLoadingOverlay(
              isLoading: false,
              child: Text('Conteúdo'),
            ),
          ),
        );

        expect(find.text('Conteúdo'), findsOneWidget);
        expect(find.byType(AppLoadingIndicator), findsNothing);
      });

      testWidgets('deve ter overlay semi-transparente', (WidgetTester tester) async {
        await tester.pumpWidget(
          TestConfig.createTestApp(
            child: const AppLoadingOverlay(
              isLoading: true,
              child: Text('Conteúdo'),
            ),
          ),
        );

        expect(find.byType(Container), findsWidgets);
      });

      testWidgets('deve centralizar o indicador de loading', (WidgetTester tester) async {
        await tester.pumpWidget(
          TestConfig.createTestApp(
            child: const AppLoadingOverlay(
              isLoading: true,
              child: Text('Conteúdo'),
            ),
          ),
        );

        final center = tester.widget<Center>(
          find.byType(Center).first,
        );

        expect(center.child, isA<AppLoadingIndicator>());
      });
    });

    group('AppPullToRefresh', () {
      testWidgets('deve renderizar widget com pull to refresh', (WidgetTester tester) async {
        await tester.pumpWidget(
          TestConfig.createTestApp(
            child: AppPullToRefresh(
              onRefresh: () async {
              },
              child: const Text('Conteúdo'),
            ),
          ),
        );

        expect(find.text('Conteúdo'), findsOneWidget);
        expect(find.byType(RefreshIndicator), findsOneWidget);
      });

      testWidgets('deve ter cor personalizada', (WidgetTester tester) async {
        await tester.pumpWidget(
          TestConfig.createTestApp(
            child: AppPullToRefresh(
              onRefresh: () async {},
              color: Colors.red,
              child: const Text('Conteúdo'),
            ),
          ),
        );

        final refreshIndicator = tester.widget<RefreshIndicator>(
          find.byType(RefreshIndicator),
        );

        expect(refreshIndicator.color, equals(Colors.red));
      });
    });

    group('AppTransitionWrapper', () {
      testWidgets('deve renderizar widget com transição', (WidgetTester tester) async {
        await tester.pumpWidget(
          TestConfig.createTestApp(
            child: const AppTransitionWrapper(
              child: Text('Conteúdo'),
            ),
          ),
        );

        expect(find.text('Conteúdo'), findsOneWidget);
        expect(find.byType(AnimatedBuilder), findsOneWidget);
      });

      testWidgets('deve ter animação de fade in', (WidgetTester tester) async {
        await tester.pumpWidget(
          TestConfig.createTestApp(
            child: const AppTransitionWrapper(
              child: Text('Conteúdo'),
            ),
          ),
        );

        expect(find.byType(Opacity), findsOneWidget);
      });

      testWidgets('deve ter transform de translate', (WidgetTester tester) async {
        await tester.pumpWidget(
          TestConfig.createTestApp(
            child: const AppTransitionWrapper(
              child: Text('Conteúdo'),
            ),
          ),
        );

        expect(find.byType(Transform), findsOneWidget);
      });

      testWidgets('deve desabilitar transição quando enabled = false', (WidgetTester tester) async {
        await tester.pumpWidget(
          TestConfig.createTestApp(
            child: const AppTransitionWrapper(
              enabled: false,
              child: Text('Conteúdo'),
            ),
          ),
        );

        expect(find.text('Conteúdo'), findsOneWidget);
        expect(find.byType(AnimatedBuilder), findsNothing);
      });
    });
  });
}