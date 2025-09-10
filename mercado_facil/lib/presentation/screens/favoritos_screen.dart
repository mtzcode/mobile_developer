import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/produto.dart';
import '../../data/services/carrinho_provider.dart';
import '../../data/services/user_provider.dart';
import '../../data/services/firestore_service.dart';
import '../widgets/produto_card.dart';
import '../../core/utils/snackbar_utils.dart';

class FavoritosScreen extends StatefulWidget {
  final List<Produto> produtos;
  const FavoritosScreen({super.key, required this.produtos});

  @override
  State<FavoritosScreen> createState() => _FavoritosScreenState();
}

class _FavoritosScreenState extends State<FavoritosScreen> {

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final favoritos = widget.produtos.where((p) => p.favorito).toList();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Favoritos'),
        centerTitle: true,
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          if (favoritos.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '${favoritos.length} ${favoritos.length == 1 ? 'item' : 'itens'}',
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Botão para adicionar todos ao carrinho
          if (favoritos.isNotEmpty)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                onPressed: () => _adicionarTodosAoCarrinho(context, favoritos),
                icon: const Icon(Icons.shopping_cart_outlined),
                label: Text('Adicionar todos ao carrinho (${favoritos.length} itens)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          
          // Lista de produtos favoritos
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: favoritos.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.favorite_border,
                            size: 80,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 24),
                          Text(
                            'Sua lista de favoritos está vazia',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Adicione produtos aos favoritos\npara criar sua lista de compras',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        // Calcula o número de colunas baseado na largura da tela
                        int crossAxisCount;
                        double childAspectRatio;
                        
                        if (constraints.maxWidth < 600) {
                          // Mobile: 2 colunas
                          crossAxisCount = 2;
                          childAspectRatio = 0.8;
                        } else if (constraints.maxWidth < 900) {
                          // Tablet: 3 colunas
                          crossAxisCount = 3;
                          childAspectRatio = 0.85;
                        } else if (constraints.maxWidth < 1200) {
                          // Desktop pequeno: 4 colunas
                          crossAxisCount = 4;
                          childAspectRatio = 0.9;
                        } else if (constraints.maxWidth < 1600) {
                          // Desktop médio: 5 colunas
                          crossAxisCount = 5;
                          childAspectRatio = 0.95;
                        } else {
                          // Desktop grande: 6 colunas
                          crossAxisCount = 6;
                          childAspectRatio = 1.0;
                        }
                        
                        return GridView.builder(
                          padding: const EdgeInsets.only(bottom: 16),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            childAspectRatio: childAspectRatio,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                      itemCount: favoritos.length,
                      itemBuilder: (context, index) {
                        final produto = favoritos[index];
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
                            final userProvider = Provider.of<UserProvider>(context, listen: false);
                            final userId = userProvider.usuarioLogado?.id;
                            final messenger = ScaffoldMessenger.of(context);
                            
                            if (userId != null) {
                              try {
                                final firestoreService = FirestoreService();
                                await firestoreService.removerFavorito(userId, produto.id);
                                
                                // Atualizar o estado local
                                if (!mounted) return;
                                setState(() {
                                  produto.favorito = false;
                                });
                                
                                messenger.showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        Icon(Icons.favorite_border, color: Colors.white),
                                        SizedBox(width: 8),
                                        Text('${produto.nome} removido dos favoritos!'),
                                      ],
                                    ),
                                    backgroundColor: Colors.orange.shade600,
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
                                        Text('Erro ao remover dos favoritos'),
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
            ),
          ),
        ],
      ),
    );
  }

  void _adicionarTodosAoCarrinho(BuildContext context, List<Produto> favoritos) async {
    final carrinhoProvider = Provider.of<CarrinhoProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.usuarioLogado?.id;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    
    // Adicionar todos os produtos favoritos ao carrinho
    for (final produto in favoritos) {
      carrinhoProvider.adicionarProduto(produto);
    }
    
    // Remover todos dos favoritos
    if (userId != null) {
      try {
        final firestoreService = FirestoreService();
        for (final produto in favoritos) {
          await firestoreService.removerFavorito(userId, produto.id);
          produto.favorito = false;
        }
        
        // Atualizar a tela
        if (!mounted) return;
        setState(() {});
      } catch (e) {
        // Se houver erro ao remover favoritos, apenas mostrar aviso
        if (!mounted) return;
        messenger.showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.warning, color: Colors.white),
                SizedBox(width: 8),
                Text('Itens adicionados ao carrinho, mas houve erro ao limpar favoritos'),
              ],
            ),
            backgroundColor: Colors.orange.shade600,
          ),
        );
        return;
      }
    }
    
    // Mostrar confirmação
    if (!mounted) return;
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.shopping_cart, color: Colors.white),
            SizedBox(width: 8),
            Text('${favoritos.length} ${favoritos.length == 1 ? 'item adicionado' : 'itens adicionados'} ao carrinho e removidos dos favoritos!'),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        duration: const Duration(seconds: 3),
      ),
    );
    
    // Opcional: Navegar para o carrinho
    showDialog(
      context: navigator.context,
      builder: (context) => AlertDialog(
        title: const Text('Itens Adicionados!'),
        content: Text(
          '${favoritos.length} ${favoritos.length == 1 ? 'item foi adicionado' : 'itens foram adicionados'} ao seu carrinho.\n\nDeseja ir para o carrinho agora?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continuar comprando'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Fechar dialog
              Navigator.pushNamed(context, '/carrinho');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Ir para carrinho'),
          ),
        ],
      ),
    );
  }
}