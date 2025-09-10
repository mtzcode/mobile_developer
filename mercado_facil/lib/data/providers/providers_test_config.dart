import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/user_repository.dart';
import '../repositories/carrinho_repository.dart';
import '../repositories/pedidos_repository.dart';
import '../models/usuario.dart';
import '../models/carrinho_item.dart';
import '../models/pedido.dart';
import '../models/produto.dart';
import 'providers_config.dart';

/// Configuração de providers para testes
/// 
/// Este arquivo fornece mocks e configurações específicas para testes,
/// permitindo testar os providers de forma isolada.

// ===== MOCKS =====

/// Mock do repositório de usuário para testes
class MockUserRepository implements UserRepository {
  Usuario? _mockUser;
  bool _shouldThrowError = false;
  String _errorMessage = 'Erro mock';

  void setMockUser(Usuario user) {
    _mockUser = user;
  }

  void setShouldThrowError(bool shouldThrow, {String message = 'Erro mock'}) {
    _shouldThrowError = shouldThrow;
    _errorMessage = message;
  }

  @override
  Future<Usuario> registrarUsuario({
    required String nome,
    required String email,
    required String whatsapp,
    required String senha,
  }) async {
    if (_shouldThrowError) {
      throw Exception(_errorMessage);
    }
    
    final user = Usuario(
      id: 'mock-user-id',
      nome: nome,
      email: email,
      whatsapp: whatsapp,
      senhaHash: 'mock-hash',
      dataCadastro: DateTime.now(),
      cadastroCompleto: false,
    );
    _mockUser = user;
    return user;
  }

  @override
  Future<Usuario> fazerLogin(String email, String senha) async {
    if (_shouldThrowError) {
      throw Exception(_errorMessage);
    }
    
    if (email == 'test@test.com' && senha == '123456') {
      final user = Usuario(
        id: 'mock-user-id',
        nome: 'Usuário Teste',
        email: email,
        whatsapp: '11999999999',
        senhaHash: 'mock-hash',
        dataCadastro: DateTime.now(),
        cadastroCompleto: true,
      );
      _mockUser = user;
      return user;
    } else {
      throw Exception('Credenciais inválidas');
    }
  }

  @override
  Future<Usuario?> getUsuarioLogado() async {
    if (_shouldThrowError) {
      throw Exception(_errorMessage);
    }
    return _mockUser;
  }

  @override
  Future<void> fazerLogout() async {
    if (_shouldThrowError) {
      throw Exception(_errorMessage);
    }
    _mockUser = null;
  }

  @override
  Future<void> atualizarUsuario(String userId, Map<String, dynamic> dados) async {
    if (_shouldThrowError) {
      throw Exception(_errorMessage);
    }
    
    if (_mockUser != null) {
      _mockUser = _mockUser!.copyWith(
        nome: dados['nome'] ?? _mockUser!.nome,
        email: dados['email'] ?? _mockUser!.email,
        whatsapp: dados['whatsapp'] ?? _mockUser!.whatsapp,
      );
    }
  }

  @override
  Future<Usuario?> getUsuarioPorId(String userId) async {
    if (_shouldThrowError) {
      throw Exception(_errorMessage);
    }
    return _mockUser;
  }

  @override
  Future<void> enviarEmailRecuperacao(String email) async {
    if (_shouldThrowError) {
      throw Exception(_errorMessage);
    }
    // Mock - não faz nada
  }
}

/// Mock do repositório de carrinho para testes
class MockCarrinhoRepository implements CarrinhoRepository {
  List<CarrinhoItem> _mockItens = [];
  bool _shouldThrowError = false;
  String _errorMessage = 'Erro mock';

  void setMockItens(List<CarrinhoItem> itens) {
    _mockItens = List.from(itens);
  }

  void setShouldThrowError(bool shouldThrow, {String message = 'Erro mock'}) {
    _shouldThrowError = shouldThrow;
    _errorMessage = message;
  }

  @override
  Future<List<CarrinhoItem>> carregarCarrinho(String userId) async {
    if (_shouldThrowError) {
      throw Exception(_errorMessage);
    }
    return List.from(_mockItens);
  }

  @override
  Future<void> salvarCarrinho(String userId, List<CarrinhoItem> itens) async {
    if (_shouldThrowError) {
      throw Exception(_errorMessage);
    }
    _mockItens = List.from(itens);
  }

