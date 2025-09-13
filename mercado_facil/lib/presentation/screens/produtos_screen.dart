import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/services/produtos_service.dart';
import '../../data/services/firestore_service.dart';
import '../widgets/produto_card.dart';
import '../../data/services/carrinho_provider.dart';
import '../../data/services/user_provider.dart';
import '../../data/models/produto.dart';
import 'ofertas_screen.dart';
import 'favoritos_screen.dart';
import '../../core/utils/snackbar_utils.dart';
import '../../utils/clear_cache.dart';

class ProdutosScreen extends StatefulWidget {
  const ProdutosScreen({super.key});

  @override
  State<ProdutosScreen> createState() => _ProdutosScreenState();
}

class _ProdutosScreenState extends State<ProdutosScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _categoriaScrollController = ScrollController();
  String _searchQuery = '';
  List<String> _categorias = ['TODOS'];
  String _categoriaSelecionada = 'TODOS';
  List<Produto> _produtosExibidos = [];
  Stream<List<Produto>>? _produtosStream;

  @override
  void initState() {
    super.initState();
    _inicializarStream();
    
    // Carregar dados do usuário após o build inicial
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _carregarDadosUsuario();
    });
  }

  void _inicializarStream() {
    _produtosStream = ProdutosService.getProdutosStream();
  }

  List<Produto> _aplicarFiltros(List<Produto> produtos) {
    var produtosFiltrados = produtos;

    // Filtrar por categoria
    if (_categoriaSelecionada != 'TODOS') {
      produtosFiltrados = produtosFiltrados
          .where((produto) => produto.categoria == _categoriaSelecionada)
          .toList();
    }

    // Filtrar por busca
     if (_searchQuery.isNotEmpty) {
       produtosFiltrados = produtosFiltrados
           .where((produto) =>
               produto.nome.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               (produto.descricao?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false))
           .toList();
     }

    return produtosFiltrados;
  }

  void _atualizarProdutosLocais(List<Produto> produtos) {
    if (!mounted) return;
    
    setState(() {
      _produtosExibidos = _aplicarFiltros(produtos);
      _categorias = ['TODOS', ...produtos.map((p) => p.categoria).where((c) => c != null).cast<String>().toSet()];
    });

    // Carregar favoritos se usuário estiver logado
    _carregarFavoritos();
  }

  Future<void> _carregarFavoritos() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.usuarioLogado?.id;
    if (userId != null) {
      try {
        final firestoreService = FirestoreService();
        final favoritos = await firestoreService.getFavoritos(userId);
        // Favoritos carregados com sucesso
        debugPrint('Favoritos carregados: ${favoritos.length}');
      } catch (e) {
        debugPrint('Erro ao carregar favoritos: $e');
      }
    }
  }

  Future<void> _carregarDadosUsuario() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.carregarUsuarioLogado();
  }

  // Método removido - agora usando StreamBuilder para atualizações em tempo real



  void _selecionarCategoria(String? categoria) {
    setState(() {
      _categoriaSelecionada = categoria ?? 'TODOS';
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
    // Este método agora é tratado pelo StreamBuilder
    // A filtragem é feita em tempo real no método _aplicarFiltros
    setState(() {
      // Força a reconstrução do widget para aplicar os filtros
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _categoriaScrollController.dispose();
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
          // Botão temporário para limpar cache
          IconButton(
            icon: const Icon(Icons.clear_all),
            tooltip: 'Limpar Cache',
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              try {
                await ClearCacheUtil.clearAllCaches();
                if (mounted) {
                  _inicializarStream();
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.white),
                          SizedBox(width: 8),
                          Text('Cache limpo! Recarregando produtos...'),
                        ],
                      ),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('Erro ao limpar cache: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
            // DrawerHeader substituído por cabeçalho de usuário
            Consumer<UserProvider>(
              builder: (context, userProvider, child) {
                final usuario = userProvider.usuarioLogado;
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        colorScheme.primary,
                        colorScheme.primary.withAlpha(204), // 0.8 * 255 = 204
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.only(top: 32, bottom: 20, left: 16, right: 16),
                  child: Row(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 34,
                            backgroundColor: Colors.white,
                            child: CircleAvatar(
                              radius: 32,
                              backgroundImage: usuario?.fotoUrl != null 
                                ? NetworkImage(usuario!.fotoUrl!)
                                : null,
                              backgroundColor: Colors.grey[200],
                              child: usuario?.fotoUrl == null 
                                ? Icon(Icons.person, size: 32, color: Colors.grey)
                                : null,
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                            ),
                          ),
                        ],
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
            // Seção Minha Conta
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'MINHA CONTA',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                  letterSpacing: 1.2,
                ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/perfil');
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    child: ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.withAlpha(26), // 0.1 * 255 ≈ 26
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.person, color: Colors.blue, size: 20),
                      ),
                      title: const Text('Meus Dados'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    ),
                  ),
                ),
              ),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/enderecos');
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.withAlpha(26), // 0.1 * 255 ≈ 26
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.location_on, color: Colors.orange, size: 20),
                    ),
                    title: const Text('Endereços'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  ),
                ),
              ),
            ),
            
            // Seção Compras
            Container(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text(
                'COMPRAS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                  letterSpacing: 1.2,
                ),
              ),
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple.withAlpha(26), // 0.1 * 255 ≈ 26
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.receipt_long, color: Colors.purple, size: 20),
              ),
              title: const Text('Meus Pedidos'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/pedidos');
              },
            ),
            Consumer<CarrinhoProvider>(
              builder: (context, carrinhoProvider, child) {
                final itemCount = carrinhoProvider.itens.fold(0, (soma, item) => soma + item.quantidade);
                return ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.withAlpha(26), // 0.1 * 255 ≈ 26
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.shopping_cart, color: Colors.green, size: 20),
                  ),
                  title: const Text('Carrinho'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (itemCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            itemCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_ios, size: 16),
                    ],
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/carrinho');
                  },
                );
              },
            ),
            Builder(
              builder: (context) {
                List<Produto> favoritos = _produtosExibidos.where((p) => p.favorito).toList();
                final favoritosCount = favoritos.length;
                return ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withAlpha(26), // 0.1 * 255 ≈ 26
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.favorite, color: Colors.red, size: 20),
                  ),
                  title: const Text('Favoritos'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (favoritosCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            favoritosCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_ios, size: 16),
                    ],
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FavoritosScreen(
                          produtos: _produtosExibidos,
                          onFavoritosChanged: () {
                            // Recarregar produtos para atualizar estado dos favoritos
                            _inicializarStream();
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber.withAlpha(26), // 0.1 * 255 ≈ 26
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.local_offer, color: Colors.amber, size: 20),
              ),
              title: const Text('Ofertas'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'NOVO',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
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
            
            // Seção Configurações
            Container(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text(
                'CONFIGURAÇÕES',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                  letterSpacing: 1.2,
                ),
              ),
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.indigo.withAlpha(26), // 0.1 * 255 ≈ 26
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.notifications, color: Colors.indigo, size: 20),
              ),
              title: const Text('Notificações'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/notificacoes');
              },
            ),
            
            // Seção Suporte
            Container(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text(
                'SUPORTE',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                  letterSpacing: 1.2,
                ),
              ),
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.teal.withAlpha(26),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.help_outline, color: Colors.teal, size: 20),
              ),
              title: const Text('Ajuda/Suporte'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/ajuda');
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.cyan.withAlpha(26),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.info_outline, color: Colors.cyan, size: 20),
              ),
              title: const Text('Sobre o App'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/sobre');
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.pink.withAlpha(26),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.star_outline, color: Colors.pink, size: 20),
              ),
              title: const Text('Avaliar App'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.pop(context);
                // Implementar avaliação do app
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Obrigado! Redirecionando para a loja...'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
            ),
            const Divider(height: 32),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withAlpha(26), // 0.1 * 255 ≈ 26
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.logout, color: Colors.red, size: 20),
              ),
              title: const Text('Sair', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.red),
              onTap: () => _handleLogout(),
            ),
            const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          // Espaçamento superior
          const SizedBox(height: 16),
          
          // Barra de pesquisa moderna
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(13),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                _buscarProdutos(value);
              },
              decoration: InputDecoration(
                hintText: 'Buscar produtos...',
                hintStyle: TextStyle(color: Colors.grey[500]),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: colorScheme.primary,
                  size: 24,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear_rounded,
                          color: Colors.grey[500],
                        ),
                        onPressed: () {
                          _searchController.clear();
                          _buscarProdutos('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: Colors.grey.withAlpha(51),
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: colorScheme.primary,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Lista de categorias moderna
          SizedBox(
            height: 50,
            child: ListView.builder(
              controller: _categoriaScrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _categorias.length,
              itemBuilder: (context, index) {
                final categoria = _categorias[index];
                final isSelected = _categoriaSelecionada == categoria;
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    child: FilterChip(
                      label: Text(
                        categoria,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected ? Colors.white : colorScheme.primary,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        _selecionarCategoria(selected ? categoria : null);
                      },
                      backgroundColor: Colors.white,
                      selectedColor: colorScheme.primary,
                      checkmarkColor: Colors.white,
                      side: BorderSide(
                        color: isSelected ? colorScheme.primary : Colors.grey.withAlpha(77),
                        width: 1.5,
                      ),
                      elevation: isSelected ? 4 : 0,
                      shadowColor: colorScheme.primary.withAlpha(77),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          
          // Grade de produtos moderna com StreamBuilder
          Expanded(
            child: StreamBuilder<List<Produto>>(
              stream: _produtosStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Carregando produtos...',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 80,
                          color: Colors.red[400],
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Erro ao carregar produtos',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _inicializarStream();
                            });
                          },
                          child: const Text('Tentar novamente'),
                        ),
                      ],
                    ),
                  );
                }

                final produtos = snapshot.data ?? [];
                
                // Atualizar produtos locais quando receber dados do stream
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    _atualizarProdutosLocais(produtos);
                  }
                });

                final produtosFiltrados = _aplicarFiltros(produtos);

                if (produtosFiltrados.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Nenhum produto encontrado',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'Tente buscar por outro termo'
                              : 'Verifique os filtros aplicados',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            // Calcula o número de colunas baseado na largura da tela
                            int crossAxisCount;
                            double childAspectRatio;
                            
                            if (constraints.maxWidth < 600) {
                              // Mobile: 2 colunas
                              crossAxisCount = 2;
                              childAspectRatio = 0.65;
                            } else if (constraints.maxWidth < 900) {
                              // Tablet: 3 colunas
                              crossAxisCount = 3;
                              childAspectRatio = 0.7;
                            } else if (constraints.maxWidth < 1200) {
                              // Desktop pequeno: 4 colunas
                              crossAxisCount = 4;
                              childAspectRatio = 0.75;
                            } else if (constraints.maxWidth < 1600) {
                              // Desktop médio: 5 colunas
                              crossAxisCount = 5;
                              childAspectRatio = 0.8;
                            } else {
                              // Desktop grande: 6 colunas
                              crossAxisCount = 6;
                              childAspectRatio = 0.85;
                            }
                            
                            return GridView.builder(
                              padding: const EdgeInsets.only(bottom: 16),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                childAspectRatio: childAspectRatio,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                          itemCount: produtosFiltrados.length,
                          itemBuilder: (context, index) {
                            final produto = produtosFiltrados[index];
                            return ProdutoCard(
                              produto: produto,
                              onAdicionarAoCarrinho: () {
                                Provider.of<CarrinhoProvider>(context, listen: false)
                                    .adicionarProduto(produto);
                                showAppSnackBar(
                                  context,
                                  '${produto.nome} adicionado ao carrinho!',
                                  icon: Icons.check_circle,
                                  backgroundColor: Colors.green.shade600,
                                );
                              },
                              onToggleFavorito: () async {
                                if (!mounted) return;
                                final userProvider = Provider.of<UserProvider>(context, listen: false);
                                final userId = userProvider.usuarioLogado?.id;
                                final messenger = ScaffoldMessenger.of(context);
                                
                                if (userId != null) {
                                  try {
                                    final firestoreService = FirestoreService();
                                    
                                    if (produto.favorito) {
                                      await firestoreService.removerFavorito(userId, produto.id);
                                    } else {
                                      await firestoreService.adicionarFavorito(userId, produto.id);
                                    }
                                    
                                    if (!mounted) return;
                                    setState(() {
                                      produto.favorito = !produto.favorito;
                                    });
                                    
                                    messenger.showSnackBar(
                                      SnackBar(
                                        content: Row(
                                          children: [
                                            Icon(produto.favorito ? Icons.favorite : Icons.favorite_border, color: Colors.white),
                                            SizedBox(width: 8),
                                            Text(produto.favorito 
                                                ? '${produto.nome} adicionado aos favoritos!' 
                                                : '${produto.nome} removido dos favoritos!'),
                                          ],
                                        ),
                                        backgroundColor: produto.favorito ? Colors.red.shade600 : Colors.orange.shade600,
                                      ),
                                    );
                                  } catch (e) {
                                    if (!mounted) return;
                                    messenger.showSnackBar(
                                      SnackBar(
                                        content: Row(
                                          children: [
                                            Icon(Icons.error, color: Colors.white),
                                            SizedBox(width: 8),
                                            Text('Erro ao atualizar favoritos'),
                                          ],
                                        ),
                                        backgroundColor: Colors.red.shade600,
                                      ),
                                    );
                                  }
                                }
                              },
                            );
                          },
                            );
                          },
                        ),
                      );
                },
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _handleLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Saída'),
        content: const Text('Tem certeza que deseja sair da sua conta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
    
    if (shouldLogout == true && mounted) {
      final navigator = Navigator.of(context);
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      navigator.pop();
      await userProvider.fazerLogout();
      if (mounted) {
        navigator.pushNamedAndRemoveUntil('/', (route) => false);
      }
    }
  }
}