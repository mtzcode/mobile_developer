import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/carrinho_item.dart';
import '../models/produto.dart';
import '../repositories/carrinho_repository.dart';
import '../../core/utils/logger.dart';

/// Estado do carrinho
class CarrinhoState {
  final List<CarrinhoItem> itens;
  final bool carregado;
  final String? error;

  const CarrinhoState({
    this.itens = const [],
    this.carregado = false,
    this.error,
  });

  double get total => itens.fold(0, (soma, item) => soma + item.subtotal);
  int get quantidadeTotal => itens.fold(0, (soma, item) => soma + item.quantidade);
  bool get isEmpty => itens.isEmpty;

  CarrinhoState copyWith({
    List<CarrinhoItem>? itens,
    bool? carregado,
    String? error,
  }) {
    return CarrinhoState(
      itens: itens ?? this.itens,
      carregado: carregado ?? this.carregado,
      error: error ?? this.error,
    );
  }
}

/// Notifier do carrinho usando Riverpod
class CarrinhoNotifier extends StateNotifier<CarrinhoState> {
  final CarrinhoRepository _carrinhoRepository;
  final String userId;

  CarrinhoNotifier(this._carrinhoRepository, this.userId) : super(const CarrinhoState()) {
    // Carregar carrinho automaticamente quando o notifier é criado
    if (userId.isNotEmpty) {
      AppLogger.cart('Inicializando CarrinhoNotifier para usuário: $userId');
      carregarCarrinho();
    } else {
      AppLogger.cart('CarrinhoNotifier inicializado sem usuário');
      state = state.copyWith(carregado: true);
    }
  }

  /// Carrega o carrinho do repositório
  Future<void> carregarCarrinho() async {
    if (userId.isEmpty) {
      AppLogger.cart('Tentativa de carregar carrinho sem userId');
      state = state.copyWith(itens: [], carregado: true);
      return;
    }
    
    AppLogger.cart('Carregando carrinho do repositório', 'Usuário: $userId');
    
    try {
      final itens = await _carrinhoRepository.carregarCarrinho(userId);
      state = state.copyWith(
        itens: itens,
        carregado: true,
        error: null,
      );
      AppLogger.cart('Carrinho carregado com sucesso', 'Quantidade de itens: ${itens.length}');
    } catch (e, stackTrace) {
      AppLogger.failure('Carregamento de carrinho', 'Erro ao carregar carrinho do repositório', e, stackTrace);
      state = state.copyWith(
        itens: [],
        carregado: true,
        error: e.toString(),
      );
    }
  }

  /// Adiciona produto ao carrinho
  void adicionarProduto(Produto produto) {
    if (userId.isEmpty) {
      AppLogger.cart('Tentativa de adicionar produto sem userId');
      return;
    }
    
    AppLogger.cart('Adicionando produto ao carrinho', 'Produto: ${produto.nome}, Usuário: $userId');
    
    final itens = List<CarrinhoItem>.from(state.itens);
    final index = itens.indexWhere((item) => item.produto.id == produto.id);
    
    if (index >= 0) {
      itens[index].quantidade++;
      AppLogger.cart('Quantidade atualizada', 'Produto: ${produto.nome}, Nova quantidade: ${itens[index].quantidade}');
    } else {
      itens.add(CarrinhoItem(produto: produto));
      AppLogger.cart('Novo produto adicionado', 'Produto: ${produto.nome}');
    }
    
    // Atualizar estado imediatamente
    state = state.copyWith(itens: itens);
    
    // Salvar no repositório em background (sem aguardar)
    _salvarCarrinho(itens);
  }

  /// Remove produto do carrinho
  void removerProduto(Produto produto) {
    if (userId.isEmpty) return;
    
    AppLogger.cart('Removendo produto do carrinho', 'Produto: ${produto.nome}, Usuário: $userId');
    
    final itens = List<CarrinhoItem>.from(state.itens);
    itens.removeWhere((item) => item.produto.id == produto.id);
    
    // Atualizar estado imediatamente
    state = state.copyWith(itens: itens);
    
    // Salvar no repositório em background (sem aguardar)
    _salvarCarrinho(itens);
  }

  /// Altera quantidade de um produto
  void alterarQuantidade(Produto produto, int quantidade) {
    if (userId.isEmpty) return;
    
    AppLogger.cart('Alterando quantidade do produto', 'Produto: ${produto.nome}, Nova quantidade: $quantidade');
    
    final itens = List<CarrinhoItem>.from(state.itens);
    final index = itens.indexWhere((item) => item.produto.id == produto.id);
    
    if (index >= 0) {
      if (quantidade <= 0) {
        itens.removeAt(index);
        AppLogger.cart('Produto removido (quantidade zero)', 'Produto: ${produto.nome}');
      } else {
        itens[index].quantidade = quantidade;
        AppLogger.cart('Quantidade alterada', 'Produto: ${produto.nome}, Quantidade: $quantidade');
      }
      
      // Atualizar estado imediatamente
      state = state.copyWith(itens: itens);
      
      // Salvar no repositório em background (sem aguardar)
      _salvarCarrinho(itens);
    }
  }

  /// Limpa o carrinho
  void limparCarrinho() {
    if (userId.isEmpty) return;
    
    AppLogger.cart('Limpando carrinho', 'Usuário: $userId');
    
    // Atualizar estado imediatamente
    state = state.copyWith(itens: []);
    
    // Salvar no repositório em background (sem aguardar)
    _salvarCarrinho([]);
  }

  /// Salva o carrinho no repositório
  Future<void> _salvarCarrinho(List<CarrinhoItem> itens) async {
    if (userId.isEmpty) {
      AppLogger.cart('Tentativa de salvar carrinho sem userId');
      return;
    }
    
    try {
      await _carrinhoRepository.salvarCarrinho(userId, itens);
      AppLogger.cart('Carrinho salvo no repositório', 'Usuário: $userId, Itens: ${itens.length}');
    } catch (e, stackTrace) {
      AppLogger.failure('Salvamento de carrinho', 'Erro ao salvar carrinho no repositório', e, stackTrace);
    }
  }

  /// Limpa erro
  void limparErro() {
    state = state.copyWith(error: null);
  }
}

/// Provider do repositório de carrinho
final carrinhoRepositoryProvider = Provider<CarrinhoRepository>((ref) {
  // Aqui você injetaria a implementação correta
  // Por enquanto, vamos usar uma implementação mock ou Firestore
  throw UnimplementedError('Implementar injeção do CarrinhoRepository');
});

/// Provider do notifier de carrinho
final carrinhoProvider = StateNotifierProvider.family<CarrinhoNotifier, CarrinhoState, String>((ref, userId) {
  final repository = ref.watch(carrinhoRepositoryProvider);
  return CarrinhoNotifier(repository, userId);
});

/// Provider dos itens do carrinho (derivado)
final carrinhoItensProvider = Provider.family<List<CarrinhoItem>, String>((ref, userId) {
  return ref.watch(carrinhoProvider(userId)).itens;
});

/// Provider do total do carrinho (derivado)
final carrinhoTotalProvider = Provider.family<double, String>((ref, userId) {
  return ref.watch(carrinhoProvider(userId)).total;
});

/// Provider da quantidade total do carrinho (derivado)
final carrinhoQuantidadeTotalProvider = Provider.family<int, String>((ref, userId) {
  return ref.watch(carrinhoProvider(userId)).quantidadeTotal;
});

/// Provider do status de carregamento do carrinho (derivado)
final carrinhoCarregadoProvider = Provider.family<bool, String>((ref, userId) {
  return ref.watch(carrinhoProvider(userId)).carregado;
}); 