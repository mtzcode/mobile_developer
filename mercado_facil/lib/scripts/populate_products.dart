import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';
import '../data/services/migration_service.dart';

/// Script para popular o Firestore com produtos de teste
/// 
/// Este script adiciona produtos de teste diretamente no Firestore
/// para facilitar o desenvolvimento e testes.
/// 
/// Uso: dart run lib/scripts/populate_products.dart

Future<void> main() async {
  try {
    // Inicializando Firebase...
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // Firebase inicializado

    final migrationService = MigrationService();
    
    // Verificando produtos existentes...
    final firestore = FirebaseFirestore.instance;
    final produtosSnapshot = await firestore.collection('produtos').get();
    
    if (produtosSnapshot.docs.isNotEmpty) {
      // Já existem ${produtosSnapshot.docs.length} produtos no Firestore
      // Limpando produtos existentes...
      await migrationService.limparProdutos();
      // Produtos existentes removidos
    }
    
    // Migrando produtos mock para Firestore...
    await migrationService.migrarProdutos();
    // Produtos migrados com sucesso!
    
    // Verificar se os produtos foram adicionados
    // final novoSnapshot = await firestore.collection('produtos').get();
    // Total de produtos no Firestore: ${novoSnapshot.docs.length}
    
    // Script executado com sucesso!
    
  } catch (e) {
    // Erro ao executar script: $e
    exit(1);
  }
  
  exit(0);
}