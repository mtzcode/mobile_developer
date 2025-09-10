import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pedido.dart';
import '../models/carrinho_item.dart';
import '../repositories/pedidos_repository.dart';

/// Estado dos pedidos
class PedidosState {
  final List<Pedido> pedidos;
  final Pedido? pedidoAtual;
  final bool carregando;
  final String? error;

  const PedidosState({
    this.pedidos = const [],
    this.pedidoAtual,
    this.carregando = false,
    this.error,
  });

  // Pedidos por status
  List<Pedido> get pedidosPendentes => pedidos.where((p) => p.status == StatusPedido.pendente).toList();
  List<Pedido> get pedidosEmAndamento => pedidos.where((p) => p.estaEmAndamento).toList();
  List<Pedido> get pedidosEntregues => pedidos.where((p) => p.foiEntregue).toList();
  List<Pedido> get pedidosCancelados => pedidos.where((p) => p.foiCancelado).toList();

  PedidosState copyWith({
    List<Pedido>? pedidos,
    Pedido? pedidoAtual,
    bool? carregando,
    String? error,
  }) {
    return PedidosState(
      pedidos: pedidos ?? this.pedidos,
      pedidoAtual: pedidoAtual ?? this.pedidoAtual,
      carregando: carregando ?? this.carregando,
      error: error ?? this.error,
    );
  }
}

/// Notifier dos pedidos usando Riverpod
class PedidosNotifier extends StateNotifier<PedidosState> {
  final PedidosRepository _pedidosRepository;
  final String userId;

  PedidosNotifier(this._pedidosRepository, this.userId) : super(const PedidosState());

  /// Carrega pedidos do usuário
  Future<void> carregarPedidos() async {
    if (userId.isEmpty) return;

    state = state.copyWith(carregando: true, error: null);

    try {
      final pedidos = await _pedidosRepository.buscarPedidosUsuario(userId);
      state = state.copyWith(
        pedidos: pedidos,
        carregando: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        carregando: false,
        error: 'Erro ao carregar pedidos: $e',
      );
    }
  }

  /// Cria novo pedido
  Future<String?> criarPedido({
    required List<CarrinhoItem> itens,
    required Map<String, dynamic> enderecoEntrega,
    required String metodoPagamento,
    String? observacoes,
  }) async {
    if (userId.isEmpty) {
      state = state.copyWith(error: 'Usuário não identificado');
      return null;
    }

    state = state.copyWith(carregando: true, error: null);

    try {
      final pedidoId = await _pedidosRepository.criarPedido(
        usuarioId: userId,
        itens: itens,
        enderecoEntrega: enderecoEntrega,
        metodoPagamento: metodoPagamento,
        observacoes: observacoes,
      );
      
      // Recarregar pedidos para incluir o novo
      await carregarPedidos();

      return pedidoId;
    } catch (e) {
      state = state.copyWith(
        carregando: false,
        error: 'Erro ao criar pedido: $e',
      );
      return null;
    }
  }

  /// Carrega pedido específico
  Future<void> carregarPedido(String pedidoId) async {
    state = state.copyWith(carregando: true, error: null);

    try {
      final pedido = await _pedidosRepository.buscarPedido(pedidoId);
      if (pedido == null) {
        state = state.copyWith(
          carregando: false,
          error: 'Pedido não encontrado',
        );
      } else {
        state = state.copyWith(
          pedidoAtual: pedido,
          carregando: false,
          error: null,
        );
      }
    } catch (e) {
      state = state.copyWith(
        carregando: false,
        error: 'Erro ao carregar pedido: $e',
      );
    }
  }

  /// Cancela pedido
  Future<bool> cancelarPedido(String pedidoId) async {
    state = state.copyWith(carregando: true, error: null);

    try {
      await _pedidosRepository.cancelarPedido(pedidoId);
      
      // Atualizar pedido na lista
      final pedidos = List<Pedido>.from(state.pedidos);
      final index = pedidos.indexWhere((p) => p.id == pedidoId);
      if (index >= 0) {
        pedidos[index] = pedidos[index].copyWith(status: StatusPedido.cancelado);
      }

      // Atualizar pedido atual se for o mesmo
      Pedido? pedidoAtual = state.pedidoAtual;
      if (pedidoAtual?.id == pedidoId) {
        pedidoAtual = pedidoAtual!.copyWith(status: StatusPedido.cancelado);
      }

      state = state.copyWith(
        pedidos: pedidos,
        pedidoAtual: pedidoAtual,
        carregando: false,
        error: null,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        carregando: false,
        error: 'Erro ao cancelar pedido: $e',
      );
      return false;
    }
  }

