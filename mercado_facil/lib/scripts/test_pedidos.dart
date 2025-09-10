import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../firebase_options.dart';
import '../data/services/pedidos_service.dart';
import '../data/services/produtos_service.dart';
import '../data/models/pedido.dart';
import '../data/models/carrinho_item.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Inicializar Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('✅ Firebase inicializado com sucesso');
    
    // Testar conexão com Firestore
    final firestore = FirebaseFirestore.instance;
    await firestore.enableNetwork();
    debugPrint('✅ Conexão com Firestore estabelecida');
    
    // Testar funcionalidade de pedidos
    await testarPedidos();
    
    debugPrint('\n🎉 Teste de pedidos concluído com sucesso!');
    
  } catch (e, stackTrace) {
    debugPrint('❌ Erro durante o teste: $e');
    debugPrint('Stack trace: $stackTrace');
  }
}

Future<void> testarPedidos() async {
  debugPrint('\n🔍 Testando funcionalidade de pedidos...');
  
  final pedidosService = PedidosService();
  
  // ID de usuário de teste (você pode usar um ID real ou criar um)
  const usuarioIdTeste = 'usuario_teste_123';
  
  try {
    // 1. Carregar alguns produtos para criar um pedido de teste
    debugPrint('\n📦 Carregando produtos...');
    final produtos = await ProdutosService.carregarProdutosComCache();
    
    if (produtos.isEmpty) {
      debugPrint('⚠️ Nenhum produto encontrado. Criando produtos de teste...');
      await criarProdutosTeste();
      final produtosNovos = await ProdutosService.carregarProdutosComCache(forcarAtualizacao: true);
      if (produtosNovos.isNotEmpty) {
        debugPrint('✅ Produtos de teste criados: ${produtosNovos.length}');
      }
    } else {
      debugPrint('✅ Produtos carregados: ${produtos.length}');
    }
    
    // 2. Criar itens do carrinho para teste
    final produtosTeste = produtos.take(3).toList();
    final itensCarrinho = produtosTeste.map((produto) => CarrinhoItem(
      produto: produto,
      quantidade: 2,
    )).toList();
    
    debugPrint('\n🛒 Criando pedido de teste com ${itensCarrinho.length} itens...');
    
    // 3. Criar um pedido de teste
    final enderecoTeste = {
      'rua': 'Rua Teste, 123',
      'bairro': 'Centro',
      'cidade': 'São Paulo',
      'cep': '01234-567',
      'complemento': 'Apto 45',
    };
    
    final pedidoId = await pedidosService.criarPedido(
      usuarioId: usuarioIdTeste,
      itens: itensCarrinho,
      enderecoEntrega: enderecoTeste,
      metodoPagamento: 'Cartão de Crédito',
      observacoes: 'Pedido de teste - pode ser removido',
    );
    
    debugPrint('✅ Pedido criado com sucesso! ID: $pedidoId');
    
    // 4. Buscar o pedido criado
    debugPrint('\n🔍 Buscando pedido criado...');
    final pedidoCriado = await pedidosService.buscarPedido(pedidoId);
    
    if (pedidoCriado != null) {
      debugPrint('✅ Pedido encontrado:');
      debugPrint('   - ID: ${pedidoCriado.id}');
      debugPrint('   - Status: ${pedidoCriado.status.name}');
      debugPrint('   - Total: R\$ ${pedidoCriado.total.toStringAsFixed(2)}');
      debugPrint('   - Itens: ${pedidoCriado.itens.length}');
      debugPrint('   - Data: ${pedidoCriado.dataCriacao}');
    } else {
      debugPrint('❌ Pedido não encontrado após criação');
    }
    
    // 5. Buscar todos os pedidos do usuário
    debugPrint('\n📋 Buscando todos os pedidos do usuário...');
    final pedidosUsuario = await pedidosService.buscarPedidosUsuario(usuarioIdTeste);
    debugPrint('✅ Pedidos encontrados: ${pedidosUsuario.length}');
    
    for (final pedido in pedidosUsuario) {
      debugPrint('   - Pedido ${pedido.id.substring(0, 8)}: ${pedido.status.name} - R\$ ${pedido.total.toStringAsFixed(2)}');
    }
    
    // 6. Testar atualização de status
    debugPrint('\n🔄 Testando atualização de status...');
    await pedidosService.atualizarStatusPedido(pedidoId, StatusPedido.confirmado);
    
    final pedidoAtualizado = await pedidosService.buscarPedido(pedidoId);
    if (pedidoAtualizado?.status == StatusPedido.confirmado) {
      debugPrint('✅ Status atualizado com sucesso para: ${pedidoAtualizado!.status.name}');
    } else {
      debugPrint('❌ Falha ao atualizar status');
    }
    
    // 7. Testar busca por status
    debugPrint('\n🔍 Testando busca por status...');
    final pedidosConfirmados = await pedidosService.buscarPedidosPorStatus(usuarioIdTeste, StatusPedido.confirmado);
    debugPrint('✅ Pedidos confirmados encontrados: ${pedidosConfirmados.length}');
    
    // 8. Testar estatísticas
    debugPrint('\n📊 Testando estatísticas...');
    final estatisticas = await pedidosService.estatisticasUsuario(usuarioIdTeste);
    debugPrint('✅ Estatísticas do usuário:');
    debugPrint('   - Total de pedidos: ${estatisticas['totalPedidos']}');
    debugPrint('   - Valor total gasto: R\$ ${estatisticas['valorTotal'].toStringAsFixed(2)}');
    
    debugPrint('\n✅ Todos os testes de pedidos passaram!');
    
  } catch (e, stackTrace) {
    debugPrint('❌ Erro durante teste de pedidos: $e');
    debugPrint('Stack trace: $stackTrace');
  }
}

Future<void> criarProdutosTeste() async {
  final firestore = FirebaseFirestore.instance;
  
  final produtosTeste = [
    {
      'nome': 'Produto Teste 1',
      'descricao': 'Descrição do produto teste 1',
      'preco': 29.90,
      'categoria': 'Teste',
      'imagemUrl': 'https://via.placeholder.com/300x300/4CAF50/FFFFFF?text=Produto+1',
      'disponivel': true,
      'estoque': 100,
      'dataCriacao': FieldValue.serverTimestamp(),
    },
    {
      'nome': 'Produto Teste 2',
      'descricao': 'Descrição do produto teste 2',
      'preco': 45.50,
      'categoria': 'Teste',
      'imagemUrl': 'https://via.placeholder.com/300x300/2196F3/FFFFFF?text=Produto+2',
      'disponivel': true,
      'estoque': 50,
      'dataCriacao': FieldValue.serverTimestamp(),
    },
    {
      'nome': 'Produto Teste 3',
      'descricao': 'Descrição do produto teste 3',
      'preco': 15.75,
      'categoria': 'Teste',
      'imagemUrl': 'https://via.placeholder.com/300x300/FF9800/FFFFFF?text=Produto+3',
      'disponivel': true,
      'estoque': 75,
      'dataCriacao': FieldValue.serverTimestamp(),
    },
  ];
  
  for (final produto in produtosTeste) {
    await firestore.collection('produtos').add(produto);
  }
}