  @override
  Future<void> adicionarProduto(String userId, Produto produto) async {
    if (_shouldThrowError) {
      throw Exception(_errorMessage);
    }
    
    final index = _mockItens.indexWhere((item) => item.produto.id == produto.id);
    if (index >= 0) {
      _mockItens[index].quantidade++;
    } else {
      _mockItens.add(CarrinhoItem(produto: produto));
    }
  }

  @override
  Future<void> removerProduto(String userId, String produtoId) async {
    if (_shouldThrowError) {
      throw Exception(_errorMessage);
    }
    _mockItens.removeWhere((item) => item.produto.id == produtoId);
  }

  @override
  Future<void> alterarQuantidade(String userId, String produtoId, int quantidade) async {
    if (_shouldThrowError) {
      throw Exception(_errorMessage);
    }
    
    final index = _mockItens.indexWhere((item) => item.produto.id == produtoId);
    if (index >= 0) {
      if (quantidade <= 0) {
        _mockItens.removeAt(index);
      } else {
        _mockItens[index].quantidade = quantidade;
      }
    }
  }

  @override
  Future<void> limparCarrinho(String userId) async {
    if (_shouldThrowError) {
      throw Exception(_errorMessage);
    }
    _mockItens.clear();
  }

  @override
  Stream<List<CarrinhoItem>> carrinhoStream(String userId) {
    if (_shouldThrowError) {
      return Stream.error(Exception(_errorMessage));
    }
    return Stream.value(List.from(_mockItens));
  }
}

/// Mock do repositório de pedidos para testes
class MockPedidosRepository implements PedidosRepository {
  List<Pedido> _mockPedidos = [];
  bool _shouldThrowError = false;
  String _errorMessage = 'Erro mock';

  void setMockPedidos(List<Pedido> pedidos) {
    _mockPedidos = List.from(pedidos);
  }

  void setShouldThrowError(bool shouldThrow, {String message = 'Erro mock'}) {
    _shouldThrowError = shouldThrow;
    _errorMessage = message;
  }

  @override
  Future<List<Pedido>> buscarPedidosUsuario(String userId) async {
    if (_shouldThrowError) {
      throw Exception(_errorMessage);
    }
    return List.from(_mockPedidos);
  }

  @override
  Future<String> criarPedido({
    required String usuarioId,
    required List<CarrinhoItem> itens,
    required Map<String, dynamic> enderecoEntrega,
    required String metodoPagamento,
    String? observacoes,
  }) async {
    if (_shouldThrowError) {
      throw Exception(_errorMessage);
    }
    
    final subtotal = itens.fold<double>(0.0, (sum, item) => sum + (item.preco * item.quantidade));
    final taxaEntrega = 5.0; // Taxa fixa para teste
    final total = subtotal + taxaEntrega;
    
    final pedido = Pedido(
      id: 'mock-pedido-${DateTime.now().millisecondsSinceEpoch}',
      usuarioId: usuarioId,
      itens: itens,
      subtotal: subtotal,
      taxaEntrega: taxaEntrega,
      total: total,
      enderecoEntrega: enderecoEntrega,
      metodoPagamento: metodoPagamento,
      observacoes: observacoes,
      status: StatusPedido.pendente,
      dataCriacao: DateTime.now(),
    );
    
    _mockPedidos.add(pedido);
    return pedido.id;
  }

