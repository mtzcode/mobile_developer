import 'package:cloud_firestore/cloud_firestore.dart';

class MigrationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Dados mock para migração
  static List<Map<String, dynamic>> get produtosMock => [
    {
      'nome': 'Arroz Integral',
      'preco': 8.50,
      'imagemUrl': 'https://via.placeholder.com/150x150/64ba01/ffffff?text=Arroz',
      'descricao': 'Arroz integral orgânico rico em fibras',
      'categoria': 'Grãos',
      'destaque': 'oferta',
      'precoPromocional': 6.99,
      'ativo': true,
      'dataCriacao': FieldValue.serverTimestamp(),
    },
    {
      'nome': 'Feijão Preto',
      'preco': 6.90,
      'imagemUrl': 'https://via.placeholder.com/150x150/64ba01/ffffff?text=Feijão',
      'descricao': 'Feijão preto tradicional',
      'categoria': 'Grãos',
      'destaque': 'oferta',
      'precoPromocional': 5.49,
      'ativo': true,
      'dataCriacao': FieldValue.serverTimestamp(),
    },
    {
      'nome': 'Leite Integral',
      'preco': 4.20,
      'imagemUrl': 'https://via.placeholder.com/150x150/64ba01/ffffff?text=Leite',
      'descricao': 'Leite integral fresco',
      'categoria': 'Laticínios',
      'destaque': 'novo',
      'ativo': true,
      'dataCriacao': FieldValue.serverTimestamp(),
    },
    {
      'nome': 'Pão de Forma',
      'preco': 5.80,
      'imagemUrl': 'https://via.placeholder.com/150x150/64ba01/ffffff?text=Pão',
      'descricao': 'Pão de forma integral',
      'categoria': 'Pães',
      'ativo': true,
      'dataCriacao': FieldValue.serverTimestamp(),
    },
    {
      'nome': 'Banana Prata',
      'preco': 3.50,
      'imagemUrl': 'https://via.placeholder.com/150x150/64ba01/ffffff?text=Banana',
      'descricao': 'Banana prata fresca',
      'categoria': 'Frutas',
      'destaque': 'mais vendido',
      'ativo': true,
      'dataCriacao': FieldValue.serverTimestamp(),
    },
    {
      'nome': 'Tomate',
      'preco': 2.80,
      'imagemUrl': 'https://via.placeholder.com/150x150/64ba01/ffffff?text=Tomate',
      'descricao': 'Tomate vermelho maduro',
      'categoria': 'Verduras',
      'ativo': true,
      'dataCriacao': FieldValue.serverTimestamp(),
    },
    {
      'nome': 'Coca-Cola 2L',
      'preco': 7.90,
      'imagemUrl': 'https://via.placeholder.com/150x150/64ba01/ffffff?text=Refrigerante',
      'descricao': 'Refrigerante Coca-Cola 2 litros',
      'categoria': 'Bebidas',
      'destaque': 'novo',
      'ativo': true,
      'dataCriacao': FieldValue.serverTimestamp(),
    },
    {
      'nome': 'Sabão em Pó',
      'preco': 12.50,
      'imagemUrl': 'https://via.placeholder.com/150x150/64ba01/ffffff?text=Sabão',
      'descricao': 'Sabão em pó para roupas',
      'categoria': 'Limpeza',
      'ativo': true,
      'dataCriacao': FieldValue.serverTimestamp(),
    },
    {
      'nome': 'Óleo de Soja',
      'preco': 9.90,
      'imagemUrl': 'https://via.placeholder.com/150x150/64ba01/ffffff?text=Óleo',
      'descricao': 'Óleo de soja refinado',
      'categoria': 'Condimentos',
      'ativo': true,
      'dataCriacao': FieldValue.serverTimestamp(),
    },
    {
      'nome': 'Macarrão Espaguete',
      'preco': 3.20,
      'imagemUrl': 'https://via.placeholder.com/150x150/64ba01/ffffff?text=Macarrão',
      'descricao': 'Macarrão espaguete tradicional',
      'categoria': 'Massas',
      'ativo': true,
      'dataCriacao': FieldValue.serverTimestamp(),
    },
    {
      'nome': 'Queijo Mussarela',
      'preco': 15.80,
      'imagemUrl': 'https://via.placeholder.com/150x150/64ba01/ffffff?text=Queijo',
      'descricao': 'Queijo mussarela fatiado',
      'categoria': 'Laticínios',
      'ativo': true,
      'dataCriacao': FieldValue.serverTimestamp(),
    },
    {
      'nome': 'Maçã Fuji',
      'preco': 4.50,
      'imagemUrl': 'https://via.placeholder.com/150x150/64ba01/ffffff?text=Maçã',
      'descricao': 'Maçã Fuji doce e crocante',
      'categoria': 'Frutas',
      'ativo': true,
      'dataCriacao': FieldValue.serverTimestamp(),
    },
  ];

  // Migrar produtos para Firestore
  Future<void> migrarProdutos() async {
    try {
      final batch = _firestore.batch();
      
      for (final produtoData in produtosMock) {
        final docRef = _firestore.collection('produtos').doc();
        batch.set(docRef, produtoData);
      }
      
      await batch.commit();
    } catch (e) {
      throw Exception('Falha na migração de produtos');
    }
  }

  // Verificar se já existem produtos
  Future<bool> produtosExistem() async {
    try {
      final snapshot = await _firestore.collection('produtos').limit(1).get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Limpar todos os produtos (cuidado!)
  Future<void> limparProdutos() async {
    try {
      final snapshot = await _firestore.collection('produtos').get();
      final batch = _firestore.batch();
      
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
    } catch (e) {
      throw Exception('Falha ao limpar produtos');
    }
  }

  // Migração completa
  Future<void> executarMigracaoCompleta() async {
    try {
      // Verificar se já existem dados
      final produtosExistem = await this.produtosExistem();
      
      if (produtosExistem) {
        // Em uma implementação real, você perguntaria ao usuário
        return;
      }
      
      // Migrar produtos
      await migrarProdutos();
    } catch (e) {
      throw Exception('Falha na migração completa');
    }
  }

  // Testar conexão com Firestore
  Future<bool> testarConexao() async {
    try {
      await _firestore.collection('teste').doc('conexao').set({
        'timestamp': FieldValue.serverTimestamp(),
        'teste': true,
      });
      
      await _firestore.collection('teste').doc('conexao').delete();
      
      return true;
    } catch (e) {
      return false;
    }
  }

  // Obter estatísticas do banco
  Future<Map<String, dynamic>> getEstatisticas() async {
    try {
      final produtosSnapshot = await _firestore.collection('produtos').get();
      final usuariosSnapshot = await _firestore.collection('usuarios').get();
      final pedidosSnapshot = await _firestore.collection('pedidos').get();
      
      return {
        'produtos': produtosSnapshot.docs.length,
        'usuarios': usuariosSnapshot.docs.length,
        'pedidos': pedidosSnapshot.docs.length,
      };
    } catch (e) {
      return {
        'produtos': 0,
        'usuarios': 0,
        'pedidos': 0,
      };
    }
  }
}