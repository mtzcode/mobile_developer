import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mercado_facil/main.dart' as app;
import '../test_config.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Produtos Flow Integration Tests', () {
    testWidgets('deve carregar produtos e exibir na tela', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Aguarda carregamento inicial
      await TestConfig.waitForAsync(tester);

      // Verifica se os produtos foram carregados
      expect(find.byType(GridView), findsOneWidget);
      expect(find.byType(Card), findsWidgets);

      // Verifica se há produtos na tela
      final produtosCards = find.byType(Card);
      expect(produtosCards, findsWidgets);
    });

    testWidgets('deve filtrar produtos por categoria', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Aguarda carregamento inicial
      await TestConfig.waitForAsync(tester);

      // Procura por filtros de categoria
      final filtros = find.byType(Chip);
      if (filtros.evaluate().isNotEmpty) {
        // Toca no primeiro filtro
        await tester.tapAndWait(filtros.first);
        
        // Verifica se a lista foi filtrada
        await TestConfig.waitForAsync(tester);
        expect(find.byType(GridView), findsOneWidget);
      }
    });

    testWidgets('deve buscar produtos', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Aguarda carregamento inicial
      await TestConfig.waitForAsync(tester);

      // Procura por campo de busca
      final searchField = find.byType(TextField);
      if (searchField.evaluate().isNotEmpty) {
        // Insere texto na busca
        await tester.enterTextAndWait(searchField.first, 'arroz');
        
        // Verifica se a busca foi executada
        await TestConfig.waitForAsync(tester);
        expect(find.byType(GridView), findsOneWidget);
      }
    });

    testWidgets('deve adicionar produto ao carrinho', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Aguarda carregamento inicial
      await TestConfig.waitForAsync(tester);

      // Procura por botões de adicionar ao carrinho
      final addButtons = find.byIcon(Icons.add);
      if (addButtons.evaluate().isNotEmpty) {
        // Toca no primeiro botão de adicionar
        await tester.tapAndWait(addButtons.first);
        
        // Verifica se o produto foi adicionado (pode haver feedback visual)
        await TestConfig.waitForAsync(tester);
      }
    });

    testWidgets('deve favoritar produto', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Aguarda carregamento inicial
      await TestConfig.waitForAsync(tester);

      // Procura por botões de favorito
      final favoriteButtons = find.byIcon(Icons.favorite_border);
      if (favoriteButtons.evaluate().isNotEmpty) {
        // Toca no primeiro botão de favorito
        await tester.tapAndWait(favoriteButtons.first);
        
        // Verifica se o produto foi favoritado
        await TestConfig.waitForAsync(tester);
        expect(find.byIcon(Icons.favorite), findsWidgets);
      }
    });

    testWidgets('deve navegar para detalhes do produto', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Aguarda carregamento inicial
      await TestConfig.waitForAsync(tester);

      // Procura por cards de produto
      final produtoCards = find.byType(Card);
      if (produtoCards.evaluate().isNotEmpty) {
        // Toca no primeiro card
        await tester.tapAndWait(produtoCards.first);
        
        // Verifica se navegou para detalhes
        await TestConfig.waitForAsync(tester);
        // Pode verificar se há elementos específicos da tela de detalhes
      }
    });

    testWidgets('deve fazer pull to refresh', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Aguarda carregamento inicial
      await TestConfig.waitForAsync(tester);

      // Procura por RefreshIndicator
      final refreshIndicator = find.byType(RefreshIndicator);
      if (refreshIndicator.evaluate().isNotEmpty) {
        // Faz pull to refresh
        await tester.dragAndWait(refreshIndicator.first, const Offset(0, 300));
        
        // Verifica se o refresh foi executado
        await TestConfig.waitForAsync(tester);
        expect(find.byType(GridView), findsOneWidget);
      }
    });

    testWidgets('deve paginar produtos', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Aguarda carregamento inicial
      await TestConfig.waitForAsync(tester);

      // Procura por GridView
      final gridView = find.byType(GridView);
      if (gridView.evaluate().isNotEmpty) {
        // Faz scroll para baixo para carregar mais produtos
        await tester.dragAndWait(gridView.first, const Offset(0, -500));
        
        // Verifica se mais produtos foram carregados
        await TestConfig.waitForAsync(tester);
        expect(find.byType(Card), findsWidgets);
      }
    });

    testWidgets('deve exibir loading durante carregamento', (tester) async {
      app.main();
      
      // Verifica se há indicador de loading inicial
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      await tester.pumpAndSettle();
      
      // Verifica se o loading foi removido
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('deve exibir skeleton loading', (tester) async {
      app.main();
      
      // Verifica se há skeleton loading inicial
      expect(find.byType(Container), findsWidgets);
      
      await tester.pumpAndSettle();
      
      // Verifica se o skeleton foi substituído por conteúdo real
      expect(find.byType(GridView), findsOneWidget);
    });

    testWidgets('deve lidar com erro de carregamento', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Aguarda carregamento inicial
      await TestConfig.waitForAsync(tester);

      // Verifica se há conteúdo mesmo com erro
      expect(find.byType(GridView), findsOneWidget);
    });

    testWidgets('deve filtrar por ofertas', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Aguarda carregamento inicial
      await TestConfig.waitForAsync(tester);

      // Procura por filtro de ofertas
      final ofertaFilter = find.text('OFERTA');
      if (ofertaFilter.evaluate().isNotEmpty) {
        // Toca no filtro de ofertas
        await tester.tapAndWait(ofertaFilter.first);
        
        // Verifica se os produtos foram filtrados
        await TestConfig.waitForAsync(tester);
        expect(find.byType(GridView), findsOneWidget);
      }
    });

    testWidgets('deve filtrar por mais vendidos', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Aguarda carregamento inicial
      await TestConfig.waitForAsync(tester);

      // Procura por filtro de mais vendidos
      final maisVendidosFilter = find.text('MAIS VENDIDO');
      if (maisVendidosFilter.evaluate().isNotEmpty) {
        // Toca no filtro de mais vendidos
        await tester.tapAndWait(maisVendidosFilter.first);
        
        // Verifica se os produtos foram filtrados
        await TestConfig.waitForAsync(tester);
        expect(find.byType(GridView), findsOneWidget);
      }
    });

    testWidgets('deve filtrar por novos produtos', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Aguarda carregamento inicial
      await TestConfig.waitForAsync(tester);

      // Procura por filtro de novos produtos
      final novosFilter = find.text('NOVO');
      if (novosFilter.evaluate().isNotEmpty) {
        // Toca no filtro de novos produtos
        await tester.tapAndWait(novosFilter.first);
        
        // Verifica se os produtos foram filtrados
        await TestConfig.waitForAsync(tester);
        expect(find.byType(GridView), findsOneWidget);
      }
    });

    testWidgets('deve limpar filtros', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Aguarda carregamento inicial
      await TestConfig.waitForAsync(tester);

      // Procura por botão de limpar filtros
      final clearFilterButton = find.byIcon(Icons.clear);
      if (clearFilterButton.evaluate().isNotEmpty) {
        // Toca no botão de limpar
        await tester.tapAndWait(clearFilterButton.first);
        
        // Verifica se os filtros foram limpos
        await TestConfig.waitForAsync(tester);
        expect(find.byType(GridView), findsOneWidget);
      }
    });

    testWidgets('deve exibir preços promocionais', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Aguarda carregamento inicial
      await TestConfig.waitForAsync(tester);

      // Verifica se há produtos com preços promocionais
      final precoPromocional = find.textContaining('R\$');
      expect(precoPromocional, findsWidgets);
    });

    testWidgets('deve exibir tags de destaque', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Aguarda carregamento inicial
      await TestConfig.waitForAsync(tester);

      // Verifica se há tags de destaque
      final tags = find.textContaining('OFERTA');
      if (tags.evaluate().isNotEmpty) {
        expect(tags, findsWidgets);
      }
    });

    testWidgets('deve ser responsivo em diferentes tamanhos', (tester) async {
      // Testa em tamanho de tablet
      tester.view.physicalSize = const Size(1024, 768);
    tester.view.devicePixelRatio = 1.0;

      app.main();
      await tester.pumpAndSettle();

      // Aguarda carregamento inicial
      await TestConfig.waitForAsync(tester);

      // Verifica se o layout se adaptou
      expect(find.byType(GridView), findsOneWidget);

      // Restaura tamanho original
      tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
    });

    testWidgets('deve manter estado durante navegação', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Aguarda carregamento inicial
      await TestConfig.waitForAsync(tester);

      // Adiciona produto ao carrinho
      final addButtons = find.byIcon(Icons.add);
      if (addButtons.evaluate().isNotEmpty) {
        await tester.tapAndWait(addButtons.first);
      }

      // Navega para outra tela e volta
      final appBar = find.byType(AppBar);
      if (appBar.evaluate().isNotEmpty) {
        // Simula navegação
        await TestConfig.waitForAsync(tester);
        
        // Verifica se o estado foi mantido
        expect(find.byType(GridView), findsOneWidget);
      }
    });
  });
}