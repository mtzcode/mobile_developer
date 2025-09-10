import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/models/produto.dart';
import '../../core/theme/app_theme.dart';
import 'const_widgets.dart';

/// Versão otimizada do ProdutoCard que evita rebuilds desnecessários
class OptimizedProdutoCard extends StatelessWidget {
  final Produto produto;
  final VoidCallback? onAdicionarAoCarrinho;
  final VoidCallback? onToggleFavorito;
  final VoidCallback? onTap;

  const OptimizedProdutoCard({
    super.key,
    required this.produto,
    this.onAdicionarAoCarrinho,
    this.onToggleFavorito,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isOferta = produto.destaque == 'oferta';
    final isMaisVendido = produto.destaque == 'mais vendido';
    final isNovo = produto.destaque == 'novo';
    
    return Semantics(
      label: 'Produto: ${produto.nome}. Preço: R\$${(produto.precoPromocional ?? produto.preco).toStringAsFixed(2)}.'
        '${isOferta ? ' Em oferta.' : ''}'
        '${isMaisVendido ? ' Mais vendido.' : ''}'
        '${isNovo ? ' Novo.' : ''}',
      child: GestureDetector(
        onTap: onTap ?? () {
          _showProductModal(context, colorScheme);
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: ConstWidgets.borderRadius16,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Imagem otimizada
                  _buildProductImage(colorScheme),
                  
                  // Conteúdo do produto
                  Padding(
                    padding: ConstWidgets.horizontalPadding14,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildProductName(colorScheme),
                        ConstWidgets.height8,
                        _buildProductPrice(colorScheme),
                        ConstWidgets.height8,
                        _buildAddToCartButton(),
                      ],
                    ),
                  ),
                ],
              ),
              
              // Badge de destaque
              if (produto.destaque != null) _buildDestaqueBadge(),
              
              // Botão de favorito
              _buildFavoriteButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductImage(ColorScheme colorScheme) {
    return Semantics(
      label: 'Imagem do produto ${produto.nome}',
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        child: CachedNetworkImage(
          imageUrl: produto.imagemUrl,
          height: 110,
          width: double.infinity,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            height: 110,
            color: colorScheme.tertiary.withValues(alpha: 0.1),
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(colorScheme.tertiary),
              ),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            height: 110,
            color: colorScheme.tertiary.withValues(alpha: 0.15),
            child: Center(
              child: ConstWidgets.imageIcon,
            ),
          ),
          memCacheWidth: 300,
          memCacheHeight: 200,
        ),
      ),
    );
  }

  Widget _buildProductName(ColorScheme colorScheme) {
    return Semantics(
      header: true,
      child: Text(
        produto.nome,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: colorScheme.secondary,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildProductPrice(ColorScheme colorScheme) {
    if (produto.precoPromocional != null) {
      return Row(
        children: [
          Semantics(
            label: 'Preço original R\$${produto.preco.toStringAsFixed(2)}',
            child: Text(
              'R\$ ${produto.preco.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
                decoration: TextDecoration.lineThrough,
              ),
            ),
          ),
          ConstWidgets.width8,
          Semantics(
            label: 'Preço promocional R\$${produto.precoPromocional!.toStringAsFixed(2)}',
            child: Text(
              'R\$ ${produto.precoPromocional!.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade800,
              ),
            ),
          ),
        ],
      );
    }
    
    return Semantics(
      label: 'Preço R\$${produto.preco.toStringAsFixed(2)}',
      child: Text(
        'R\$ ${produto.preco.toStringAsFixed(2)}',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildAddToCartButton() {
    return Semantics(
      button: true,
      label: 'Adicionar ${produto.nome} ao carrinho',
      child: SizedBox(
        width: double.infinity,
        height: 36,
        child: ElevatedButton(
          onPressed: onAdicionarAoCarrinho,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.produtoButtonColor,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: ConstWidgets.borderRadius10,
            ),
            textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            padding: ConstWidgets.verticalPadding10,
          ),
          child: ConstWidgets.addToCartText,
        ),
      ),
    );
  }

  Widget _buildDestaqueBadge() {
    Widget badge;
    
    switch (produto.destaque) {
      case 'oferta':
        badge = ProductConstWidgets.buildOfertaBadge();
        break;
      case 'mais vendido':
        badge = ProductConstWidgets.buildMaisVendidoBadge();
        break;
      case 'novo':
        badge = ProductConstWidgets.buildNovoBadge();
        break;
      default:
        return ConstWidgets.shrink;
    }
    
    return Positioned(
      left: 0,
      top: 0,
      child: Semantics(
        label: produto.destaque == 'oferta'
            ? 'Produto em oferta'
            : produto.destaque == 'mais vendido'
                ? 'Produto mais vendido'
                : 'Produto novo',
        child: badge,
      ),
    );
  }

  Widget _buildFavoriteButton() {
    return Positioned(
      right: 8,
      top: 8,
      child: GestureDetector(
        onTap: onToggleFavorito,
        child: Semantics(
          label: produto.favorito ? 'Remover dos favoritos' : 'Adicionar aos favoritos',
          button: true,
          child: Icon(
            produto.favorito ? Icons.favorite : Icons.favorite_border,
            color: produto.favorito ? Colors.red : Colors.grey.shade400,
            size: 28,
          ),
        ),
      ),
    );
  }

  void _showProductModal(BuildContext context, ColorScheme colorScheme) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _ProductModal(
        produto: produto,
        colorScheme: colorScheme,
        onAdicionarAoCarrinho: onAdicionarAoCarrinho,
      ),
    );
  }
}

/// Widget separado para o modal do produto (evita rebuilds)
class _ProductModal extends StatelessWidget {
  final Produto produto;
  final ColorScheme colorScheme;
  final VoidCallback? onAdicionarAoCarrinho;

  const _ProductModal({
    required this.produto,
    required this.colorScheme,
    this.onAdicionarAoCarrinho,
  });

  @override
  Widget build(BuildContext context) {
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
          Center(
            child: ClipRRect(
              borderRadius: ConstWidgets.borderRadius12,
              child: CachedNetworkImage(
                imageUrl: produto.imagemUrl,
                height: 180,
                width: 180,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 180,
                  width: 180,
                  color: colorScheme.tertiary.withValues(alpha: 0.1),
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(colorScheme.tertiary),
                    ),
                  ),
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
          ConstWidgets.height18,
          Text(
            produto.nome,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          ConstWidgets.height8,
          _buildModalPrice(),
          ConstWidgets.height16,
          if (produto.descricao != null && produto.descricao!.isNotEmpty)
            Text(
              produto.descricao!,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
          ConstWidgets.height24,
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: onAdicionarAoCarrinho,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.produtoButtonColor,
                foregroundColor: Colors.white,
                textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: ConstWidgets.borderRadius12,
                ),
              ),
              child: ConstWidgets.addToCartFullText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModalPrice() {
    if (produto.precoPromocional != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'R\$ ${produto.preco.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
              decoration: TextDecoration.lineThrough,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'R\$ ${produto.precoPromocional!.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
        ],
      );
    }
    
    return Text(
      'R\$ ${produto.preco.toStringAsFixed(2)}',
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: colorScheme.primary,
      ),
      textAlign: TextAlign.center,
    );
  }
}