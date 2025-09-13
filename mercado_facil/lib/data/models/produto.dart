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

  /// Quantidade em estoque do produto
  final int estoque;

  /// Indica se o produto está disponível para compra
  final bool disponivel;

  /// Lista de avaliações do produto
  final List<double> avaliacoes;

  /// Código de barras do produto (opcional)
  final String? codigoBarras;

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
  /// [estoque] - Quantidade em estoque (padrão: 0)
  /// [disponivel] - Disponibilidade do produto (padrão: true)
  /// [avaliacoes] - Lista de avaliações (padrão: lista vazia)
  /// [codigoBarras] - Código de barras do produto (opcional)
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
    this.estoque = 0,
    this.disponivel = true,
    this.avaliacoes = const [],
    this.codigoBarras,
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
  /// [estoque] - Nova quantidade em estoque (opcional)
  /// [disponivel] - Nova disponibilidade (opcional)
  /// [avaliacoes] - Nova lista de avaliações (opcional)
  /// [codigoBarras] - Novo código de barras (opcional)
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
    int? estoque,
    bool? disponivel,
    List<double>? avaliacoes,
    String? codigoBarras,
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
        estoque: estoque ?? this.estoque,
        disponivel: disponivel ?? this.disponivel,
        avaliacoes: avaliacoes ?? this.avaliacoes,
        codigoBarras: codigoBarras ?? this.codigoBarras,
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
      'estoque': estoque,
      'disponivel': disponivel,
      'avaliacoes': avaliacoes,
      'codigoBarras': codigoBarras,
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
      descricao: map['descricao'] is String ? map['descricao'] : null,
      categoria: map['categoria'] is String ? map['categoria'] : null,
      destaque: map['destaque'] is String ? map['destaque'] : null,
      precoPromocional: map['precoPromocional'] != null 
          ? (map['precoPromocional'] as num).toDouble() 
          : null,
      favorito: map['favorito'] ?? false,
      estoque: map['estoque'] ?? 0,
      disponivel: map['disponivel'] ?? true,
      avaliacoes: map['avaliacoes'] != null 
          ? List<double>.from(map['avaliacoes'].map((x) => (x as num).toDouble()))
          : [],
      codigoBarras: map['codigoBarras'] is String ? map['codigoBarras'] : null,
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

// Mock de produtos para testes de filtros, tags e favoritos
final List<Produto> produtosMock = [
  Produto(
    id: '1',
    nome: 'Arroz Integral',
    preco: 6.99,
    precoPromocional: 5.99,
    imagemUrl: 'https://via.placeholder.com/150',
    categoria: 'Cereais',
    destaque: 'oferta',
    favorito: false,
  ),
  Produto(
    id: '2',
    nome: 'Feijão Preto',
    preco: 7.49,
    precoPromocional: 6.49,
    imagemUrl: 'https://via.placeholder.com/150',
    categoria: 'Cereais',
    destaque: 'mais vendido',
    favorito: true,
  ),
  Produto(
    id: '3',
    nome: 'Leite Integral',
    preco: 4.20,
    imagemUrl: 'https://via.placeholder.com/150',
    categoria: 'Laticínios',
    destaque: 'novo',
    favorito: false,
  ),
  Produto(
    id: '4',
    nome: 'Açúcar Refinado',
    preco: 3.10,
    imagemUrl: 'https://via.placeholder.com/150',
    categoria: 'Açúcar',
    favorito: false,
  ),
  Produto(
    id: '5',
    nome: 'Óleo de Soja',
    preco: 8.99,
    precoPromocional: 7.99,
    imagemUrl: 'https://via.placeholder.com/150',
    categoria: 'Óleos',
    destaque: 'oferta',
    favorito: true,
  ),
  Produto(
    id: '6',
    nome: 'Café Torrado',
    preco: 12.50,
    imagemUrl: 'https://via.placeholder.com/150',
    categoria: 'Bebidas',
    destaque: 'mais vendido',
    favorito: false,
  ),
  Produto(
    id: '7',
    nome: 'Biscoito Recheado',
    preco: 2.99,
    imagemUrl: 'https://via.placeholder.com/150',
    categoria: 'Snacks',
    destaque: 'novo',
    favorito: true,
  ),
  Produto(
    id: '8',
    nome: 'Sabonete',
    preco: 1.99,
    imagemUrl: 'https://via.placeholder.com/150',
    categoria: 'Higiene',
    favorito: false,
  ),
  Produto(
    id: '9',
    nome: 'Detergente',
    preco: 2.50,
    imagemUrl: 'https://via.placeholder.com/150',
    categoria: 'Limpeza',
    destaque: 'oferta',
    favorito: false,
  ),
  Produto(
    id: '10',
    nome: 'Queijo Mussarela',
    preco: 15.90,
    precoPromocional: 13.90,
    imagemUrl: 'https://via.placeholder.com/150',
    categoria: 'Laticínios',
    destaque: 'mais vendido',
    favorito: true,
  ),
];