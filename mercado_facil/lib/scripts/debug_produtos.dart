import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import '../data/services/firestore_service.dart';
import '../data/services/produtos_service.dart';
import '../firebase_options.dart';

/// Função principal para executar o script de debug
void main() async {
  // Inicializar Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Executar debug
  await debugProdutos();
}

/// Script para debugar o carregamento de produtos
Future<void> debugProdutos() async {
  try {
    debugPrint('🔍 Iniciando debug de produtos...');
    
    // Teste 1: Verificar conexão com Firestore
    debugPrint('\n1. Testando conexão com Firestore...');
    final firestoreService = FirestoreService();
    
    try {
      final produtosFirestore = await firestoreService.getProdutos();
      debugPrint('✅ Firestore conectado - ${produtosFirestore.length} produtos encontrados');
      
      if (produtosFirestore.isNotEmpty) {
        debugPrint('Primeiros produtos do Firestore:');
        for (var produto in produtosFirestore.take(3)) {
          debugPrint('  - ${produto.nome}: R\$ ${produto.preco}');
        }
      } else {
        debugPrint('⚠️ Nenhum produto encontrado no Firestore');
      }
    } catch (e) {
      debugPrint('❌ Erro ao conectar com Firestore: $e');
    }
    
    // Teste 2: Verificar ProdutosService
    debugPrint('\n2. Testando ProdutosService...');
    try {
      final produtosService = await ProdutosService.carregarProdutosComCache(forcarAtualizacao: true);
      debugPrint('✅ ProdutosService - ${produtosService.length} produtos carregados');
      
      if (produtosService.isNotEmpty) {
        debugPrint('Primeiros produtos do Service:');
        for (var produto in produtosService.take(3)) {
          debugPrint('  - ${produto.nome}: R\$ ${produto.preco}');
        }
      } else {
        debugPrint('⚠️ ProdutosService retornou lista vazia');
      }
    } catch (e) {
      debugPrint('❌ Erro no ProdutosService: $e');
    }
    
    // Teste 3: Verificar dados mock
    debugPrint('\n3. Testando dados mock...');
    final produtosMock = ProdutosService.getProdutosMock();
    debugPrint('✅ Dados mock - ${produtosMock.length} produtos disponíveis');
    
    debugPrint('\n🎯 Debug concluído!');
    
  } catch (e, stackTrace) {
    debugPrint('❌ Erro geral no debug: $e');
    debugPrint('Stack trace: $stackTrace');
  }
}