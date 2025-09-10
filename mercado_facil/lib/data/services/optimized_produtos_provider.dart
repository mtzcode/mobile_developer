import 'package:flutter/foundation.dart';
import '../models/produto.dart';
import 'produtos_service.dart';

/// Provider otimizado para produtos que evita rebuilds desnecessários
class OptimizedProdutosProvider extends ChangeNotifier {
  List<Produto> _produtos = [];
  List<Produto> _produtosFiltrados = [];
  bool _loading = false;
  bool _carregandoMais = false;
  bool _temMaisProdutos = true;
  int _paginaAtual = 1;
  
  // Filtros
  String _searchQuery = '';
  String? _categoriaFiltro;
  double _precoMin = 0;
  double _precoMax = 100;
  bool _filtrarOferta = false;
  bool _filtrarNovo = false;
  bool _filtrarMaisVendido = false;

  // Getters
  List<Produto> get produtos => _produtos;
  List<Produto> get produtosFiltrados => _produtosFiltrados;
  bool get loading => _loading;
  bool get carregandoMais => _carregandoMais;
  bool get temMaisProdutos => _temMaisProdutos;
  int get paginaAtual => _paginaAtual;
  
  // Getters para filtros
  String get searchQuery => _searchQuery;
  String? get categoriaFiltro => _categoriaFiltro;
  double get precoMin => _precoMin;
  double get precoMax => _precoMax;
  bool get filtrarOferta => _filtrarOferta;
  bool get filtrarNovo => _filtrarNovo;
  bool get filtrarMaisVendido => _filtrarMaisVendido;

