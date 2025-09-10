import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/produto.dart';
import '../../data/services/carrinho_provider.dart';
import '../widgets/produto_card.dart';
import '../../core/utils/snackbar_utils.dart';

class OfertasScreen extends StatelessWidget {
  final List<Produto> produtos;
  const OfertasScreen({super.key, required this.produtos});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final ofertas = produtos.where((p) => p.destaque?.toLowerCase() == 'oferta').toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ofertas'),
        centerTitle: true,
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ofertas.isEmpty
            ? const Center(child: Text('Nenhum produto em oferta.'))
            : GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.8,
                  crossAxisSpacing: 24,
                  mainAxisSpacing: 24,
                ),
                itemCount: ofertas.length,
                itemBuilder: (context, index) {
                  final produto = ofertas[index];
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
                      (context as Element).markNeedsBuild();
                      produto.favorito = !produto.favorito;
                    },
                  );
                },
              ),
      ),
    );
  }
}