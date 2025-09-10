import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../../data/services/produtos_service.dart';
import '../../data/providers/providers_config.dart';
import '../widgets/produto_card.dart';
import '../../data/models/produto.dart';
import '../../core/utils/snackbar_utils.dart';

class ProdutosScreen extends ConsumerStatefulWidget {
  const ProdutosScreen({super.key});

  @override
  ConsumerState<ProdutosScreen> createState() => _ProdutosScreenState();
}

class _ProdutosScreenState extends ConsumerState<ProdutosScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final ItemScrollController _categoriaScrollController = ItemScrollController();
  String _searchQuery = '';
  int _categoriaSelecionada = 0;
  List<String> categorias = [];
  final List<String> _historicoBuscas = [];
  bool _showSuggestions = false;

  // Filtros avançados
  String? _categoriaFiltro;
  double _precoMin = 0;
  double _precoMax = 100;
  double _precoRangeMin = 0;
  double _precoRangeMax = 100;
  bool _filtrarOferta = false;


  bool _loading = true;
  List<Produto> _produtosExibidos = [];
  int _paginaAtual = 1;
  bool _carregandoMais = false;
  bool _temMaisProdutos = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _inicializarCategorias();
    _searchFocusNode.addListener(() {
      if (mounted) {
        setState(() {
          _showSuggestions = _searchFocusNode.hasFocus;
        });
      }
    });
    _carregarProdutosIniciais();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 && !_carregandoMais && _temMaisProdutos) {
        _carregarMaisProdutos();
      }
    });
    
    // Carregar dados do usuário após o build inicial
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _carregarDadosUsuario();
    });
  }

  Future<void> _carregarDadosUsuario() async {
    try {
      await ref.read(userProvider.notifier).carregarUsuarioLogado();
    } catch (e) {
      // Ignorar erro silenciosamente
    }
  }

  Future<void> _inicializarCategorias() async {
    try {
      final produtos = await ProdutosService.carregarProdutosComCache();
      if (mounted) {
        setState(() {
          categorias = ['Todos'];
          categorias.addAll(produtos.map((p) => p.categoria ?? '').toSet().where((c) => c.isNotEmpty));
          
          // Inicializa faixa de preço
          final precos = produtos.map((p) => p.precoPromocional ?? p.preco).toList();
          if (precos.isNotEmpty) {
            _precoRangeMin = precos.reduce((a, b) => a < b ? a : b);
            _precoRangeMax = precos.reduce((a, b) => a > b ? a : b);
            _precoMin = _precoRangeMin;
            _precoMax = _precoRangeMax;
          }
        });
      }
    } catch (e) {
      // Ignorar erro silenciosamente
    }
  }

  Future<void> _carregarProdutosIniciais() async {
    setState(() => _loading = true);
    
    try {
      final produtos = await ProdutosService.getProdutosPaginados(page: 1, pageSize: 8);
      final temMais = await ProdutosService.temMaisProdutos(page: 1, pageSize: 8);
      
      if (mounted) {
        setState(() {
          _produtosExibidos = produtos;
          _paginaAtual = 1;
          _temMaisProdutos = temMais;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        showAppSnackBar(
          context,
          'Erro ao carregar produtos: $e',
          icon: Icons.error,
          backgroundColor: Colors.red.shade600,
        );
      }
    }
  }

  Future<void> _atualizarProdutos() async {
    try {
      final produtos = await ProdutosService.carregarProdutosComCache(forcarAtualizacao: true);
      if (mounted) {
        setState(() {
          _produtosExibidos = produtos;
          _paginaAtual = 1;
          _temMaisProdutos = true;
        });
        
        showAppSnackBar(
          context,
          'Produtos atualizados com sucesso!',
          icon: Icons.check_circle,
          backgroundColor: Colors.green.shade600,
        );
      }
    } catch (e) {
      if (mounted) {
        showAppSnackBar(
          context,
          'Erro ao atualizar produtos: $e',
          icon: Icons.error,
          backgroundColor: Colors.red.shade600,
        );
      }
    }
  }

  void _mostrarInfoCache(Map<String, dynamic> cacheInfo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Informações do Cache'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: ${cacheInfo['valido'] ? 'Válido' : 'Expirado'}'),
            const SizedBox(height: 8),
            Text('Produtos em cache: ${cacheInfo['quantidadeProdutos']}'),
            if (cacheInfo['ultimaAtualizacao'] != null) ...[
              const SizedBox(height: 8),
              Text('Última atualização: ${_formatarData(cacheInfo['ultimaAtualizacao'])}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _atualizarProdutos();
            },
            child: const Text('Atualizar'),
          ),
        ],
      ),
    );
  }

  String _formatarData(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year} às ${data.hour.toString().padLeft(2, '0')}:${data.minute.toString().padLeft(2, '0')}';
  }

  void _selecionarCategoria(int index) {
    setState(() {
      _categoriaSelecionada = index;
      // Conecta a seleção de categoria com o filtro
      if (index == 0) {
        _categoriaFiltro = null; // "Todos"
      } else {
        _categoriaFiltro = categorias[index];
      }
    });
    _scrollToCategoria(index);
  }

  void _scrollToCategoria(int index) {
    if (index < categorias.length) {
      try {
        _categoriaScrollController.scrollTo(
          index: index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } catch (e) {
        // Ignorar erro de scroll
      }
    }
  }

  void _adicionarAoCarrinho(Produto produto) {
    final user = ref.read(usuarioLogadoProvider);
    if (user == null) {
      showAppSnackBar(
        context,
        'Faça login para adicionar produtos ao carrinho',
        icon: Icons.warning,
        backgroundColor: Colors.orange.shade600,
      );
      return;
    }

    // Usar o notifier do carrinho Riverpod
    ref.read(carrinhoProvider(user.id).notifier).adicionarProduto(produto);
    
    showAppSnackBar(
      context,
      '${produto.nome} adicionado ao carrinho!',
      icon: Icons.check_circle,
      backgroundColor: Colors.green.shade600,
    );
  }

  void _buscarProdutos(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      _paginaAtual = 1;
      _temMaisProdutos = true;
    });
    
    if (query.isNotEmpty && !_historicoBuscas.contains(query)) {
      setState(() {
        _historicoBuscas.insert(0, query);
        if (_historicoBuscas.length > 5) {
          _historicoBuscas.removeLast();
        }
      });
    }
    
    _aplicarFiltros();
  }

  void _aplicarFiltros() {
    setState(() {
      _paginaAtual = 1;
      _temMaisProdutos = true;
    });
    _carregarProdutosFiltrados();
  }

  Future<void> _carregarProdutosFiltrados() async {
    setState(() => _loading = true);
    
    try {
      List<Produto> produtos = await ProdutosService.carregarProdutosComCache();
      
      // Aplicar filtros
      if (_searchQuery.isNotEmpty) {
        produtos = produtos.where((p) => 
          p.nome.toLowerCase().contains(_searchQuery) ||
          (p.descricao?.toLowerCase().contains(_searchQuery) ?? false) ||
          (p.categoria?.toLowerCase().contains(_searchQuery) ?? false)
        ).toList();
      }
      
      if (_categoriaFiltro != null) {
        produtos = produtos.where((p) => p.categoria == _categoriaFiltro).toList();
      }
      
      if (_filtrarOferta) {
        produtos = produtos.where((p) => p.precoPromocional != null && p.precoPromocional! < p.preco).toList();
      }
      
      // Filtro de preço
      produtos = produtos.where((p) {
        final preco = p.precoPromocional ?? p.preco;
        return preco >= _precoMin && preco <= _precoMax;
      }).toList();
      
      if (mounted) {
        setState(() {
          _produtosExibidos = produtos;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        showAppSnackBar(
          context,
          'Erro ao filtrar produtos: $e',
          icon: Icons.error,
          backgroundColor: Colors.red.shade600,
        );
      }
    }
  }

  Future<void> _carregarMaisProdutos() async {
    if (_carregandoMais || !_temMaisProdutos) return;
    
    setState(() => _carregandoMais = true);
    
    try {
      final novaPagina = _paginaAtual + 1;
      final novosProdutos = await ProdutosService.getProdutosPaginados(page: novaPagina, pageSize: 8);
      final temMais = await ProdutosService.temMaisProdutos(page: novaPagina, pageSize: 8);
      
      if (mounted) {
        setState(() {
          _produtosExibidos.addAll(novosProdutos);
          _paginaAtual = novaPagina;
          _temMaisProdutos = temMais;
          _carregandoMais = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _carregandoMais = false);
        showAppSnackBar(
          context,
          'Erro ao carregar mais produtos: $e',
          icon: Icons.error,
          backgroundColor: Colors.red.shade600,
        );
      }
    }
  }

  void _mostrarFiltrosAvancados() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildFiltrosAvancados(),
    );
  }

  Widget _buildFiltrosAvancados() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filtros Avançados',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Filtro de categoria
                Text(
                  'Categoria',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _categoriaFiltro,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Todas')),
                    ...categorias.skip(1).map((categoria) => DropdownMenuItem(
                      value: categoria,
                      child: Text(categoria),
                    )),
                  ],
                  onChanged: (value) {
                    setState(() => _categoriaFiltro = value);
                  },
                ),
                const SizedBox(height: 16),
                
                // Filtro de preço
                Text(
                  'Faixa de Preço',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                RangeSlider(
                  values: RangeValues(_precoMin, _precoMax),
                  min: _precoRangeMin,
                  max: _precoRangeMax,
                  divisions: 100,
                  labels: RangeLabels(
                    'R\$ ${_precoMin.toStringAsFixed(2)}',
                    'R\$ ${_precoMax.toStringAsFixed(2)}',
                  ),
                  onChanged: (values) {
                    setState(() {
                      _precoMin = values.start;
                      _precoMax = values.end;
                    });
                  },
                ),
                const SizedBox(height: 16),
                
                // Filtros de checkbox
                CheckboxListTile(
                  title: const Text('Apenas ofertas'),
                  value: _filtrarOferta,
                  onChanged: (value) {
                    setState(() => _filtrarOferta = value ?? false);
                  },
                ),
                const SizedBox(height: 16),
                
                // Botões
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _categoriaFiltro = null;
                            _precoMin = _precoRangeMin;
                            _precoMax = _precoRangeMax;
                            _filtrarOferta = false;
                          });
                        },
                        child: const Text('Limpar'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _aplicarFiltros();
                        },
                        child: const Text('Aplicar'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Consumir providers Riverpod
    final user = ref.watch(usuarioLogadoProvider);
    final carrinhoQuantidade = user != null 
        ? ref.watch(carrinhoQuantidadeTotalProvider(user.id))
        : 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Produtos',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        actions: [
          // Botão de filtros
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _mostrarFiltrosAvancados,
            tooltip: 'Filtros avançados',
          ),
          // Botão de cache info
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () async {
              try {
                final cacheInfo = await ProdutosService.getCacheInfo();
                _mostrarInfoCache(cacheInfo);
              } catch (e) {
                // Ignorar erro
              }
            },
            tooltip: 'Informações do cache',
          ),
          // Botão de atualizar
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _atualizarProdutos,
            tooltip: 'Atualizar produtos',
          ),
          // Botão do carrinho
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () => Navigator.pushNamed(context, '/carrinho'),
                tooltip: 'Carrinho',
              ),
              if (carrinhoQuantidade > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      carrinhoQuantidade.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de pesquisa
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  decoration: InputDecoration(
                    hintText: 'Buscar produtos...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _buscarProdutos('');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: _buscarProdutos,
                ),
                
                // Sugestões de busca
                if (_showSuggestions && _historicoBuscas.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: _historicoBuscas.map((busca) => ListTile(
                        leading: const Icon(Icons.history),
                        title: Text(busca),
                        onTap: () {
                          _searchController.text = busca;
                          _buscarProdutos(busca);
                          _searchFocusNode.unfocus();
                        },
                      )).toList(),
                    ),
                  ),
              ],
            ),
          ),
          
          // Categorias
          if (categorias.isNotEmpty)
            Container(
              height: 50,
              margin: const EdgeInsets.only(bottom: 16),
              child: ScrollablePositionedList.builder(
                itemCount: categorias.length,
                scrollDirection: Axis.horizontal,
                itemScrollController: _categoriaScrollController,
                itemBuilder: (context, index) {
                  final isSelected = index == _categoriaSelecionada;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    child: FilterChip(
                      label: Text(categorias[index]),
                      selected: isSelected,
                      onSelected: (_) => _selecionarCategoria(index),
                      backgroundColor: Colors.grey[200],
                      selectedColor: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                      checkmarkColor: Theme.of(context).primaryColor,
                    ),
                  );
                },
              ),
            ),
          
          // Lista de produtos
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _produtosExibidos.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'Nenhum produto encontrado',
                              style: TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _atualizarProdutos,
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: _produtosExibidos.length + (_temMaisProdutos ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == _produtosExibidos.length) {
                              return _carregandoMais
                                  ? const Center(
                                      child: Padding(
                                        padding: EdgeInsets.all(16),
                                        child: CircularProgressIndicator(),
                                      ),
                                    )
                                  : const SizedBox.shrink();
                            }
                            
                            final produto = _produtosExibidos[index];
                            return ProdutoCard(
                              produto: produto,
                              onAdicionarAoCarrinho: () => _adicionarAoCarrinho(produto),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}