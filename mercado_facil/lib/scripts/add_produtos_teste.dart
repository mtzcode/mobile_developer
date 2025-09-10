import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Script para adicionar produtos de teste no Firestore
Future<void> adicionarProdutosTeste() async {
  try {
    debugPrint('🔄 Adicionando produtos de teste...');
    
    final firestore = FirebaseFirestore.instance;
    final produtosCollection = firestore.collection('produtos');
    
    // Verificar se já existem produtos
    final snapshot = await produtosCollection.get();
    debugPrint('📊 Produtos existentes: ${snapshot.docs.length}');
    
    if (snapshot.docs.isNotEmpty) {
      debugPrint('✅ Já existem produtos no Firestore');
      return;
    }
    
    // Produtos de teste
    final produtosTeste = [
      {
        'nome': 'Arroz Integral Tio João',
        'preco': 8.50,
        'imagemUrl': 'https://picsum.photos/300/300?random=1',
        'descricao': 'Arroz integral de alta qualidade',
        'categoria': 'Grãos',
        'destaque': 'oferta',
        'precoPromocional': 6.99,
        'disponivel': true,
        'estoque': 100,
        'dataCriacao': FieldValue.serverTimestamp(),
      },
      {
        'nome': 'Feijão Preto Camil',
        'preco': 6.90,
        'imagemUrl': 'https://picsum.photos/300/300?random=2',
        'descricao': 'Feijão preto selecionado',
        'categoria': 'Grãos',
        'destaque': 'oferta',
        'precoPromocional': 5.49,
        'disponivel': true,
        'estoque': 80,
        'dataCriacao': FieldValue.serverTimestamp(),
      },
      {
        'nome': 'Leite Integral Parmalat',
        'preco': 4.20,
        'imagemUrl': 'https://picsum.photos/300/300?random=3',
        'descricao': 'Leite integral 1L',
        'categoria': 'Laticínios',
        'destaque': 'novo',
        'disponivel': true,
        'estoque': 50,
        'dataCriacao': FieldValue.serverTimestamp(),
      },
      {
        'nome': 'Pão de Forma Wickbold',
        'preco': 5.80,
        'imagemUrl': 'https://picsum.photos/300/300?random=4',
        'descricao': 'Pão de forma integral',
        'categoria': 'Pães',
        'disponivel': true,
        'estoque': 30,
        'dataCriacao': FieldValue.serverTimestamp(),
      },
      {
        'nome': 'Banana Prata',
        'preco': 3.50,
        'imagemUrl': 'https://picsum.photos/300/300?random=5',
        'descricao': 'Banana prata fresca por kg',
        'categoria': 'Frutas',
        'destaque': 'mais vendido',
        'disponivel': true,
        'estoque': 200,
        'dataCriacao': FieldValue.serverTimestamp(),
      },
      {
        'nome': 'Tomate Salada',
        'preco': 2.80,
        'imagemUrl': 'https://picsum.photos/300/300?random=6',
        'descricao': 'Tomate salada fresco por kg',
        'categoria': 'Verduras',
        'disponivel': true,
        'estoque': 150,
        'dataCriacao': FieldValue.serverTimestamp(),
      },
      {
        'nome': 'Coca-Cola 2L',
        'preco': 7.90,
        'imagemUrl': 'https://picsum.photos/300/300?random=7',
        'descricao': 'Refrigerante Coca-Cola 2 litros',
        'categoria': 'Bebidas',
        'destaque': 'novo',
        'disponivel': true,
        'estoque': 60,
        'dataCriacao': FieldValue.serverTimestamp(),
      },
      {
        'nome': 'Sabão em Pó OMO',
        'preco': 12.50,
        'imagemUrl': 'https://picsum.photos/300/300?random=8',
        'descricao': 'Sabão em pó OMO 1kg',
        'categoria': 'Limpeza',
        'disponivel': true,
        'estoque': 40,
        'dataCriacao': FieldValue.serverTimestamp(),
      },
    ];
    
    // Adicionar produtos
    for (int i = 0; i < produtosTeste.length; i++) {
      final produto = produtosTeste[i];
      await produtosCollection.add(produto);
      debugPrint('✅ Produto ${i + 1} adicionado: ${produto['nome']}');
    }
    
    debugPrint('🎉 Todos os produtos de teste foram adicionados com sucesso!');
    
  } catch (e, stackTrace) {
    debugPrint('❌ Erro ao adicionar produtos de teste: $e');
    debugPrint('Stack trace: $stackTrace');
  }
}