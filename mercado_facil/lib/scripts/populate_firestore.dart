import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../firebase_options.dart';

/// Função principal para popular o Firestore com dados de teste
void main() async {
  // Inicializar Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Popular Firestore
  await popularFirestore();
}

/// Script para popular o Firestore com produtos de teste
Future<void> popularFirestore() async {
  try {
    debugPrint('🔄 Iniciando população do Firestore...');
    
    final firestore = FirebaseFirestore.instance;
    final produtosCollection = firestore.collection('produtos');
    
    // Verificar se já existem produtos
    final snapshot = await produtosCollection.get();
    debugPrint('📊 Produtos existentes: ${snapshot.docs.length}');
    
    if (snapshot.docs.isNotEmpty) {
      debugPrint('⚠️ Produtos já existem. Limpando coleção...');
      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
      debugPrint('🗑️ Coleção limpa.');
    }
    
    // Produtos de teste
    final produtosTeste = [
      {
        'nome': 'Arroz Integral',
        'preco': 8.50,
        'imagemUrl': 'https://picsum.photos/300/300?random=1',
        'descricao': 'Arroz integral de qualidade premium',
        'categoria': 'Grãos',
        'destaque': true,
        'precoPromocional': 6.99,
        'disponivel': true,
        'estoque': 100,
        'avaliacoes': [4.5, 5.0, 4.0, 4.5],
      },
      {
        'nome': 'Feijão Preto',
        'preco': 6.90,
        'imagemUrl': 'https://picsum.photos/300/300?random=2',
        'descricao': 'Feijão preto selecionado',
        'categoria': 'Grãos',
        'destaque': false,
        'disponivel': true,
        'estoque': 80,
        'avaliacoes': [4.0, 4.5, 4.0],
      },
      {
        'nome': 'Leite Integral',
        'preco': 4.20,
        'imagemUrl': 'https://picsum.photos/300/300?random=3',
        'descricao': 'Leite integral fresco',
        'categoria': 'Laticínios',
        'destaque': false,
        'disponivel': true,
        'estoque': 50,
        'avaliacoes': [4.8, 5.0, 4.5, 4.7],
      },
      {
        'nome': 'Pão Integral',
        'preco': 5.50,
        'imagemUrl': 'https://picsum.photos/300/300?random=4',
        'descricao': 'Pão integral artesanal',
        'categoria': 'Padaria',
        'destaque': true,
        'precoPromocional': 4.99,
        'disponivel': true,
        'estoque': 30,
        'avaliacoes': [4.2, 4.0, 4.5],
      },
      {
        'nome': 'Banana Prata',
        'preco': 3.80,
        'imagemUrl': 'https://picsum.photos/300/300?random=5',
        'descricao': 'Banana prata doce e madura',
        'categoria': 'Frutas',
        'destaque': false,
        'disponivel': true,
        'estoque': 120,
        'avaliacoes': [4.3, 4.5, 4.0, 4.2],
      },
      {
        'nome': 'Maçã Fuji',
        'preco': 7.90,
        'imagemUrl': 'https://picsum.photos/300/300?random=6',
        'descricao': 'Maçã Fuji crocante e doce',
        'categoria': 'Frutas',
        'destaque': true,
        'precoPromocional': 6.50,
        'disponivel': true,
        'estoque': 90,
        'avaliacoes': [4.7, 5.0, 4.5, 4.8],
      },
      {
        'nome': 'Frango Inteiro',
        'preco': 12.90,
        'imagemUrl': 'https://picsum.photos/300/300?random=7',
        'descricao': 'Frango inteiro congelado',
        'categoria': 'Carnes',
        'destaque': false,
        'disponivel': true,
        'estoque': 25,
        'avaliacoes': [4.1, 4.0, 4.3],
      },
      {
        'nome': 'Queijo Mussarela',
        'preco': 15.80,
        'imagemUrl': 'https://picsum.photos/300/300?random=8',
        'descricao': 'Queijo mussarela fatiado',
        'categoria': 'Laticínios',
        'destaque': true,
        'precoPromocional': 13.99,
        'disponivel': true,
        'estoque': 40,
        'avaliacoes': [4.6, 4.5, 4.8, 4.7],
      },
    ];
    
    // Adicionar produtos
    debugPrint('📦 Adicionando ${produtosTeste.length} produtos...');
    
    for (int i = 0; i < produtosTeste.length; i++) {
      final produto = produtosTeste[i];
      await produtosCollection.add(produto);
      debugPrint('✅ Produto ${i + 1}/${produtosTeste.length}: ${produto['nome']}');
    }
    
    // Verificar produtos adicionados
    final finalSnapshot = await produtosCollection.get();
    debugPrint('🎯 População concluída! Total de produtos: ${finalSnapshot.docs.length}');
    
    // Listar produtos adicionados
    debugPrint('\n📋 Produtos no Firestore:');
    for (var doc in finalSnapshot.docs) {
      final data = doc.data();
      debugPrint('  - ${data['nome']}: R\$ ${data['preco']}');
    }
    
  } catch (e, stackTrace) {
    debugPrint('❌ Erro ao popular Firestore: $e');
    debugPrint('Stack trace: $stackTrace');
  }
}