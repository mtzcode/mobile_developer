import 'package:flutter/material.dart';

/// Widgets const otimizados para reutilização
class ConstWidgets {
  // Espaçamentos
  static const SizedBox height8 = SizedBox(height: 8);
  static const SizedBox height16 = SizedBox(height: 16);
  static const SizedBox height24 = SizedBox(height: 24);
  static const SizedBox height32 = SizedBox(height: 32);
  static const SizedBox height18 = SizedBox(height: 18);
  
  static const SizedBox width8 = SizedBox(width: 8);
  static const SizedBox width12 = SizedBox(width: 12);
  static const SizedBox width16 = SizedBox(width: 16);
  
  // Ícones
  static const Icon searchIcon = Icon(Icons.search, color: Color(0xFF003938));
  static const Icon menuIcon = Icon(Icons.menu);
  static const Icon cartIcon = Icon(Icons.shopping_cart);
  static const Icon personIcon = Icon(Icons.person);
  static const Icon locationIcon = Icon(Icons.location_on);
  static const Icon favoriteIcon = Icon(Icons.favorite);
  static const Icon favoriteBorderIcon = Icon(Icons.favorite_border);
  static const Icon imageIcon = Icon(Icons.image);
  static const Icon cloudDoneIcon = Icon(Icons.cloud_done);
  static const Icon cloudOffIcon = Icon(Icons.cloud_off);
  
  // Textos comuns
  static const Text addToCartText = Text('Adicionar');
  static const Text addToCartFullText = Text('Adicionar ao carrinho');
  static const Text closeText = Text('Fechar');
  static const Text updateText = Text('Atualizar');
  static const Text productsText = Text('Produtos');
  static const Text myDataText = Text('Meus Dados');
  static const Text addressesText = Text('Endereços');
  static const Text ordersText = Text('Pedidos');
  static const Text logoutText = Text('Sair');
  
  // Containers e decorações
  static const BorderRadius borderRadius16 = BorderRadius.all(Radius.circular(16));
  static const BorderRadius borderRadius12 = BorderRadius.all(Radius.circular(12));
  static const BorderRadius borderRadius10 = BorderRadius.all(Radius.circular(10));
  static const BorderRadius borderRadius8 = BorderRadius.all(Radius.circular(8));
  
  static const EdgeInsets padding16 = EdgeInsets.all(16);
  static const EdgeInsets padding20 = EdgeInsets.all(20);
  static const EdgeInsets padding24 = EdgeInsets.all(24);
  static const EdgeInsets horizontalPadding14 = EdgeInsets.symmetric(horizontal: 14);
  static const EdgeInsets verticalPadding10 = EdgeInsets.symmetric(vertical: 10);
  static const EdgeInsets horizontalPadding8 = EdgeInsets.symmetric(horizontal: 8);
  static const EdgeInsets horizontalPadding12 = EdgeInsets.symmetric(horizontal: 12);
  static const EdgeInsets verticalPadding6 = EdgeInsets.symmetric(vertical: 6);
  
  // Cores
  static const Color greyColor = Colors.grey;
  static const Color redColor = Colors.red;
  static const Color whiteColor = Colors.white;
  static const Color blackColor = Colors.black;
  
  // Estilos de texto
  static const TextStyle boldTextStyle = TextStyle(fontWeight: FontWeight.bold);
  static const TextStyle greyTextStyle = TextStyle(color: Colors.grey);
  static const TextStyle redBoldTextStyle = TextStyle(
    fontWeight: FontWeight.bold,
    color: Colors.red,
  );
  
  // Widgets compostos
  static const Center centerWidget = Center();
  // Remover expandedWidget pois Expanded precisa de child obrigatório.
  
  // Loading indicators
  static const CircularProgressIndicator circularProgress = CircularProgressIndicator();
  
  // Shrink widgets
  static const SizedBox shrink = SizedBox.shrink();
}

/// Widgets const específicos para produtos
class ProductConstWidgets {
  // Badges de destaque
  static Widget buildOfertaBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: const BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: const Text(
        'OFERTA',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 11,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
  
  static Widget buildMaisVendidoBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: const BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: const Text(
        'MAIS VENDIDO',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 11,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
  
  static Widget buildNovoBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: const BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: const Text(
        'NOVO',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 11,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
} 