import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'lib/firebase_options.dart';

void main() async {
  print('🔄 Testando conexão com Firestore...');
  
  try {
    // Inicializar Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase inicializado');
    
    // Testar conexão com Firestore
    final firestore = FirebaseFirestore.instance;
    
    // Verificar produtos existentes
    print('📡 Buscando produtos...');
    final snapshot = await firestore.collection('produtos').get();
    print('📊 Produtos encontrados: ${snapshot.docs.length}');
    
    if (snapshot.docs.isEmpty) {
      print('⚠️ Nenhum produto encontrado. Adicionando produtos de teste...');
      
      // Adicionar produtos de teste
      final produtosTeste = [
        {
          'nome': 'Arroz Integral',
          'preco': 8.50,
          'imagemUrl': 'https://picsum.photos/300/300?random=1',
          'descricao': 'Arroz integral de qualidade',
          'categoria': 'Grãos',
          'destaque': 'oferta',
          'precoPromocional': 6.99,
          'disponivel': true,
          'estoque': 100,
        },
        {
          'nome': 'Feijão Preto',
          'preco': 6.90,
          'imagemUrl': 'https://picsum.photos/300/300?random=2',
          'descricao': 'Feijão preto selecionado',
          'categoria': 'Grãos',
          'disponivel': true,
          'estoque': 80,
        },
        {
          'nome': 'Leite Integral',
          'preco': 4.20,
          'imagemUrl': 'https://picsum.photos/300/300?random=3',
          'descricao': 'Leite integral 1L',
          'categoria': 'Laticínios',
          'disponivel': true,
          'estoque': 50,
        },
      ];
      
      for (int i = 0; i < produtosTeste.length; i++) {
        await firestore.collection('produtos').add(produtosTeste[i]);
        print('✅ Produto ${i + 1} adicionado: ${produtosTeste[i]['nome']}');
      }
      
      print('🎉 Produtos de teste adicionados!');
    } else {
      print('✅ Produtos já existem no Firestore:');
      for (var doc in snapshot.docs.take(3)) {
        final data = doc.data();
        print('  - ${data['nome']}: R\$ ${data['preco']}');
      }
    }
    
    print('🎯 Teste concluído com sucesso!');
    
  } catch (e, stackTrace) {
    print('❌ Erro: $e');
    print('Stack trace: $stackTrace');
  }
}