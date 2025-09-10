import 'produto.dart';

class CarrinhoItem {
  final Produto produto;
  int quantidade;

  CarrinhoItem({required this.produto, this.quantidade = 1});

  double get preco => produto.precoPromocional ?? produto.preco;
  double get subtotal => preco * quantidade;
}