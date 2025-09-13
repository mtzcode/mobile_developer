import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/produto.dart';
import '../../data/services/carrinho_provider.dart';
import '../../data/services/user_provider.dart';
import '../../data/services/firestore_service.dart';
import '../widgets/produto_card.dart';
import '../../core/utils/snackbar_utils.dart';

class OfertasScreen extends StatefulWidget {
  final List<Produto> produtos;
  const OfertasScreen({super.key, required this.produtos});

  @override
  State<OfertasScreen> createState() => _OfertasScreenState();
}

class _OfertasScreenState extends State<OfertasScreen> {

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    // Filtrar ofertas com lógica mais abrangente
    final ofertas = widget.produtos.where((p) {
      // Verifica se tem destaque 'oferta' (case insensitive)
      final temDestaqueOferta = p.destaque?.toLowerCase() == 'oferta';
      // Verifica se está em promoção (tem preço promocional)
      final temPromocao = p.precoPromocional != null && p.precoPromocional! < p.preco;
      // Verifica se tem desconto significativo
      final temDesconto = p.precoPromocional != null && p.precoPromocional! > 0;
      
      return temDestaqueOferta || temPromocao || temDesconto;
    }).toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ofertas'),
        centerTitle: true,
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: widget.produtos.isEmpty
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Carregando ofertas...')
                  ],
                ),
              )
            : ofertas.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.local_offer_outlined, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'Nenhuma oferta disponível no momento',
                          style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Volte em breve para conferir nossas promoções!',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  )
                : LayoutBuilder(
                builder: (context, constraints) {
                  int crossAxisCount;
                  double childAspectRatio;
                  
                  if (constraints.maxWidth < 600) {
                    // Mobile: 2 colunas
                    crossAxisCount = 2;
                    childAspectRatio = 0.8;
                  } else if (constraints.maxWidth < 900) {
                    // Tablet: 3 colunas
                    crossAxisCount = 3;
                    childAspectRatio = 0.75;
                  } else if (constraints.maxWidth < 1200) {
                    // Desktop pequeno: 4 colunas
                    crossAxisCount = 4;
                    childAspectRatio = 0.7;
                  } else {
                    // Desktop grande: 6 colunas
                    crossAxisCount = 6;
                    childAspectRatio = 0.65;
                  }
                  
                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      childAspectRatio: childAspectRatio,
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
                    onToggleFavorito: () async {
                      final userProvider = Provider.of<UserProvider>(context, listen: false);
                      final userId = userProvider.usuarioLogado?.id;
                      final messenger = ScaffoldMessenger.of(context);
                      
                      if (userId != null) {
                        try {
                          final firestoreService = FirestoreService();
                          
                          if (produto.favorito) {
                            await firestoreService.removerFavorito(userId, produto.id);
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
                          } else {
                            await firestoreService.adicionarFavorito(userId, produto.id);
                            if (!mounted) return;
                            setState(() {
                              produto.favorito = true;
                            });
                            messenger.showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    Icon(Icons.favorite, color: Colors.white),
                                    SizedBox(width: 8),
                                    Text('${produto.nome} adicionado aos favoritos!'),
                                  ],
                                ),
                                backgroundColor: Colors.red.shade600,
                              ),
                            );
                          }
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
      ),
    );
  }
}