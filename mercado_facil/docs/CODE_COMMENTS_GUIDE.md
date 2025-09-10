# 📝 Guia de Comentários no Código - Mercado Fácil

Este documento estabelece padrões e diretrizes para comentários no código do projeto Mercado Fácil.

## 📋 Índice

- [Tipos de Comentários](#tipos-de-comentários)
- [Padrões de Documentação](#padrões-de-documentação)
- [Exemplos Práticos](#exemplos-práticos)
- [Boas Práticas](#boas-práticas)
- [Ferramentas de Documentação](#ferramentas-de-documentação)

## 🏷️ Tipos de Comentários

### 1. Documentação de API (///)

````dart
/// Serviço responsável por gerenciar autenticação de usuários.
///
/// Este serviço fornece métodos para login, registro, logout e
/// gerenciamento do estado de autenticação do usuário.
///
/// Exemplo de uso:
/// ```dart
/// final authService = AuthService();
/// final user = await authService.login('user@example.com', 'password123');
/// ```
class AuthService {
  // Implementação...
}
````

### 2. Comentários de Linha (//)

```dart
// Verifica se o usuário está autenticado
if (currentUser != null) {
  // Redireciona para tela principal
  Navigator.pushReplacementNamed(context, '/home');
} else {
  // Redireciona para login
  Navigator.pushReplacementNamed(context, '/login');
}
```

### 3. Comentários de Bloco (/\* \*/)

```dart
/*
 * Este bloco de código implementa a lógica de cache inteligente
 * que tenta carregar dados em ordem de prioridade:
 * 1. Cache local (SharedPreferences)
 * 2. Cache em memória
 * 3. Firestore
 * 4. Dados mock
 */
```

## 📚 Padrões de Documentação

### Documentação de Classes

````dart
/// Widget que exibe um card de produto com informações básicas.
///
/// Este widget é responsável por renderizar as informações de um produto
/// de forma consistente em toda a aplicação, incluindo imagem, nome,
/// preço e botões de ação.
///
/// Características:
/// - Design responsivo
/// - Suporte a promoções
/// - Indicador de favoritos
/// - Animações suaves
///
/// Exemplo de uso:
/// ```dart
/// ProdutoCard(
///   produto: produto,
///   onAdicionarAoCarrinho: () => adicionarAoCarrinho(produto),
///   onToggleFavorito: () => toggleFavorito(produto.id),
/// )
/// ```
class ProdutoCard extends StatelessWidget {
  // Implementação...
}
````

### Documentação de Métodos

````dart
/// Realiza login do usuário com email e senha.
///
/// Este método autentica o usuário no Firebase Authentication
/// e retorna os dados do usuário em caso de sucesso.
///
/// [email] - Email do usuário (deve ser válido)
/// [password] - Senha do usuário (mínimo 6 caracteres)
///
/// Retorna [User] em caso de sucesso.
///
/// Lança [AuthException] se as credenciais forem inválidas
/// ou se houver erro de conexão.
///
/// Exemplo:
/// ```dart
/// try {
///   final user = await login('user@example.com', 'password123');
///   print('Usuário logado: ${user.name}');
/// } catch (e) {
///   print('Erro de login: $e');
/// }
/// ```
Future<User> login(String email, String password) async {
  // Implementação...
}
````

### Documentação de Parâmetros

```dart
/// Widget que exibe uma lista de produtos com paginação.
///
/// [produtos] - Lista de produtos a serem exibidos
/// [onProdutoTap] - Callback chamado quando um produto é tocado
/// [onAdicionarAoCarrinho] - Callback para adicionar produto ao carrinho
/// [onToggleFavorito] - Callback para favoritar/desfavoritar produto
/// [isLoading] - Indica se está carregando mais produtos
/// [hasMore] - Indica se há mais produtos para carregar
/// [onLoadMore] - Callback para carregar mais produtos
class ProdutosList extends StatelessWidget {
  final List<Produto> produtos;
  final Function(Produto)? onProdutoTap;
  final Function(Produto)? onAdicionarAoCarrinho;
  final Function(String)? onToggleFavorito;
  final bool isLoading;
  final bool hasMore;
  final VoidCallback? onLoadMore;

  // Implementação...
}
```

### Documentação de Propriedades

```dart
class Produto {
  /// Identificador único do produto no sistema
  final String id;

  /// Nome do produto para exibição
  final String nome;

  /// Preço original do produto em reais
  final double preco;

  /// URL da imagem do produto
  final String imagemUrl;

  /// Descrição detalhada do produto (opcional)
  final String? descricao;

  /// Categoria do produto (ex: 'Frutas', 'Laticínios')
  final String? categoria;

  /// Destaque do produto ('mais vendido', 'novo', 'oferta' ou null)
  final String? destaque;

  /// Preço promocional do produto (opcional)
  final double? precoPromocional;

  /// Indica se o produto está nos favoritos do usuário atual
  bool favorito;
}
```

## 💡 Exemplos Práticos

### Modelo de Dados

```dart
/// Modelo que representa um produto no sistema.
///
/// Esta classe encapsula todas as informações de um produto,
/// incluindo dados básicos, preços, imagens e status de favorito.
/// É utilizada em toda a aplicação para exibição e manipulação de produtos.
class Produto {
  /// Identificador único do produto
  final String id;

  /// Nome do produto
  final String nome;

  /// Preço original do produto
  final double preco;

  /// URL da imagem do produto
  final String imagemUrl;

  /// Descrição detalhada do produto (opcional)
  final String? descricao;

  /// Categoria do produto (ex: 'Frutas', 'Laticínios')
  final String? categoria;

  /// Destaque do produto ('mais vendido', 'novo', 'oferta' ou null)
  final String? destaque;

  /// Preço promocional do produto (opcional)
  final double? precoPromocional;

  /// Indica se o produto está nos favoritos do usuário
  bool favorito;

  /// Construtor do Produto
  ///
  /// [id] - Identificador único obrigatório
  /// [nome] - Nome do produto obrigatório
  /// [preco] - Preço original obrigatório
  /// [imagemUrl] - URL da imagem obrigatória
  /// [descricao] - Descrição opcional
  /// [categoria] - Categoria opcional
  /// [destaque] - Destaque opcional
  /// [precoPromocional] - Preço promocional opcional
  /// [favorito] - Status de favorito (padrão: false)
  Produto({
    required this.id,
    required this.nome,
    required this.preco,
    required this.imagemUrl,
    this.descricao,
    this.categoria,
    this.destaque,
    this.precoPromocional,
    bool? favorito,
  }) : favorito = favorito ?? false;

  /// Cria uma cópia do produto com campos modificados.
  ///
  /// Este método é útil para criar variações do produto sem modificar
  /// a instância original, mantendo a imutabilidade.
  ///
  /// [id] - Novo ID (opcional)
  /// [nome] - Novo nome (opcional)
  /// [preco] - Novo preço (opcional)
  /// [imagemUrl] - Nova URL de imagem (opcional)
  /// [descricao] - Nova descrição (opcional)
  /// [categoria] - Nova categoria (opcional)
  /// [destaque] - Novo destaque (opcional)
  /// [precoPromocional] - Novo preço promocional (opcional)
  /// [favorito] - Novo status de favorito (opcional)
  ///
  /// Retorna uma nova instância de [Produto] com os campos modificados.
  Produto copyWith({
    String? id,
    String? nome,
    double? preco,
    String? imagemUrl,
    String? descricao,
    String? categoria,
    String? destaque,
    double? precoPromocional,
    bool? favorito,
  }) {
    return Produto(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      preco: preco ?? this.preco,
      imagemUrl: imagemUrl ?? this.imagemUrl,
      descricao: descricao ?? this.descricao,
      categoria: categoria ?? this.categoria,
      destaque: destaque ?? this.destaque,
      precoPromocional: precoPromocional ?? this.precoPromocional,
      favorito: favorito ?? this.favorito,
    );
  }

  /// Converte o produto para um Map para persistência no Firestore.
  ///
  /// Este método serializa todos os campos do produto em um formato
  /// compatível com o Firestore, incluindo conversões de tipos necessárias.
  ///
  /// Retorna um [Map<String, dynamic>] com todos os dados do produto.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'preco': preco,
      'imagemUrl': imagemUrl,
      'descricao': descricao,
      'categoria': categoria,
      'destaque': destaque,
      'precoPromocional': precoPromocional,
      'favorito': favorito,
    };
  }

  /// Cria um produto a partir de um Map do Firestore.
  ///
  /// Este factory method deserializa os dados do Firestore e cria
  /// uma instância válida de Produto, tratando valores nulos e
  /// convertendo tipos conforme necessário.
  ///
  /// [map] - Map contendo os dados do produto
  ///
  /// Retorna uma nova instância de [Produto].
  factory Produto.fromMap(Map<String, dynamic> map) {
    return Produto(
      id: map['id'] ?? '',
      nome: map['nome'] ?? '',
      preco: (map['preco'] ?? 0.0).toDouble(),
      imagemUrl: map['imagemUrl'] ?? '',
      descricao: map['descricao'],
      categoria: map['categoria'],
      destaque: map['destaque'],
      precoPromocional: map['precoPromocional'] != null
          ? (map['precoPromocional'] as num).toDouble()
          : null,
      favorito: map['favorito'] ?? false,
    );
  }

  /// Verifica se o produto está em promoção.
  ///
  /// Um produto está em promoção quando possui um preço promocional
  /// definido e diferente do preço original.
  ///
  /// Retorna [true] se o produto está em promoção, [false] caso contrário.
  bool get isPromocao => precoPromocional != null && precoPromocional! < preco;

  /// Obtém o preço atual do produto.
  ///
  /// Se o produto está em promoção, retorna o preço promocional.
  /// Caso contrário, retorna o preço original.
  ///
  /// Retorna o preço atual como [double].
  double get precoAtual => precoPromocional ?? preco;

  /// Calcula o percentual de desconto da promoção.
  ///
  /// Retorna o percentual de desconto como [double] ou 0.0 se não há promoção.
  double get percentualDesconto {
    if (!isPromocao) return 0.0;
    return ((preco - precoPromocional!) / preco * 100).roundToDouble();
  }

  /// Verifica se o produto possui destaque.
  ///
  /// Retorna [true] se o produto tem algum tipo de destaque, [false] caso contrário.
  bool get hasDestaque => destaque != null && destaque!.isNotEmpty;

  @override
  String toString() {
    return 'Produto(id: $id, nome: $nome, preco: $preco, categoria: $categoria)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Produto && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
```

### Serviço

```dart
/// Serviço responsável por gerenciar produtos com estratégia de cache inteligente.
///
/// Este serviço implementa uma estratégia de cache em múltiplas camadas:
/// 1. Cache local (SharedPreferences) - persistente
/// 2. Cache em memória - rápido acesso
/// 3. Firestore - fonte de dados principal
/// 4. Dados mock - fallback final
///
/// A estratégia garante que o app funcione mesmo offline e tenha
/// performance otimizada com dados sempre atualizados quando possível.
class ProdutosService {
  /// Instância do serviço Firestore para operações de banco de dados
  static final FirestoreService _firestoreService = FirestoreService();

  /// Retorna uma lista de produtos mock para uso como fallback.
  ///
  /// Estes dados são utilizados quando todas as outras fontes falham,
  /// garantindo que o app sempre tenha produtos para exibir.
  ///
  /// Retorna [List<Produto>] com dados de exemplo.
  static List<Produto> getProdutosMock() {
    return [
      Produto(
        id: '1',
        nome: 'Arroz Integral',
        preco: 8.50,
        imagemUrl: 'https://picsum.photos/150/150?random=1',
        categoria: 'Grãos',
        destaque: 'oferta',
        precoPromocional: 6.99,
        favorito: false,
      ),
      // ... outros produtos
    ];
  }

  /// Carrega produtos com estratégia de cache inteligente.
  ///
  /// Implementa uma estratégia de fallback em cascata:
  /// 1. Tenta cache local (se válido e não forçar atualização)
  /// 2. Tenta cache em memória (se válido)
  /// 3. Carrega do Firestore (fonte principal)
  /// 4. Salva no cache local e memória
  /// 5. Fallback para cache local (mesmo expirado)
  /// 6. Fallback para cache em memória
  /// 7. Fallback para dados mock
  ///
  /// [forcarAtualizacao] - Se true, ignora cache e força atualização do Firestore
  ///
  /// Retorna [List<Produto>] com os produtos carregados.
  ///
  /// Lança [Exception] apenas se todos os fallbacks falharem.
  static Future<List<Produto>> carregarProdutosComCache({bool forcarAtualizacao = false}) async {
    try {
      // Se não forçar atualização, tenta carregar do cache primeiro
      if (!forcarAtualizacao) {
        // Tenta cache local (shared_preferences)
        try {
          final temCache = await CacheService.temCache();
          final cacheValido = await CacheService.isCacheValido();

          if (temCache && cacheValido) {
            final produtosCache = await CacheService.carregarProdutos();
            if (produtosCache.isNotEmpty) {
              return produtosCache;
            }
          }
        } catch (cacheError) {
          // Erro silencioso ao acessar cache local
        }

        // Tenta cache em memória como fallback
        if (MemoryCacheService.temCache() && MemoryCacheService.isCacheValido()) {
          final produtosCache = MemoryCacheService.carregarProdutos();
          if (produtosCache.isNotEmpty) {
            return produtosCache;
          }
        }
      }

      // Se não tem cache válido ou forçou atualização, carrega do Firestore
      final produtos = await _carregarProdutosDoFirestore();

      // Salva no cache local (tenta, mas não falha se der erro)
      if (produtos.isNotEmpty) {
        try {
          await CacheService.salvarProdutos(produtos);
        } catch (cacheError) {
          // Erro silencioso ao salvar no cache local
        }

        // Sempre salva no cache em memória como backup
        MemoryCacheService.salvarProdutos(produtos);
      }

      return produtos;
    } catch (e) {
      // Fallback para cache local mesmo que expirado
      try {
        final produtosCache = await CacheService.carregarProdutos();
        if (produtosCache.isNotEmpty) {
          return produtosCache;
        }
      } catch (cacheError) {
        // Erro silencioso ao carregar cache local como fallback
      }

      // Fallback para cache em memória
      if (MemoryCacheService.temCache()) {
        final produtosCache = MemoryCacheService.carregarProdutos();
        if (produtosCache.isNotEmpty) {
          return produtosCache;
        }
      }

      // Último fallback: dados mock
      return getProdutosMock();
    }
  }

  /// Carrega produtos diretamente do Firestore.
  ///
  /// Método privado que encapsula a lógica de carregamento do Firestore.
  /// Se o Firestore não retornar dados, usa dados mock como fallback.
  ///
  /// Retorna [List<Produto>] do Firestore ou dados mock.
  ///
  /// Lança [Exception] se houver erro na comunicação com Firestore.
  static Future<List<Produto>> _carregarProdutosDoFirestore() async {
    try {
      final produtosData = await _firestoreService.getProdutos();

      if (produtosData.isEmpty) {
        return getProdutosMock();
      }

      return produtosData;
    } catch (e) {
      throw e;
    }
  }
}
```

### Widget

````dart
/// Widget que exibe um card de produto com informações básicas e ações.
///
/// Este widget é responsável por renderizar as informações de um produto
/// de forma consistente em toda a aplicação, incluindo imagem, nome,
/// preço e botões de ação.
///
/// Características:
/// - Design responsivo
/// - Suporte a promoções
/// - Indicador de favoritos
/// - Animações suaves
/// - Acessibilidade
///
/// Exemplo de uso:
/// ```dart
/// ProdutoCard(
///   produto: produto,
///   onAdicionarAoCarrinho: () => adicionarAoCarrinho(produto),
///   onToggleFavorito: () => toggleFavorito(produto.id),
/// )
/// ```
class ProdutoCard extends StatelessWidget {
  /// Constantes para dimensões do card
  static const double _cardHeight = 280.0;
  static const double _imageHeight = 120.0;
  static const double _borderRadius = 12.0;
  static const double _padding = 12.0;

  /// Produto a ser exibido
  final Produto produto;

  /// Callback chamado ao adicionar produto ao carrinho
  final VoidCallback? onAdicionarAoCarrinho;

  /// Callback chamado ao favoritar/desfavoritar produto
  final VoidCallback? onToggleFavorito;

  /// Construtor do ProdutoCard
  ///
  /// [produto] - Produto a ser exibido (obrigatório)
  /// [onAdicionarAoCarrinho] - Callback para adicionar ao carrinho (opcional)
  /// [onToggleFavorito] - Callback para favoritar/desfavoritar (opcional)
  const ProdutoCard({
    super.key,
    required this.produto,
    this.onAdicionarAoCarrinho,
    this.onToggleFavorito,
  });

  /// Exibe modal com detalhes do produto
  ///
  /// [context] - Contexto do widget
  void _showProductModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProdutoDetalhesModal(produto: produto),
    );
  }

  /// Formata preço para exibição
  ///
  /// [preco] - Preço a ser formatado
  ///
  /// Retorna string formatada do preço
  String _formatarPreco(double preco) {
    return 'R\$ ${preco.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showProductModal(context),
      child: Container(
        height: _cardHeight,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(_borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagem do produto
            _buildProductImage(),

            // Informações do produto
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(_padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nome do produto
                    _buildProductName(),

                    // Preço
                    _buildProductPrice(),

                    // Botões de ação
                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Constrói a imagem do produto
  Widget _buildProductImage() {
    return Stack(
      children: [
        // Imagem principal
        ClipRRect(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(_borderRadius),
          ),
          child: CachedNetworkImage(
            imageUrl: produto.imagemUrl,
            height: _imageHeight,
            width: double.infinity,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              height: _imageHeight,
              color: Colors.grey[200],
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              height: _imageHeight,
              color: Colors.grey[200],
              child: const Icon(Icons.error),
            ),
          ),
        ),

        // Tag de destaque
        if (produto.hasDestaque) _buildHighlightTag(),

        // Botão de favorito
        Positioned(
          top: 8,
          right: 8,
          child: _buildFavoriteButton(),
        ),
      ],
    );
  }

  /// Constrói a tag de destaque
  Widget _buildHighlightTag() {
    Color tagColor;
    String tagText;

    switch (produto.destaque) {
      case 'mais vendido':
        tagColor = Colors.orange;
        tagText = 'Mais Vendido';
        break;
      case 'novo':
        tagColor = Colors.green;
        tagText = 'Novo';
        break;
      case 'oferta':
        tagColor = Colors.red;
        tagText = 'Oferta';
        break;
      default:
        return const SizedBox.shrink();
    }

    return Positioned(
      top: 8,
      left: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: tagColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          tagText,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// Constrói o botão de favorito
  Widget _buildFavoriteButton() {
    return GestureDetector(
      onTap: onToggleFavorito,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
        ),
        child: Icon(
          produto.favorito ? Icons.favorite : Icons.favorite_border,
          color: produto.favorito ? Colors.red : Colors.grey,
          size: 20,
        ),
      ),
    );
  }

  /// Constrói o nome do produto
  Widget _buildProductName() {
    return Text(
      produto.nome,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Constrói o preço do produto
  Widget _buildProductPrice() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (produto.isPromocao) ...[
          // Preço original riscado
          Text(
            _formatarPreco(produto.preco),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              decoration: TextDecoration.lineThrough,
            ),
          ),
          const SizedBox(height: 2),
        ],

        // Preço atual
        Text(
          _formatarPreco(produto.precoAtual),
          style: TextStyle(
            fontSize: produto.isPromocao ? 16 : 14,
            fontWeight: FontWeight.bold,
            color: produto.isPromocao ? Colors.red : Colors.black,
          ),
        ),
      ],
    );
  }

  /// Constrói os botões de ação
  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: onAdicionarAoCarrinho,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Adicionar',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }
}
````

## ✅ Boas Práticas

### 1. Documente o "Porquê", não o "O Que"

```dart
// ❌ Ruim - documenta o óbvio
// Incrementa o contador
counter++;

// ✅ Bom - documenta o motivo
// Incrementa o contador para rastrear cliques do usuário
// usado para analytics e personalização
counter++;
```

### 2. Use Comentários para Explicar Complexidade

```dart
// ✅ Bom - explica algoritmo complexo
/// Calcula o preço com desconto aplicando regras de negócio:
/// - Desconto máximo de 50%
/// - Desconto progressivo por quantidade
/// - Desconto especial para clientes VIP
double calcularPrecoComDesconto(double precoBase, int quantidade, bool isVip) {
  double desconto = 0.0;

  // Desconto por quantidade (5% a cada 10 itens)
  desconto += (quantidade ~/ 10) * 0.05;

  // Desconto VIP adicional
  if (isVip) desconto += 0.10;

  // Limita desconto máximo
  desconto = desconto.clamp(0.0, 0.50);

  return precoBase * (1 - desconto);
}
```

### 3. Documente Exceções e Casos Especiais

```dart
/// Carrega produtos do cache ou Firestore.
///
/// [forcarAtualizacao] - Se true, ignora cache
///
/// Retorna lista de produtos ou lista vazia se erro.
///
/// Exceções:
/// - [NetworkException] - Erro de conexão (tratado internamente)
/// - [CacheException] - Erro de cache (tratado internamente)
/// - [FirestoreException] - Erro do Firestore (tratado internamente)
///
/// Nota: Este método nunca falha, sempre retorna uma lista
/// (pode ser vazia em caso de erro)
Future<List<Produto>> carregarProdutos({bool forcarAtualizacao = false}) async {
  // Implementação...
}
```

### 4. Mantenha Comentários Atualizados

```dart
// ❌ Ruim - comentário desatualizado
// Este método retorna apenas produtos ativos
// TODO: Adicionar filtro por categoria
List<Produto> getProdutos() {
  return produtos.where((p) => p.ativo && p.categoria == 'Frutas').toList();
}

// ✅ Bom - comentário atualizado
// Este método retorna produtos ativos filtrados por categoria
// Filtro implementado na versão 2.1.0
List<Produto> getProdutos() {
  return produtos.where((p) => p.ativo && p.categoria == 'Frutas').toList();
}
```

### 5. Use Comentários para Seções de Código

```dart
class ProdutoCard extends StatelessWidget {
  // ===== CONSTANTES =====
  static const double _cardHeight = 280.0;
  static const double _imageHeight = 120.0;

  // ===== PROPRIEDADES =====
  final Produto produto;
  final VoidCallback? onAdicionarAoCarrinho;

  // ===== CONSTRUTOR =====
  const ProdutoCard({
    super.key,
    required this.produto,
    this.onAdicionarAoCarrinho,
  });

  // ===== MÉTODOS PRIVADOS =====
  void _showProductModal(BuildContext context) {
    // Implementação...
  }

  // ===== BUILD =====
  @override
  Widget build(BuildContext context) {
    // Implementação...
  }
}
```

## 🛠️ Ferramentas de Documentação

### 1. dartdoc

```bash
# Gerar documentação
dartdoc

# Servir documentação localmente
dart pub global activate dhttpd
dhttpd --path doc/api
```

### 2. VS Code Extensions

```json
{
  "recommendations": [
    "Dart-Code.dart-code",
    "Dart-Code.flutter",
    "ms-vscode.vscode-json",
    "bradlc.vscode-tailwindcss"
  ]
}
```

### 3. Análise de Código

```bash
# Verificar documentação
flutter analyze

# Verificar cobertura de documentação
dart pub global activate dart_style
dart_style --fix .
```

### 4. Templates de Comentário

#### Template para Classes

````dart
/// [Descrição breve da classe]
///
/// [Descrição detalhada se necessário]
///
/// Características principais:
/// - [Característica 1]
/// - [Característica 2]
/// - [Característica 3]
///
/// Exemplo de uso:
/// ```dart
/// [Exemplo de código]
/// ```
class NomeDaClasse {
  // Implementação...
}
````

#### Template para Métodos

````dart
/// [Descrição breve do método]
///
/// [Descrição detalhada se necessário]
///
/// [parametro1] - [Descrição do parâmetro]
/// [parametro2] - [Descrição do parâmetro]
///
/// Retorna [tipo] em caso de sucesso.
///
/// Lança [Excecao] se [condição].
///
/// Exemplo:
/// ```dart
/// [Exemplo de uso]
/// ```
Future<Tipo> nomeDoMetodo(Tipo parametro1, Tipo parametro2) async {
  // Implementação...
}
````

---

## 📞 Suporte

Para dúvidas sobre comentários e documentação:

- **Email**: docs@mercadofacil.com
- **Issues**: [GitHub Issues](https://github.com/seu-usuario/mercado_facil/issues)
- **Wiki**: [Documentação do Projeto](https://github.com/seu-usuario/mercado_facil/wiki)

---

**Código bem documentado é código mantível! 📝✨**
