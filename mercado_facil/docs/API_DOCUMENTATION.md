# 📚 Documentação da API - Mercado Fácil

## 📋 Índice

- [Visão Geral](#visão-geral)
- [Autenticação](#autenticação)
- [Modelos de Dados](#modelos-de-dados)
- [Serviços](#serviços)
- [Providers](#providers)
- [Utilitários](#utilitários)
- [Exemplos de Uso](#exemplos-de-uso)

## 🎯 Visão Geral

A API do Mercado Fácil é baseada em serviços locais que se comunicam com o Firebase. Todos os serviços seguem um padrão consistente de retorno e tratamento de erros.

### Estrutura Base

```dart
// Padrão de retorno dos serviços
Future<Result<T>> serviceMethod(Parameters params);

// Result é um tipo que pode ser Success ou Error
sealed class Result<T> {
  const Result();
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

class Error<T> extends Result<T> {
  final String message;
  final Exception? exception;
  const Error(this.message, [this.exception]);
}
```

## 🔐 Autenticação

### AuthService

Serviço responsável por gerenciar autenticação de usuários.

#### Métodos

```dart
class AuthService {
  /// Realiza login do usuário
  ///
  /// [email] - Email do usuário
  /// [password] - Senha do usuário
  ///
  /// Retorna [User] em caso de sucesso ou [AuthException] em caso de erro
  Future<User> login(String email, String password);

  /// Registra novo usuário
  ///
  /// [name] - Nome completo do usuário
  /// [email] - Email do usuário
  /// [password] - Senha do usuário
  ///
  /// Retorna [User] em caso de sucesso ou [AuthException] em caso de erro
  Future<User> register(String name, String email, String password);

  /// Recupera senha do usuário
  ///
  /// [email] - Email do usuário
  ///
  /// Retorna void em caso de sucesso ou [AuthException] em caso de erro
  Future<void> resetPassword(String email);

  /// Faz logout do usuário atual
  ///
  /// Retorna void em caso de sucesso
  Future<void> logout();

  /// Obtém usuário atual
  ///
  /// Retorna [User?] (null se não autenticado)
  User? getCurrentUser();

  /// Stream de mudanças de autenticação
  ///
  /// Retorna [Stream<User?>] que emite mudanças no estado de autenticação
  Stream<User?> get authStateChanges;
}
```

#### Exemplo de Uso

```dart
final authService = AuthService();

try {
  // Login
  final user = await authService.login('user@example.com', 'password123');
  print('Usuário logado: ${user.name}');

  // Registro
  final newUser = await authService.register('João Silva', 'joao@example.com', 'senha123');
  print('Usuário registrado: ${newUser.id}');

  // Recuperar senha
  await authService.resetPassword('user@example.com');
  print('Email de recuperação enviado');

} catch (e) {
  print('Erro de autenticação: $e');
}
```

## 📊 Modelos de Dados

### Produto

```dart
class Produto {
  final String id;
  final String nome;
  final double preco;
  final String? descricao;
  final String categoria;
  final String imagemUrl;
  final String? destaque;
  final double? precoPromocional;
  final bool favorito;
  final DateTime dataCriacao;
  final DateTime dataAtualizacao;

  const Produto({
    required this.id,
    required this.nome,
    required this.preco,
    this.descricao,
    required this.categoria,
    required this.imagemUrl,
    this.destaque,
    this.precoPromocional,
    this.favorito = false,
    required this.dataCriacao,
    required this.dataAtualizacao,
  });

  /// Converte para Map (Firestore)
  Map<String, dynamic> toMap();

  /// Cria instância a partir de Map (Firestore)
  factory Produto.fromMap(Map<String, dynamic> map, String id);

  /// Cria cópia com modificações
  Produto copyWith({...});

  /// Verifica se produto está em promoção
  bool get isPromocao => precoPromocional != null;

  /// Obtém preço atual (promocional ou normal)
  double get precoAtual => precoPromocional ?? preco;
}
```

### Usuario

```dart
class Usuario {
  final String id;
  final String nome;
  final String email;
  final String whatsapp;
  final String? fotoUrl;
  final List<Endereco> enderecos;
  final DateTime dataCriacao;
  final DateTime dataAtualizacao;

  const Usuario({
    required this.id,
    required this.nome,
    required this.email,
    required this.whatsapp,
    this.fotoUrl,
    this.enderecos = const [],
    required this.dataCriacao,
    required this.dataAtualizacao,
  });

  /// Converte para Map (Firestore)
  Map<String, dynamic> toMap();

  /// Cria instância a partir de Map (Firestore)
  factory Usuario.fromMap(Map<String, dynamic> map, String id);

  /// Cria cópia com modificações
  Usuario copyWith({...});

  /// Obtém endereço principal
  Endereco? get enderecoPrincipal =>
    enderecos.isNotEmpty ? enderecos.first : null;
}
```

### Pedido

```dart
class Pedido {
  final String id;
  final String usuarioId;
  final List<PedidoItem> itens;
  final double total;
  final StatusPedido status;
  final Endereco enderecoEntrega;
  final DateTime dataCriacao;
  final DateTime? dataEntrega;

  const Pedido({
    required this.id,
    required this.usuarioId,
    required this.itens,
    required this.total,
    required this.status,
    required this.enderecoEntrega,
    required this.dataCriacao,
    this.dataEntrega,
  });

  /// Converte para Map (Firestore)
  Map<String, dynamic> toMap();

  /// Cria instância a partir de Map (Firestore)
  factory Pedido.fromMap(Map<String, dynamic> map, String id);

  /// Verifica se pedido está finalizado
  bool get isFinalizado => status == StatusPedido.entregue;

  /// Obtém cor do status
  Color get statusColor => status.color;

  /// Obtém ícone do status
  IconData get statusIcon => status.icon;
}

enum StatusPedido {
  pendente,
  confirmado,
  preparando,
  enviado,
  entregue,
  cancelado;

  Color get color;
  IconData get icon;
  String get label;
}
```

## 🔧 Serviços

### ProdutosService

```dart
class ProdutosService {
  /// Obtém lista de produtos com cache inteligente
  ///
  /// [categoria] - Filtrar por categoria (opcional)
  /// [destaque] - Filtrar por destaque (opcional)
  /// [forcarAtualizacao] - Ignorar cache (padrão: false)
  ///
  /// Retorna [List<Produto>] ou lança [ProdutosException]
  Future<List<Produto>> getProdutos({
    String? categoria,
    String? destaque,
    bool forcarAtualizacao = false,
  });

  /// Busca produtos por termo
  ///
  /// [query] - Termo de busca
  ///
  /// Retorna [List<Produto>] ou lança [ProdutosException]
  Future<List<Produto>> buscarProdutos(String query);

  /// Obtém produto por ID
  ///
  /// [id] - ID do produto
  ///
  /// Retorna [Produto] ou lança [ProdutosException]
  Future<Produto> getProdutoPorId(String id);

  /// Adiciona/remove produto dos favoritos
  ///
  /// [produtoId] - ID do produto
  /// [favorito] - Status de favorito
  ///
  /// Retorna void ou lança [ProdutosException]
  Future<void> toggleFavorito(String produtoId, bool favorito);

  /// Obtém produtos favoritos do usuário
  ///
  /// Retorna [List<Produto>] ou lança [ProdutosException]
  Future<List<Produto>> getFavoritos();
}
```

### PedidosService

```dart
class PedidosService {
  /// Cria novo pedido
  ///
  /// [carrinho] - Carrinho com itens
  /// [enderecoEntrega] - Endereço de entrega
  ///
  /// Retorna [Pedido] ou lança [PedidosException]
  Future<Pedido> criarPedido(Carrinho carrinho, Endereco enderecoEntrega);

  /// Obtém pedidos do usuário
  ///
  /// [usuarioId] - ID do usuário
  ///
  /// Retorna [List<Pedido>] ou lança [PedidosException]
  Future<List<Pedido>> getPedidosUsuario(String usuarioId);

  /// Obtém pedido por ID
  ///
  /// [pedidoId] - ID do pedido
  ///
  /// Retorna [Pedido] ou lança [PedidosException]
  Future<Pedido> getPedidoPorId(String pedidoId);

  /// Atualiza status do pedido
  ///
  /// [pedidoId] - ID do pedido
  /// [novoStatus] - Novo status
  ///
  /// Retorna void ou lança [PedidosException]
  Future<void> atualizarStatus(String pedidoId, StatusPedido novoStatus);

  /// Cancela pedido
  ///
  /// [pedidoId] - ID do pedido
  /// [motivo] - Motivo do cancelamento
  ///
  /// Retorna void ou lança [PedidosException]
  Future<void> cancelarPedido(String pedidoId, String motivo);
}
```

## 🎛️ Providers

### CarrinhoProvider

```dart
class CarrinhoProvider extends ChangeNotifier {
  final String userId;

  /// Lista de itens no carrinho
  List<CarrinhoItem> get itens => _itens;

  /// Total de itens no carrinho
  int get totalItens => _itens.fold(0, (sum, item) => sum + item.quantidade);

  /// Valor total do carrinho
  double get total => _itens.fold(0.0, (sum, item) => sum + item.subtotal);

  /// Verifica se carrinho está vazio
  bool get isEmpty => _itens.isEmpty;

  /// Adiciona produto ao carrinho
  ///
  /// [produto] - Produto a ser adicionado
  /// [quantidade] - Quantidade (padrão: 1)
  void adicionarProduto(Produto produto, {int quantidade = 1});

  /// Remove produto do carrinho
  ///
  /// [produtoId] - ID do produto
  void removerProduto(String produtoId);

  /// Atualiza quantidade de produto
  ///
  /// [produtoId] - ID do produto
  /// [quantidade] - Nova quantidade
  void atualizarQuantidade(String produtoId, int quantidade);

  /// Limpa carrinho
  void limparCarrinho();

  /// Obtém item do carrinho
  ///
  /// [produtoId] - ID do produto
  ///
  /// Retorna [CarrinhoItem?] ou null se não encontrado
  CarrinhoItem? getItem(String produtoId);
}
```

### UserProvider

```dart
class UserProvider extends ChangeNotifier {
  /// Usuário logado atual
  Usuario? get usuarioLogado => _usuario;

  /// Verifica se está carregando
  bool get isLoading => _isLoading;

  /// Carrega dados do usuário logado
  ///
  /// Retorna void ou lança [UserException]
  Future<void> carregarUsuarioLogado();

  /// Atualiza dados do usuário
  ///
  /// [dados] - Map com dados a serem atualizados
  ///
  /// Retorna void ou lança [UserException]
  Future<void> atualizarDadosUsuario(Map<String, dynamic> dados);

  /// Adiciona endereço ao usuário
  ///
  /// [endereco] - Endereço a ser adicionado
  ///
  /// Retorna void ou lança [UserException]
  Future<void> adicionarEndereco(Endereco endereco);

  /// Remove endereço do usuário
  ///
  /// [enderecoId] - ID do endereço
  ///
  /// Retorna void ou lança [UserException]
  Future<void> removerEndereco(String enderecoId);

  /// Atualiza foto do usuário
  ///
  /// [fotoFile] - Arquivo da foto
  ///
  /// Retorna void ou lança [UserException]
  Future<void> atualizarFoto(File fotoFile);
}
```

## 🛠️ Utilitários

### Validators

```dart
class Validators {
  /// Valida e-mail
  ///
  /// [value] - Email a ser validado
  ///
  /// Retorna String? (null se válido, mensagem de erro se inválido)
  static String? email(String? value);

  /// Valida senha forte
  ///
  /// [value] - Senha a ser validada
  ///
  /// Retorna String? (null se válida, mensagem de erro se inválida)
  static String? senha(String? value);

  /// Valida CPF
  ///
  /// [value] - CPF a ser validado
  ///
  /// Retorna String? (null se válido, mensagem de erro se inválido)
  static String? cpf(String? value);

  /// Valida telefone brasileiro
  ///
  /// [value] - Telefone a ser validado
  ///
  /// Retorna String? (null se válido, mensagem de erro se inválido)
  static String? telefone(String? value);

  /// Valida CEP brasileiro
  ///
  /// [value] - CEP a ser validado
  ///
  /// Retorna String? (null se válido, mensagem de erro se inválido)
  static String? cep(String? value);
}
```

### AppLogger

```dart
class AppLogger {
  /// Log de debug
  static void debug(String message, [Object? error, StackTrace? stackTrace]);

  /// Log de informação
  static void info(String message, [Object? error, StackTrace? stackTrace]);

  /// Log de warning
  static void warning(String message, [Object? error, StackTrace? stackTrace]);

  /// Log de erro
  static void error(String message, [Object? error, StackTrace? stackTrace]);

  /// Log específico para autenticação
  static void auth(String message, [Object? error, StackTrace? stackTrace]);

  /// Log específico para UI
  static void ui(String message, [Object? error, StackTrace? stackTrace]);

  /// Log específico para serviços
  static void service(String message, [Object? error, StackTrace? stackTrace]);
}
```

## 💡 Exemplos de Uso

### Fluxo Completo de Compra

```dart
// 1. Autenticação
final authService = AuthService();
final user = await authService.login('user@example.com', 'password123');

// 2. Carregar produtos
final produtosService = ProdutosService();
final produtos = await produtosService.getProdutos(categoria: 'Frutas');

// 3. Adicionar ao carrinho
final carrinhoProvider = CarrinhoProvider(userId: user.id);
carrinhoProvider.adicionarProduto(produtos.first, quantidade: 2);

// 4. Finalizar compra
final pedidosService = PedidosService();
final pedido = await pedidosService.criarPedido(
  carrinhoProvider.carrinho,
  user.enderecoPrincipal!,
);

// 5. Limpar carrinho
carrinhoProvider.limparCarrinho();

print('Pedido criado: ${pedido.id}');
```

### Gerenciamento de Favoritos

```dart
// Adicionar aos favoritos
await produtosService.toggleFavorito('produto123', true);

// Obter favoritos
final favoritos = await produtosService.getFavoritos();

// Remover dos favoritos
await produtosService.toggleFavorito('produto123', false);
```

### Atualização de Perfil

```dart
final userProvider = UserProvider();

// Atualizar dados básicos
await userProvider.atualizarDadosUsuario({
  'nome': 'João Silva',
  'whatsapp': '(11) 99999-9999',
});

// Adicionar endereço
final novoEndereco = Endereco(
  id: 'end1',
  rua: 'Rua das Flores',
  numero: '123',
  bairro: 'Centro',
  cidade: 'São Paulo',
  uf: 'SP',
  cep: '01234-567',
);

await userProvider.adicionarEndereco(novoEndereco);

// Atualizar foto
final fotoFile = File('path/to/photo.jpg');
await userProvider.atualizarFoto(fotoFile);
```

### Tratamento de Erros

```dart
try {
  final produtos = await produtosService.getProdutos();
  // Processar produtos
} on ProdutosException catch (e) {
  AppLogger.error('Erro ao carregar produtos: ${e.message}');
  // Mostrar mensagem de erro para o usuário
} catch (e) {
  AppLogger.error('Erro inesperado: $e');
  // Tratar erro genérico
}
```

## 📝 Notas Importantes

1. **Cache Inteligente**: O `ProdutosService` implementa cache em múltiplas camadas (memória, local, remoto)
2. **Tratamento de Erros**: Todos os serviços lançam exceções específicas para facilitar o tratamento
3. **Logs Estruturados**: Use `AppLogger` para logs consistentes e organizados
4. **Validação**: Sempre valide dados de entrada usando `Validators`
5. **Performance**: Use `ChangeNotifier` apenas quando necessário para evitar rebuilds desnecessários

---

**Para mais informações, consulte a documentação completa do projeto.**
