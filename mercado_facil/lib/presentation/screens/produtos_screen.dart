import 'package:flutter/material.dart';
import '../../data/services/produtos_service.dart';
import '../../data/services/firestore_service.dart';
import '../widgets/produto_card.dart';
import 'package:provider/provider.dart';
import '../../data/services/carrinho_provider.dart';
import '../../data/services/user_provider.dart';
import '../../data/models/produto.dart';
import 'ofertas_screen.dart';
import '../../core/utils/snackbar_utils.dart';

class ProdutosScreen extends StatefulWidget {
  const ProdutosScreen({super.key});

  @override
  State<ProdutosScreen> createState() => _ProdutosScreenState();
}

class _ProdutosScreenState extends State<ProdutosScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _categoriaSelecionada = 0;
  List<String> categorias = ['Todos', 'Frutas', 'Verduras', 'Carnes', 'Laticínios', 'Bebidas', 'Padaria'];
  final List<String> _categorias = ['Todos', 'Frutas', 'Verduras', 'Carnes', 'Laticínios', 'Bebidas', 'Padaria'];
  String _categoriaFiltro = 'Todos';
  bool _isLoading = true;
  List<Produto> _produtosExibidos = [];
  List<Produto> _todosProdutos = [];

  @override
  void initState() {
    super.initState();
    _carregarProdutos();
    
    // Carregar dados do usuário após o build inicial
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _carregarDadosUsuario();
    });
  }

  Future<void> _carregarDadosUsuario() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.carregarUsuarioLogado();
  }

  Future<void> _carregarProdutos() async {
    debugPrint('🔄 Iniciando carregamento de produtos...');
    setState(() {
      _isLoading = true;
    });
    
    try {
      debugPrint('📡 Chamando ProdutosService.carregarProdutosComCache()...');
      final produtos = await ProdutosService.carregarProdutosComCache();
      debugPrint('✅ Produtos carregados: ${produtos.length} itens');
      
      // Carregar favoritos do usuário se estiver logado
      if (!mounted) return;
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userId = userProvider.usuarioLogado?.id;
      
      if (userId != null) {
        try {
          final firestoreService = FirestoreService();
          final produtosComFavoritos = await firestoreService.getProdutosComFavoritos(userId);
          debugPrint('💖 Favoritos carregados para usuário: $userId');
          
          if (mounted) {
            setState(() {
              _todosProdutos = produtosComFavoritos;
              _produtosExibidos = produtosComFavoritos;
              _isLoading = false;
            });
            debugPrint('🎯 Estado atualizado - produtos com favoritos: ${produtosComFavoritos.length}');
          }
        } catch (e) {
          debugPrint('⚠️ Erro ao carregar favoritos, usando produtos sem favoritos: $e');
          if (mounted) {
            setState(() {
              _todosProdutos = produtos;
              _produtosExibidos = produtos;
              _isLoading = false;
            });
          }
        }
      } else {
        if (mounted) {
          setState(() {
            _todosProdutos = produtos;
            _produtosExibidos = produtos;
            _isLoading = false;
          });
          debugPrint('🎯 Estado atualizado - produtos: ${produtos.length}');
        }
      }
    } catch (e) {
      debugPrint('❌ Erro ao carregar produtos: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        showAppSnackBar(
          context,
          'Erro ao carregar produtos: $e',
          icon: Icons.error,
          backgroundColor: Colors.red.shade600,
        );
      }
    }
  }

  void _selecionarCategoria(String? categoria) {
    setState(() {
      _categoriaFiltro = categoria ?? 'Todos';
      _categoriaSelecionada = _categorias.indexOf(_categoriaFiltro);
      _filtrarProdutos();
    });
  }

  void _buscarProdutos(String query) {
    setState(() {
      _searchQuery = query;
      _filtrarProdutos();
    });
  }

  void _filtrarProdutos() {
    List<Produto> produtosFiltrados = _todosProdutos;

    // Filtrar por categoria
    if (_categoriaSelecionada > 0) {
      final categoriaSelecionada = categorias[_categoriaSelecionada];
      produtosFiltrados = produtosFiltrados.where((produto) => 
        produto.categoria == categoriaSelecionada).toList();
    }

    // Filtrar por busca
    if (_searchQuery.isNotEmpty) {
      produtosFiltrados = produtosFiltrados.where((produto) => 
        produto.nome.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }

    setState(() {
      _produtosExibidos = produtosFiltrados;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Produtos'),
        centerTitle: true,
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          // Indicador de cache
          // REMOVIDO: IconButton de status de cache
          Consumer<CarrinhoProvider>(
            builder: (context, carrinho, child) {
              int quantidade = carrinho.itens.fold(0, (soma, item) => soma + item.quantidade);
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    onPressed: () {
                      Navigator.pushNamed(context, '/carrinho');
                    },
                  ),
                  if (quantidade > 0)
                    Positioned(
                      right: 8,
                      top: 12,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                        child: Text(
                          '$quantidade',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // DrawerHeader substituído por cabeçalho de usuário
            Consumer<UserProvider>(
              builder: (context, userProvider, child) {
                final usuario = userProvider.usuarioLogado;
                return Container(
                  color: colorScheme.primary,
                  padding: const EdgeInsets.only(top: 32, bottom: 20, left: 16, right: 16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundImage: usuario?.fotoUrl != null 
                          ? NetworkImage(usuario!.fotoUrl!)
                          : null,
                        backgroundColor: Colors.white,
                        child: usuario?.fotoUrl == null 
                          ? Icon(Icons.person, size: 32, color: colorScheme.primary)
                          : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              usuario?.nome ?? 'Usuário',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              usuario?.email ?? 'email@exemplo.com',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            // Itens de navegação principais
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Meus Dados'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/perfil');
              },
            ),
            ListTile(
              leading: const Icon(Icons.location_on),
              title: const Text('Endereços'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/enderecos');
              },
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long),
              title: const Text('Meus Pedidos'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/pedidos');
              },
            ),
            ListTile(
              leading: const Icon(Icons.shopping_cart),
              title: const Text('Carrinho'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/carrinho');
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite),
              title: const Text('Favoritos'),
              onTap: () {
                Navigator.pop(context);
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.white,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  builder: (context) {
                    return StatefulBuilder(
                      builder: (context, setModalState) {
                        List<Produto> favoritos = _produtosExibidos.where((p) => p.favorito).toList();
                        return Padding(
                          padding: EdgeInsets.only(
                            left: 20,
                            right: 20,
                            top: 20,
                            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text('Meus Favoritos', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 18),
                              if (favoritos.isEmpty)
                                const Center(child: Text('Nenhum produto favorito.'))
                              else
                                SizedBox(
                                  height: 350,
                                  child: GridView.builder(
                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      childAspectRatio: 0.8,
                                      crossAxisSpacing: 24,
                                      mainAxisSpacing: 24,
                                    ),
                                    itemCount: favoritos.length,
                                    itemBuilder: (context, index) {
                                      final produto = favoritos[index];
                                      return ProdutoCard(
                                        produto: produto,
                                        onAdicionarAoCarrinho: () {
                                          Provider.of<CarrinhoProvider>(context, listen: false).adicionarProduto(produto);
                                          showAppSnackBar(
                                            context,
                                            '${produto.nome} adicionado ao carrinho!',
                                            icon: Icons.check_circle,
                                            backgroundColor: Colors.green.shade600,
                                          );
                                        },
                                        onToggleFavorito: () {
                                          setModalState(() {});
                                        },
                                        key: ValueKey(produto.id),
                                      );
                                    },
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.local_offer),
              title: const Text('Ofertas'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OfertasScreen(produtos: _produtosExibidos),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Notificações'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/notificacoes');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('Ajuda/Suporte'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/ajuda');
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Sobre o App'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/sobre');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sair'),
              onTap: () async {
                final navigator = Navigator.of(context);
                navigator.pop();
                final userProvider = Provider.of<UserProvider>(context, listen: false);
                await userProvider.fazerLogout();
                if (mounted) {
                  navigator.pushNamedAndRemoveUntil('/', (route) => false);
                }
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Barra de pesquisa simples
            Container(
              height: 53,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade400),
                color: Colors.white,
              ),
              child: Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(Icons.search, color: Color(0xFF003938)),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        _buscarProdutos(value);
                      },
                      decoration: const InputDecoration(
                        hintText: 'Pesquisar produtos...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Lista de categorias simples
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _categorias.length,
                itemBuilder: (context, index) {
                  final categoria = _categorias[index];
                  final isSelected = _categoriaFiltro == categoria;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(categoria),
                      selected: isSelected,
                      onSelected: (selected) {
                        _selecionarCategoria(selected ? categoria : null);
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            // Lista de produtos
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: _produtosExibidos.length,
                      itemBuilder: (context, index) {
                        final produto = _produtosExibidos[index];
                        return ProdutoCard(
                          produto: produto,
                          onAdicionarAoCarrinho: () {
                            Provider.of<CarrinhoProvider>(context, listen: false)
                                .adicionarProduto(produto);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${produto.nome} adicionado ao carrinho!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          },
                          onToggleFavorito: () async {
                            if (!mounted) return;
                            final scaffoldMessenger = ScaffoldMessenger.of(context);
                            final userProvider = Provider.of<UserProvider>(context, listen: false);
                            final userId = userProvider.usuarioLogado?.id;
                            
                            if (userId != null) {
                              try {
                                final firestoreService = FirestoreService();
                                
                                if (produto.favorito) {
                                  await firestoreService.removerFavorito(userId, produto.id);
                                } else {
                                  await firestoreService.adicionarFavorito(userId, produto.id);
                                }
                                
                                if (mounted) {
                                  setState(() {
                                    produto.favorito = !produto.favorito;
                                  });
                                  
                                  scaffoldMessenger.showSnackBar(
                                    SnackBar(
                                      content: Text(produto.favorito 
                                          ? '${produto.nome} adicionado aos favoritos!' 
                                          : '${produto.nome} removido dos favoritos!'),
                                      backgroundColor: produto.favorito ? Colors.green : Colors.orange,
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (mounted) {
                                  scaffoldMessenger.showSnackBar(
                                    SnackBar(
                                      content: Text('Erro ao atualizar favoritos: $e'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            }
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}