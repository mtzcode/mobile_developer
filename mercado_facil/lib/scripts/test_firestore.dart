import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../firebase_options.dart';
import '../data/services/produtos_service.dart';

/// Script para testar conexão com Firestore e popular dados se necessário
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    debugPrint('Inicializando Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('Firebase inicializado com sucesso!');
    
    // Testar conexão com Firestore
    final firestore = FirebaseFirestore.instance;
    debugPrint('Testando conexão com Firestore...');
    
    // Verificar produtos existentes
    final produtosSnapshot = await firestore.collection('produtos').get();
    debugPrint('Produtos encontrados no Firestore: ${produtosSnapshot.docs.length}');
    
    if (produtosSnapshot.docs.isEmpty) {
      debugPrint('Nenhum produto encontrado. Populando com dados mock...');
      
      // Popular com dados mock
      await ProdutosService.migrarDadosMock();
      
      // Verificar novamente
      final novoSnapshot = await firestore.collection('produtos').get();
      debugPrint('Produtos adicionados: ${novoSnapshot.docs.length}');
      
      // Mostrar alguns produtos
      for (var doc in novoSnapshot.docs.take(3)) {
        final data = doc.data();
        debugPrint('Produto: ${data['nome']} - R\$ ${data['preco']}');
      }
    } else {
      debugPrint('Produtos já existem no Firestore:');
      for (var doc in produtosSnapshot.docs.take(3)) {
        final data = doc.data();
        debugPrint('Produto: ${data['nome']} - R\$ ${data['preco']}');
      }
    }
    
    // Testar carregamento através do serviço
    debugPrint('\nTestando ProdutosService...');
    final produtos = await ProdutosService.carregarProdutosComCache(forcarAtualizacao: true);
    debugPrint('Produtos carregados pelo serviço: ${produtos.length}');
    
    if (produtos.isNotEmpty) {
      debugPrint('Primeiros 3 produtos:');
      for (var produto in produtos.take(3)) {
        debugPrint('- ${produto.nome}: R\$ ${produto.preco}');
      }
    }
    
    debugPrint('\nTeste concluído com sucesso!');
    
  } catch (e, stackTrace) {
    debugPrint('Erro durante o teste: $e');
    debugPrint('Stack trace: $stackTrace');
  }
}