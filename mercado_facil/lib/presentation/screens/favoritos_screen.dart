import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/produto.dart';
import '../../data/services/carrinho_provider.dart';
import '../widgets/produto_card.dart';
import '../../core/utils/snackbar_utils.dart';

class FavoritosScreen extends StatelessWidget {
  final List<Produto> produtos;
  const FavoritosScreen({super.key, required this.produtos});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final favoritos = produtos.where((p) => p.favorito).toList();
    
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
                  : GridView.builder(
                      padding: const EdgeInsets.only(bottom: 16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.8,
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
                          onToggleFavorito: () {
                            // Atualizar a tela quando remover dos favoritos
                            (context as Element).markNeedsBuild();
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

  void _adicionarTodosAoCarrinho(BuildContext context, List<Produto> favoritos) {
    final carrinhoProvider = Provider.of<CarrinhoProvider>(context, listen: false);
    
    // Adicionar todos os produtos favoritos ao carrinho
    for (final produto in favoritos) {
      carrinhoProvider.adicionarProduto(produto);
    }
    
    // Mostrar confirmação
    showAppSnackBar(
      context,
      '${favoritos.length} ${favoritos.length == 1 ? 'item adicionado' : 'itens adicionados'} ao carrinho!',
      icon: Icons.shopping_cart,
      backgroundColor: Colors.green.shade600,
      duration: const Duration(seconds: 3),
    );
    
    // Opcional: Navegar para o carrinho
    showDialog(
      context: context,
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