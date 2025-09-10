import '../models/carrinho_item.dart';
import '../models/produto.dart';

/// Interface do repositório de carrinho
/// 
/// Define os contratos para operações de carrinho,
/// permitindo diferentes implementações (Firestore, mock, etc.)
abstract class CarrinhoRepository {
  /// Carrega o carrinho do usuário
  Future<List<CarrinhoItem>> carregarCarrinho(String userId);

  /// Salva o carrinho do usuário
  Future<void> salvarCarrinho(String userId, List<CarrinhoItem> itens);

  /// Adiciona produto ao carrinho
  Future<void> adicionarProduto(String userId, Produto produto);

  /// Remove produto do carrinho
  Future<void> removerProduto(String userId, String produtoId);

  /// Altera quantidade de um produto
  Future<void> alterarQuantidade(String userId, String produtoId, int quantidade);

  /// Limpa o carrinho
  Future<void> limparCarrinho(String userId);

  /// Obtém stream do carrinho (tempo real)
  Stream<List<CarrinhoItem>> carrinhoStream(String userId);
}

/// Implementação do repositório de carrinho usando Firestore
/// 
/// Implementa a interface CarrinhoRepository usando Firestore diretamente
class FirestoreCarrinhoRepository implements CarrinhoRepository {
  final dynamic _firestore; // FirebaseFirestore

  FirestoreCarrinhoRepository(this._firestore);

  static const String _colecao = 'carrinhos';

  @override
  Future<List<CarrinhoItem>> carregarCarrinho(String userId) async {
    if (userId.isEmpty) return [];

    try {
      final doc = await _firestore.collection(_colecao).doc(userId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final itensFirestore = data['itens'] as List<dynamic>? ?? [];
        return itensFirestore.map((item) => CarrinhoItem(
          produto: Produto.fromMap(item['produto']),
          quantidade: item['quantidade'] ?? 1,
        )).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> salvarCarrinho(String userId, List<CarrinhoItem> itens) async {
    if (userId.isEmpty) return;

    try {
      final itensFirestore = itens.map((item) => {
        'produto': item.produto.toMap(),
        'quantidade': item.quantidade,
      }).toList();
      
      await _firestore.collection(_colecao).doc(userId).set({
        'itens': itensFirestore,
      });
    } catch (e) {
      // Ignorar erro ao salvar
    }
  }

  @override
  Future<void> adicionarProduto(String userId, Produto produto) async {
    if (userId.isEmpty) return;

    final itens = await carregarCarrinho(userId);
    final index = itens.indexWhere((item) => item.produto.id == produto.id);
    
    if (index >= 0) {
      itens[index].quantidade++;
    } else {
      itens.add(CarrinhoItem(produto: produto));
    }
    
    await salvarCarrinho(userId, itens);
  }

  @override
  Future<void> removerProduto(String userId, String produtoId) async {
    if (userId.isEmpty) return;

    final itens = await carregarCarrinho(userId);
    itens.removeWhere((item) => item.produto.id == produtoId);
    await salvarCarrinho(userId, itens);
  }

  @override
  Future<void> alterarQuantidade(String userId, String produtoId, int quantidade) async {
    if (userId.isEmpty) return;

    final itens = await carregarCarrinho(userId);
    final index = itens.indexWhere((item) => item.produto.id == produtoId);
    
    if (index >= 0) {
      if (quantidade <= 0) {
        itens.removeAt(index);
      } else {
        itens[index].quantidade = quantidade;
      }
      await salvarCarrinho(userId, itens);
    }
  }

  @override
  Future<void> limparCarrinho(String userId) async {
    if (userId.isEmpty) return;
    await salvarCarrinho(userId, []);
  }

  @override
  Stream<List<CarrinhoItem>> carrinhoStream(String userId) {
    if (userId.isEmpty) {
      return Stream.value([]);
    }
    
    return _firestore.collection(_colecao).doc(userId).snapshots().map((doc) {
      if (!doc.exists) return [];
      
      final data = doc.data() as Map<String, dynamic>;
      final itensFirestore = data['itens'] as List<dynamic>? ?? [];
      return itensFirestore.map((item) => CarrinhoItem(
        produto: Produto.fromMap(item['produto']),
        quantidade: item['quantidade'] ?? 1,
      )).toList();
    });
  }
} 