  /// Atualiza status do pedido
  Future<bool> atualizarStatusPedido(String pedidoId, StatusPedido novoStatus) async {
    state = state.copyWith(carregando: true, error: null);

    try {
      await _pedidosRepository.atualizarStatusPedido(pedidoId, novoStatus);
      
      // Atualizar pedido na lista
      final pedidos = List<Pedido>.from(state.pedidos);
      final index = pedidos.indexWhere((p) => p.id == pedidoId);
      if (index >= 0) {
        pedidos[index] = pedidos[index].copyWith(status: novoStatus);
      }

      // Atualizar pedido atual se for o mesmo
      Pedido? pedidoAtual = state.pedidoAtual;
      if (pedidoAtual?.id == pedidoId) {
        pedidoAtual = pedidoAtual!.copyWith(status: novoStatus);
      }

      state = state.copyWith(
        pedidos: pedidos,
        pedidoAtual: pedidoAtual,
        carregando: false,
        error: null,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        carregando: false,
        error: 'Erro ao atualizar status do pedido: $e',
      );
      return false;
    }
  }

  /// Adiciona código de rastreamento
  Future<bool> adicionarCodigoRastreamento(String pedidoId, String codigo) async {
    state = state.copyWith(carregando: true, error: null);

    try {
      await _pedidosRepository.adicionarCodigoRastreamento(pedidoId, codigo);
      
      // Atualizar pedido na lista
      final pedidos = List<Pedido>.from(state.pedidos);
      final index = pedidos.indexWhere((p) => p.id == pedidoId);
      if (index >= 0) {
        pedidos[index] = pedidos[index].copyWith(codigoRastreamento: codigo);
      }

      // Atualizar pedido atual se for o mesmo
      Pedido? pedidoAtual = state.pedidoAtual;
      if (pedidoAtual?.id == pedidoId) {
        pedidoAtual = pedidoAtual!.copyWith(codigoRastreamento: codigo);
      }

      state = state.copyWith(
        pedidos: pedidos,
        pedidoAtual: pedidoAtual,
        carregando: false,
        error: null,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        carregando: false,
        error: 'Erro ao adicionar código de rastreamento: $e',
      );
      return false;
    }
  }

  /// Busca pedidos por status
  Future<List<Pedido>> buscarPedidosPorStatus(StatusPedido status) async {
    try {
      return await _pedidosRepository.buscarPedidosPorStatus(userId, status);
    } catch (e) {
      return [];
    }
  }

  /// Limpa erro
  void limparErro() {
    state = state.copyWith(error: null);
  }

  /// Limpa pedido atual
  void limparPedidoAtual() {
    state = state.copyWith(pedidoAtual: null);
  }
}

/// Provider do repositório de pedidos
final pedidosRepositoryProvider = Provider<PedidosRepository>((ref) {
  // Aqui você injetaria a implementação correta
  // Por enquanto, vamos usar uma implementação mock ou Service
  throw UnimplementedError('Implementar injeção do PedidosRepository');
});

/// Provider do notifier de pedidos
final pedidosProvider = StateNotifierProvider.family<PedidosNotifier, PedidosState, String>((ref, userId) {
  final repository = ref.watch(pedidosRepositoryProvider);
  return PedidosNotifier(repository, userId);
});

/// Provider dos pedidos (derivado)
final pedidosListProvider = Provider.family<List<Pedido>, String>((ref, userId) {
  return ref.watch(pedidosProvider(userId)).pedidos;
});

/// Provider do pedido atual (derivado)
final pedidoAtualProvider = Provider.family<Pedido?, String>((ref, userId) {
  return ref.watch(pedidosProvider(userId)).pedidoAtual;
});

/// Provider do status de carregamento (derivado)
final pedidosCarregandoProvider = Provider.family<bool, String>((ref, userId) {
  return ref.watch(pedidosProvider(userId)).carregando;
});

/// Provider dos pedidos pendentes (derivado)
final pedidosPendentesProvider = Provider.family<List<Pedido>, String>((ref, userId) {
  return ref.watch(pedidosProvider(userId)).pedidosPendentes;
});

/// Provider dos pedidos em andamento (derivado)
final pedidosEmAndamentoProvider = Provider.family<List<Pedido>, String>((ref, userId) {
  return ref.watch(pedidosProvider(userId)).pedidosEmAndamento;
});

/// Provider dos pedidos entregues (derivado)
final pedidosEntreguesProvider = Provider.family<List<Pedido>, String>((ref, userId) {
  return ref.watch(pedidosProvider(userId)).pedidosEntregues;
});

/// Provider dos pedidos cancelados (derivado)
final pedidosCanceladosProvider = Provider.family<List<Pedido>, String>((ref, userId) {
  return ref.watch(pedidosProvider(userId)).pedidosCancelados;
}); 