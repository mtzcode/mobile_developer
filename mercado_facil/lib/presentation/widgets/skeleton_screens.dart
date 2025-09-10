import 'package:flutter/material.dart';
import 'loading_components.dart';

export 'loading_components.dart';

/// Skeleton screens padronizados para o app
class SkeletonScreens {
  /// Skeleton para card de produto
  static Widget productCard({
    double height = 280.0,
    double imageHeight = 120.0,
  }) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Skeleton da imagem
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            child: LoadingComponents.imageSkeleton(
              height: imageHeight,
              borderRadius: 0,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Skeleton do nome (2 linhas)
                LoadingComponents.textSkeleton(
                  height: 16,
                  width: double.infinity,
                ),
                const SizedBox(height: 8),
                LoadingComponents.textSkeleton(
                  height: 16,
                  width: 120,
                ),
                const SizedBox(height: 12),
                // Skeleton do preço
                LoadingComponents.textSkeleton(
                  height: 20,
                  width: 80,
                ),
                const SizedBox(height: 16),
                // Skeleton do botão
                LoadingComponents.buttonSkeleton(
                  height: 40,
                  borderRadius: 8,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Skeleton para lista de produtos
  static Widget productList({
    int itemCount = 6,
    int crossAxisCount = 2,
    double childAspectRatio = 0.8,
  }) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) => productCard(),
    );
  }

  /// Skeleton para item de carrinho
  static Widget cartItem({
    double height = 100.0,
  }) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Skeleton da imagem
          LoadingComponents.imageSkeleton(
            height: 60,
            width: 60,
            borderRadius: 8,
          ),
          const SizedBox(width: 16),
          // Skeleton do conteúdo
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LoadingComponents.textSkeleton(
                  height: 16,
                  width: double.infinity,
                ),
                const SizedBox(height: 8),
                LoadingComponents.textSkeleton(
                  height: 14,
                  width: 100,
                ),
                const SizedBox(height: 8),
                LoadingComponents.textSkeleton(
                  height: 16,
                  width: 80,
                ),
              ],
            ),
          ),
          // Skeleton dos controles
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LoadingComponents.buttonSkeleton(
                height: 32,
                width: 80,
                borderRadius: 16,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Skeleton para lista de carrinho
  static Widget cartList({
    int itemCount = 3,
  }) {
    return ListView.builder(
      itemCount: itemCount,
      itemBuilder: (context, index) => cartItem(),
    );
  }

  /// Skeleton para item de pedido
  static Widget orderItem({
    double height = 120.0,
  }) {
    return Container(
      height: height,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Skeleton do cabeçalho
          Row(
            children: [
              LoadingComponents.textSkeleton(
                height: 16,
                width: 100,
              ),
              const Spacer(),
              LoadingComponents.textSkeleton(
                height: 16,
                width: 80,
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Skeleton do status
          LoadingComponents.textSkeleton(
            height: 14,
            width: 120,
          ),
          const SizedBox(height: 12),
          // Skeleton dos itens
          LoadingComponents.textSkeleton(
            height: 14,
            width: double.infinity,
          ),
          const SizedBox(height: 8),
          LoadingComponents.textSkeleton(
            height: 14,
            width: 200,
          ),
        ],
      ),
    );
  }

  /// Skeleton para lista de pedidos
  static Widget orderList({
    int itemCount = 5,
  }) {
    return ListView.builder(
      itemCount: itemCount,
      itemBuilder: (context, index) => orderItem(),
    );
  }

  /// Skeleton para perfil do usuário
  static Widget userProfile({
    double height = 200.0,
  }) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Skeleton do avatar
          LoadingComponents.imageSkeleton(
            height: 80,
            width: 80,
            borderRadius: 40,
          ),
          const SizedBox(height: 16),
          // Skeleton do nome
          LoadingComponents.textSkeleton(
            height: 20,
            width: 150,
          ),
          const SizedBox(height: 8),
          // Skeleton do email
          LoadingComponents.textSkeleton(
            height: 16,
            width: 200,
          ),
          const SizedBox(height: 24),
          // Skeleton dos botões
          Row(
            children: [
              Expanded(
                child: LoadingComponents.buttonSkeleton(
                  height: 48,
                  borderRadius: 8,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: LoadingComponents.buttonSkeleton(
                  height: 48,
                  borderRadius: 8,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Skeleton para formulário
  static Widget form({
    int fieldCount = 4,
    double fieldHeight = 56.0,
  }) {
    return Column(
      children: List.generate(fieldCount, (index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Skeleton do label
              LoadingComponents.textSkeleton(
                height: 14,
                width: 80,
              ),
              const SizedBox(height: 8),
              // Skeleton do campo
              LoadingComponents.textSkeleton(
                height: fieldHeight,
                width: double.infinity,
                borderRadius: 8,
              ),
            ],
          ),
        );
      }),
    );
  }

  /// Skeleton para detalhes de pedido
  static Widget orderDetails() {
    return Column(
      children: [
        // Skeleton do status
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              LoadingComponents.textSkeleton(
                height: 20,
                width: 120,
              ),
              const SizedBox(height: 8),
              LoadingComponents.textSkeleton(
                height: 16,
                width: 100,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Skeleton dos itens
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LoadingComponents.textSkeleton(
                height: 18,
                width: 100,
              ),
              const SizedBox(height: 16),
              // Skeleton dos itens
              ...List.generate(3, (index) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    LoadingComponents.imageSkeleton(
                      height: 50,
                      width: 50,
                      borderRadius: 8,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          LoadingComponents.textSkeleton(
                            height: 16,
                            width: double.infinity,
                          ),
                          const SizedBox(height: 4),
                          LoadingComponents.textSkeleton(
                            height: 14,
                            width: 80,
                          ),
                        ],
                      ),
                    ),
                    LoadingComponents.textSkeleton(
                      height: 16,
                      width: 60,
                    ),
                  ],
                ),
              )),
            ],
          ),
        ),
      ],
    );
  }

  /// Skeleton para busca
  static Widget searchBar({
    double height = 56.0,
  }) {
    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: Colors.grey.shade400),
          const SizedBox(width: 12),
          Expanded(
            child: LoadingComponents.textSkeleton(
              height: 20,
              width: 200,
            ),
          ),
        ],
      ),
    );
  }

  /// Skeleton para categorias
  static Widget categories({
    int itemCount = 6,
  }) {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(right: 12),
            child: LoadingComponents.buttonSkeleton(
              height: 40,
              width: 80,
              borderRadius: 20,
            ),
          );
        },
      ),
    );
  }

  /// Skeleton para página completa
  static Widget page({
    String? title,
    Widget? content,
  }) {
    return Scaffold(
      appBar: AppBar(
        title: title != null 
          ? Text(title)
          : LoadingComponents.textSkeleton(
              height: 20,
              width: 120,
            ),
      ),
      body: content ?? 
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              searchBar(),
              const SizedBox(height: 16),
              categories(),
              const SizedBox(height: 16),
              Expanded(
                child: productList(),
              ),
            ],
          ),
        ),
    );
  }
}

/// Widget wrapper para skeleton screens
class SkeletonWrapper extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final Widget? skeletonWidget;

  const SkeletonWrapper({
    super.key,
    required this.isLoading,
    required this.child,
    this.skeletonWidget,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return skeletonWidget ?? 
        SkeletonScreens.page();
    }
    return child;
  }
}