  @override
  Future<Pedido?> buscarPedido(String pedidoId) async {
    if (_shouldThrowError) {
      throw Exception(_errorMessage);
    }
    
    try {
      return _mockPedidos.firstWhere((pedido) => pedido.id == pedidoId);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> cancelarPedido(String pedidoId) async {
    if (_shouldThrowError) {
      throw Exception(_errorMessage);
    }
    
    final index = _mockPedidos.indexWhere((pedido) => pedido.id == pedidoId);
    if (index >= 0) {
      _mockPedidos[index] = _mockPedidos[index].copyWith(status: StatusPedido.cancelado);
    }
  }

  @override
  Future<void> atualizarStatusPedido(String pedidoId, StatusPedido novoStatus) async {
    if (_shouldThrowError) {
      throw Exception(_errorMessage);
    }
    
    final index = _mockPedidos.indexWhere((pedido) => pedido.id == pedidoId);
    if (index >= 0) {
      _mockPedidos[index] = _mockPedidos[index].copyWith(status: novoStatus);
    }
  }

  @override
  Future<void> adicionarCodigoRastreamento(String pedidoId, String codigo) async {
    if (_shouldThrowError) {
      throw Exception(_errorMessage);
    }
    
    final index = _mockPedidos.indexWhere((pedido) => pedido.id == pedidoId);
    if (index >= 0) {
      _mockPedidos[index] = _mockPedidos[index].copyWith(codigoRastreamento: codigo);
    }
  }

  @override
  Future<List<Pedido>> buscarPedidosPorStatus(String userId, StatusPedido status) async {
    if (_shouldThrowError) {
      throw Exception(_errorMessage);
    }
    
    return _mockPedidos.where((pedido) => pedido.status == status).toList();
  }
}

// ===== PROVIDERS DE TESTE =====

/// Provider de teste para UserRepository
final testUserRepositoryProvider = Provider<UserRepository>((ref) {
  return MockUserRepository();
});

/// Provider de teste para CarrinhoRepository
final testCarrinhoRepositoryProvider = Provider<CarrinhoRepository>((ref) {
  return MockCarrinhoRepository();
});

/// Provider de teste para PedidosRepository
final testPedidosRepositoryProvider = Provider<PedidosRepository>((ref) {
  return MockPedidosRepository();
});

// ===== UTILITÁRIOS DE TESTE =====

/// Utilitário para criar dados de teste
class TestDataFactory {
  /// Cria um usuário de teste
  static Usuario createTestUser({
    String id = 'test-user-id',
    String nome = 'Usuário Teste',
    String email = 'test@test.com',
    String whatsapp = '11999999999',
    bool cadastroCompleto = true,
  }) {
    return Usuario(
      id: id,
      nome: nome,
      email: email,
      whatsapp: whatsapp,
      senhaHash: 'mock-hash',
      dataCadastro: DateTime.now(),
      cadastroCompleto: cadastroCompleto,
    );
  }

  /// Cria um produto de teste
  static Produto createTestProduto({
    String id = 'test-produto-id',
    String nome = 'Produto Teste',
    double preco = 10.0,
    String categoria = 'Teste',
  }) {
    return Produto(
      id: id,
      nome: nome,
      preco: preco,
      categoria: categoria,
      imagemUrl: 'https://example.com/image.jpg',
      descricao: 'Descrição do produto teste',
    );
  }

  /// Cria um item de carrinho de teste
  static CarrinhoItem createTestCarrinhoItem({
    Produto? produto,
    int quantidade = 1,
  }) {
    return CarrinhoItem(
      produto: produto ?? createTestProduto(),
      quantidade: quantidade,
    );
  }

  /// Cria um pedido de teste
  static Pedido createTestPedido({
    String id = 'test-pedido-id',
    String usuarioId = 'test-user-id',
    List<CarrinhoItem>? itens,
    StatusPedido status = StatusPedido.pendente,
  }) {
    final itensLista = itens ?? [createTestCarrinhoItem()];
    final subtotal = itensLista.fold<double>(0.0, (sum, item) => sum + (item.preco * item.quantidade));
    final taxaEntrega = 5.0;
    final total = subtotal + taxaEntrega;
    
    return Pedido(
      id: id,
      usuarioId: usuarioId,
      itens: itensLista,
      subtotal: subtotal,
      taxaEntrega: taxaEntrega,
      total: total,
      enderecoEntrega: {
        'rua': 'Rua Teste',
        'numero': '123',
        'bairro': 'Bairro Teste',
        'cidade': 'Cidade Teste',
        'estado': 'SP',
        'cep': '12345-678',
      },
      metodoPagamento: 'Cartão de Crédito',
      status: status,
      dataCriacao: DateTime.now(),
    );
  }
}

/// Utilitário para configurar providers de teste
class TestProviderConfig {
  /// Configura providers com mocks para testes
  static ProviderContainer createTestContainer({
    Usuario? mockUser,
    List<CarrinhoItem>? mockCarrinhoItens,
    List<Pedido>? mockPedidos,
  }) {
    final container = ProviderContainer(
      overrides: [
        userRepositoryProvider.overrideWithValue(
          MockUserRepository()..setMockUser(mockUser ?? TestDataFactory.createTestUser()),
        ),
        carrinhoRepositoryProvider.overrideWithValue(
          MockCarrinhoRepository()..setMockItens(mockCarrinhoItens ?? []),
        ),
        pedidosRepositoryProvider.overrideWithValue(
          MockPedidosRepository()..setMockPedidos(mockPedidos ?? []),
        ),
      ],
    );
    
    return container;
  }

  /// Limpa o container de teste
  static void disposeTestContainer(ProviderContainer container) {
    container.dispose();
  }
}