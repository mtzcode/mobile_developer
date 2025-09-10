import '../models/pedido.dart';
import '../models/carrinho_item.dart';

/// Interface do repositório de pedidos
/// 
/// Define os contratos para operações de pedidos,
/// permitindo diferentes implementações (Firestore, mock, etc.)
abstract class PedidosRepository {
  /// Busca pedidos do usuário
  Future<List<Pedido>> buscarPedidosUsuario(String userId);

  /// Cria um novo pedido
  Future<String> criarPedido({
    required String usuarioId,
    required List<CarrinhoItem> itens,
    required Map<String, dynamic> enderecoEntrega,
    required String metodoPagamento,
    String? observacoes,
  });

  /// Busca um pedido específico
  Future<Pedido?> buscarPedido(String pedidoId);

  /// Cancela um pedido
  Future<void> cancelarPedido(String pedidoId);

  /// Atualiza status do pedido
  Future<void> atualizarStatusPedido(String pedidoId, StatusPedido novoStatus);

  /// Adiciona código de rastreamento
  Future<void> adicionarCodigoRastreamento(String pedidoId, String codigo);

  /// Busca pedidos por status
  Future<List<Pedido>> buscarPedidosPorStatus(String userId, StatusPedido status);
}

/// Implementação do repositório de pedidos usando PedidosService
/// 
/// Implementa a interface PedidosRepository usando o PedidosService
class ServicePedidosRepository implements PedidosRepository {
  final dynamic _pedidosService; // PedidosService

  ServicePedidosRepository(this._pedidosService);

  @override
  Future<List<Pedido>> buscarPedidosUsuario(String userId) async {
    return await _pedidosService.buscarPedidosUsuario(userId);
  }

  @override
  Future<String> criarPedido({
    required String usuarioId,
    required List<CarrinhoItem> itens,
    required Map<String, dynamic> enderecoEntrega,
    required String metodoPagamento,
    String? observacoes,
  }) async {
    return await _pedidosService.criarPedido(
      usuarioId: usuarioId,
      itens: itens,
      enderecoEntrega: enderecoEntrega,
      metodoPagamento: metodoPagamento,
      observacoes: observacoes,
    );
  }

  @override
  Future<Pedido?> buscarPedido(String pedidoId) async {
    return await _pedidosService.buscarPedido(pedidoId);
  }

  @override
  Future<void> cancelarPedido(String pedidoId) async {
    await _pedidosService.cancelarPedido(pedidoId);
  }

  @override
  Future<void> atualizarStatusPedido(String pedidoId, StatusPedido novoStatus) async {
    await _pedidosService.atualizarStatusPedido(pedidoId, novoStatus);
  }

  @override
  Future<void> adicionarCodigoRastreamento(String pedidoId, String codigo) async {
    await _pedidosService.adicionarCodigoRastreamento(pedidoId, codigo);
  }

  @override
  Future<List<Pedido>> buscarPedidosPorStatus(String userId, StatusPedido status) async {
    return await _pedidosService.buscarPedidosPorStatus(userId, status);
  }
} 