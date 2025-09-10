import 'package:flutter_test/flutter_test.dart';
import 'package:mercado_facil/data/services/carrinho_provider.dart';
import 'package:mercado_facil/data/models/produto.dart';

void main() {
  group('CarrinhoProvider', () {
    late CarrinhoProvider carrinhoProvider;
    late Produto produtoTeste;

    setUp(() {
      carrinhoProvider = CarrinhoProvider(userId: 'test_user_123');
      produtoTeste = Produto(
        id: '1',
        nome: 'Produto Teste',
        preco: 10.0,
        imagemUrl: 'teste.jpg',
        descricao: 'Descrição do produto teste',
        categoria: 'Teste',
      );
    });

    test('deve inicializar com carrinho vazio', () {
      expect(carrinhoProvider.itens, isEmpty);
      expect(carrinhoProvider.total, 0.0);
    });

    test('deve adicionar produto ao carrinho', () {
      carrinhoProvider.adicionarProduto(produtoTeste);
      
      expect(carrinhoProvider.itens.length, 1);
      expect(carrinhoProvider.itens.first.produto.id, produtoTeste.id);
      expect(carrinhoProvider.itens.first.quantidade, 1);
    });

    test('deve incrementar quantidade ao adicionar produto existente', () {
      carrinhoProvider.adicionarProduto(produtoTeste);
      carrinhoProvider.adicionarProduto(produtoTeste);
      
      expect(carrinhoProvider.itens.length, 1);
      expect(carrinhoProvider.itens.first.quantidade, 2);
    });

    test('deve remover produto do carrinho', () {
      carrinhoProvider.adicionarProduto(produtoTeste);
      carrinhoProvider.removerProduto(produtoTeste);
      
      expect(carrinhoProvider.itens, isEmpty);
    });

    test('deve alterar quantidade do produto', () {
      carrinhoProvider.adicionarProduto(produtoTeste);
      carrinhoProvider.alterarQuantidade(produtoTeste, 5);
      
      expect(carrinhoProvider.itens.first.quantidade, 5);
    });

    test('deve calcular total corretamente', () {
      carrinhoProvider.adicionarProduto(produtoTeste);
      carrinhoProvider.adicionarProduto(produtoTeste);
      
      expect(carrinhoProvider.total, 20.0);
    });

    test('deve calcular total com preço promocional', () {
      final produtoPromocional = Produto(
        id: '2',
        nome: 'Produto Promocional',
        preco: 20.0,
        imagemUrl: 'promocional.jpg',
        descricao: 'Produto com desconto',
        categoria: 'Teste',
        precoPromocional: 15.0,
      );
      
      carrinhoProvider.adicionarProduto(produtoPromocional);
      
      expect(carrinhoProvider.total, 15.0);
    });

    test('deve limpar carrinho', () {
      carrinhoProvider.adicionarProduto(produtoTeste);
      carrinhoProvider.limparCarrinho();
      
      expect(carrinhoProvider.itens, isEmpty);
      expect(carrinhoProvider.total, 0.0);
    });

    test('deve retornar quantidade total de itens', () {
      carrinhoProvider.adicionarProduto(produtoTeste);
      carrinhoProvider.adicionarProduto(produtoTeste);
      
      final quantidadeTotal = carrinhoProvider.itens.fold(0, (soma, item) => soma + item.quantidade);
      expect(quantidadeTotal, 2);
    });

    test('deve remover produto quando quantidade for zero', () {
      carrinhoProvider.adicionarProduto(produtoTeste);
      carrinhoProvider.alterarQuantidade(produtoTeste, 0);
      
      expect(carrinhoProvider.itens, isEmpty);
    });
  });
}