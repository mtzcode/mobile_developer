import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/models/produto.dart';

class ProdutoCard extends StatelessWidget {
  final Produto produto;
  final VoidCallback? onAdicionarAoCarrinho;
  final VoidCallback? onToggleFavorito;

  const ProdutoCard({
    super.key,
    required this.produto,
    this.onAdicionarAoCarrinho,
    this.onToggleFavorito,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    // Função para abrir modal de detalhes do produto
    void showProductModal() {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (context) => Padding(
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
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: produto.imagemUrl,
                    height: 180,
                    width: 180,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 180,
                      width: 180,
                      color: colorScheme.tertiary.withValues(alpha: 0.1),
                      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 180,
                      width: 180,
                      color: colorScheme.tertiary.withValues(alpha: 0.15),
                      child: Icon(Icons.image, color: colorScheme.tertiary, size: 60),
                    ),
                    memCacheWidth: 400,
                    memCacheHeight: 400,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                produto.nome,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              if (produto.precoPromocional != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'R\$ \${produto.preco.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'R\$ \${produto.precoPromocional!.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                )
              else
                Text(
                  'R\$ \${produto.preco.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 16),
              if (produto.descricao != null && produto.descricao!.isNotEmpty)
                Text(
                  produto.descricao!,
                  style: const TextStyle(fontSize: 15, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: onAdicionarAoCarrinho,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Adicionar ao Carrinho'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: showProductModal,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: produto.imagemUrl.isNotEmpty
                        ? Image.network(
                            produto.imagemUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Center(
                              child: Icon(Icons.image, color: colorScheme.primary, size: 32),
                            ),
                          )
                        : Center(
                            child: Icon(Icons.image, color: colorScheme.primary, size: 32),
                          ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  produto.nome,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: colorScheme.onSurface,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                // Preços com ícone
                Row(
                  children: [
                    Icon(
                      Icons.attach_money_rounded,
                      size: 18,
                      color: produto.precoPromocional != null
                          ? Colors.green.shade600
                          : colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    if (produto.precoPromocional != null) ..[
                      Text(
                        'R\$ \${produto.preco.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                          color: Colors.grey.shade600,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'R\$ \${produto.precoPromocional!.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: Colors.green.shade600,
                        ),
                      ),
                    ] else ..[
                      Text(
                        'R\$ \${produto.preco.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onAdicionarAoCarrinho,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      shadowColor: colorScheme.primary.withValues(alpha: 0.3),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_shopping_cart_rounded, size: 18, color: Colors.white),
                        const SizedBox(width: 8),
                        const Text(
                          'Adicionar',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Tag de destaque alinhada à borda do card (fora da imagem)
            if (produto.destaque != null)
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  height: 22,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: produto.destaque == 'oferta'
                        ? Colors.red.shade800
                        : produto.destaque == 'mais vendido'
                            ? Colors.orange.shade800
                            : Colors.blue.shade800,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                  ),
                  child: Text(
                    produto.destaque == 'oferta'
                        ? 'OFERTA'
                        : produto.destaque == 'mais vendido'
                            ? 'MAIS VENDIDO'
                            : 'NOVO',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            // Ícone de favoritos alinhado à borda do card (fora da imagem)
            if (onToggleFavorito != null)
              Positioned(
                top: 10,
                right: 10,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: onToggleFavorito,
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: Icon(
                        produto.favorito == true
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: produto.favorito == true
                            ? Colors.red.shade800
                            : Colors.grey.shade400,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ProdutoCardSkeleton extends StatelessWidget {
  const ProdutoCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 16,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 14,
            width: 80,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 40,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ],
      ),
    );
  }
}