  /// Carrega produtos iniciais
  Future<void> carregarProdutosIniciais() async {
    if (_loading) return;
    
    _loading = true;
    notifyListeners();
    
    try {
      final produtos = await ProdutosService.getProdutosPaginados(page: 1, pageSize: 8);
      final temMais = await ProdutosService.temMaisProdutos(page: 1, pageSize: 8);
      
      _produtos = produtos;
      _paginaAtual = 1;
      _temMaisProdutos = temMais;
      _aplicarFiltros();
    } catch (e) {
      // Erro silencioso - pode ser tratado pela UI
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Carrega mais produtos
  Future<void> carregarMaisProdutos() async {
    if (_carregandoMais || !_temMaisProdutos) return;
    
    _carregandoMais = true;
    notifyListeners();
    
    try {
      final proximaPagina = _paginaAtual + 1;
      final maisProdutos = await ProdutosService.getProdutosPaginados(page: proximaPagina, pageSize: 8);
      final temMais = await ProdutosService.temMaisProdutos(page: proximaPagina, pageSize: 8);
      
      _produtos.addAll(maisProdutos);
      _paginaAtual = proximaPagina;
      _temMaisProdutos = temMais;
      _aplicarFiltros();
    } catch (e) {
      // Erro silencioso - pode ser tratado pela UI
    } finally {
      _carregandoMais = false;
      notifyListeners();
    }
  }

  /// Atualiza produtos (força recarregamento)
  Future<void> atualizarProdutos() async {
    _loading = true;
    notifyListeners();
    
    try {
      final produtos = await ProdutosService.getProdutosPaginados(page: 1, pageSize: 8, forcarAtualizacao: true);
      final temMais = await ProdutosService.temMaisProdutos(page: 1, pageSize: 8);
      
      _produtos = produtos;
      _paginaAtual = 1;
      _temMaisProdutos = temMais;
      _aplicarFiltros();
    } catch (e) {
      // Erro silencioso - pode ser tratado pela UI
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Define query de busca
  void setSearchQuery(String query) {
    if (_searchQuery != query) {
      _searchQuery = query;
      _aplicarFiltros();
      notifyListeners();
    }
  }

  /// Define filtro de categoria
  void setCategoriaFiltro(String? categoria) {
    if (_categoriaFiltro != categoria) {
      _categoriaFiltro = categoria;
      _aplicarFiltros();
      notifyListeners();
    }
  }

  /// Define faixa de preço
  void setFaixaPreco(double min, double max) {
    if (_precoMin != min || _precoMax != max) {
      _precoMin = min;
      _precoMax = max;
      _aplicarFiltros();
      notifyListeners();
    }
  }

  /// Define filtros de destaque
  void setFiltrosDestaque({
    bool? oferta,
    bool? novo,
    bool? maisVendido,
  }) {
    bool mudou = false;
    
    if (oferta != null && _filtrarOferta != oferta) {
      _filtrarOferta = oferta;
      mudou = true;
    }
    
    if (novo != null && _filtrarNovo != novo) {
      _filtrarNovo = novo;
      mudou = true;
    }
    
    if (maisVendido != null && _filtrarMaisVendido != maisVendido) {
      _filtrarMaisVendido = maisVendido;
      mudou = true;
    }
    
    if (mudou) {
      _aplicarFiltros();
      notifyListeners();
    }
  }

  /// Limpa todos os filtros
  void limparFiltros() {
    _searchQuery = '';
    _categoriaFiltro = null;
    _precoMin = 0;
    _precoMax = 100;
    _filtrarOferta = false;
    _filtrarNovo = false;
    _filtrarMaisVendido = false;
    
    _aplicarFiltros();
    notifyListeners();
  }

  /// Aplica filtros aos produtos
  void _aplicarFiltros() {
    _produtosFiltrados = _produtos.where((produto) {
      // Filtro por nome
      final matchNome = produto.nome.toLowerCase().contains(_searchQuery.toLowerCase());
      
      // Filtro por categoria
      final matchCategoria = _categoriaFiltro == null || (produto.categoria == _categoriaFiltro);
      
      // Filtro por preço
      final preco = produto.precoPromocional ?? produto.preco;
      final matchPreco = preco >= _precoMin && preco <= _precoMax;
      
      // Filtro por destaque
      bool matchDestaque = true;
      if (_filtrarOferta || _filtrarNovo || _filtrarMaisVendido) {
        matchDestaque = (_filtrarOferta && produto.destaque == 'oferta') ||
                       (_filtrarNovo && produto.destaque == 'novo') ||
                       (_filtrarMaisVendido && produto.destaque == 'mais vendido');
      }
      
      return matchNome && matchCategoria && matchPreco && matchDestaque;
    }).toList();
  }

  /// Atualiza favorito de um produto
  void atualizarFavorito(String produtoId, bool favorito) {
    final index = _produtos.indexWhere((p) => p.id == produtoId);
    if (index != -1) {
      _produtos[index] = _produtos[index].copyWith(favorito: favorito);
      _aplicarFiltros();
      notifyListeners();
      
      // Atualiza no cache
      ProdutosService.atualizarFavorito(produtoId, favorito);
    }
  }

  /// Obtém categorias disponíveis
  List<String> get categoriasDisponiveis {
    final categorias = _produtos.map((p) => p.categoria ?? '').toSet().where((c) => c.isNotEmpty).toList();
    categorias.sort();
    return ['Todos', ...categorias];
  }

  /// Obtém faixa de preço disponível
  Map<String, double> get faixaPrecoDisponivel {
    if (_produtos.isEmpty) return {'min': 0, 'max': 100};
    
    final precos = _produtos.map((p) => p.precoPromocional ?? p.preco).toList();
    return {
      'min': precos.reduce((a, b) => a < b ? a : b),
      'max': precos.reduce((a, b) => a > b ? a : b),
    };
  }

  /// Verifica se há filtros ativos
  bool get temFiltrosAtivos {
    return _searchQuery.isNotEmpty ||
           _categoriaFiltro != null ||
           _precoMin > 0 ||
           _precoMax < 100 ||
           _filtrarOferta ||
           _filtrarNovo ||
           _filtrarMaisVendido;
  }
} 