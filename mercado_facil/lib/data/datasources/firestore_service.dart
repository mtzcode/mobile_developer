import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/produto.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Coleções
  CollectionReference get _produtos => _firestore.collection('produtos');
  CollectionReference get _usuarios => _firestore.collection('usuarios');
  CollectionReference get _pedidos => _firestore.collection('pedidos');
  CollectionReference get _favoritos => _firestore.collection('favoritos');

  // ===== PRODUTOS =====

  // Buscar produtos paginados
  Future<List<Produto>> getProdutosPaginados({required int page, int pageSize = 8, DocumentSnapshot? startAfter}) async {
    try {
      Query query = _produtos.orderBy('nome');
      
      // Se não é a primeira página, usa o último documento da página anterior
      if (startAfter != null) {
        // Usa startAfterDocument para paginação eficiente
        query = query.startAfterDocument(startAfter);
      }
      
      final snapshot = await query.limit(pageSize).get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Produto(
          id: doc.id,
          nome: data['nome'] ?? '',
          preco: (data['preco'] ?? 0).toDouble(),
          imagemUrl: data['imagemUrl'] ?? '',
          descricao: data['descricao'],
          categoria: data['categoria'],
          destaque: data['destaque'],
          precoPromocional: data['precoPromocional']?.toDouble(),
          favorito: false,
        );
      }).toList();
    } catch (e) {
      throw Exception('Erro ao carregar produtos paginados');
    }
  }

  // Buscar todos os produtos
  Future<List<Produto>> getProdutos() async {
    try {
      final snapshot = await _produtos.get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Produto(
          id: doc.id,
          nome: data['nome'] ?? '',
          preco: (data['preco'] ?? 0).toDouble(),
          imagemUrl: data['imagemUrl'] ?? '',
          descricao: data['descricao'],
          categoria: data['categoria'],
          destaque: data['destaque'],
          precoPromocional: data['precoPromocional']?.toDouble(),
          favorito: false, // Será definido separadamente
        );
      }).toList();
    } catch (e) {
      throw Exception('Erro ao carregar produtos');
    }
  }

  // Buscar produtos por categoria
  Future<List<Produto>> getProdutosPorCategoria(String categoria) async {
    try {
      final snapshot = await _produtos
          .where('categoria', isEqualTo: categoria)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Produto(
          id: doc.id,
          nome: data['nome'] ?? '',
          preco: (data['preco'] ?? 0).toDouble(),
          imagemUrl: data['imagemUrl'] ?? '',
          descricao: data['descricao'],
          categoria: data['categoria'],
          destaque: data['destaque'],
          precoPromocional: data['precoPromocional']?.toDouble(),
          favorito: false,
        );
      }).toList();
    } catch (e) {
      throw Exception('Erro ao carregar produtos');
    }
  }

  // Buscar produtos em destaque
  Future<List<Produto>> getProdutosDestaque() async {
    try {
      final snapshot = await _produtos
          .where('destaque', isNotEqualTo: null)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Produto(
          id: doc.id,
          nome: data['nome'] ?? '',
          preco: (data['preco'] ?? 0).toDouble(),
          imagemUrl: data['imagemUrl'] ?? '',
          descricao: data['descricao'],
          categoria: data['categoria'],
          destaque: data['destaque'],
          precoPromocional: data['precoPromocional']?.toDouble(),
          favorito: false,
        );
      }).toList();
    } catch (e) {
      throw Exception('Erro ao carregar produtos em destaque');
    }
  }

  // Adicionar produto à coleção 'produtos'
  Future<void> adicionarProduto(Map<String, dynamic> produto) async {
    try {
      await _produtos.add(produto);
    } catch (e) {
      throw Exception('Erro ao adicionar produto');
    }
  }

  // Limpar todos os produtos da coleção 'produtos'
  Future<void> limparProdutos() async {
    try {
      final snapshot = await _produtos.get();
      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      throw Exception('Erro ao limpar produtos');
    }
  }

  // ===== USUÁRIOS =====

  // Criar ou atualizar usuário
  Future<void> salvarUsuario(String userId, Map<String, dynamic> dados) async {
    try {
      await _usuarios.doc(userId).set(dados, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Erro ao salvar dados do usuário');
    }
  }

  // Buscar dados do usuário
  Future<Map<String, dynamic>?> getUsuario(String userId) async {
    try {
      final doc = await _usuarios.doc(userId).get();
      return doc.data() as Map<String, dynamic>?;
    } catch (e) {
      return null;
    }
  }

  // ===== FAVORITOS =====

  // Adicionar produto aos favoritos
  Future<void> adicionarFavorito(String userId, String produtoId) async {
    try {
      await _favoritos.doc('${userId}_$produtoId').set({
        'userId': userId,
        'produtoId': produtoId,
        'dataAdicao': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Erro ao adicionar aos favoritos');
    }
  }

  // Remover produto dos favoritos
  Future<void> removerFavorito(String userId, String produtoId) async {
    try {
      await _favoritos.doc('${userId}_$produtoId').delete();
    } catch (e) {
      throw Exception('Erro ao remover dos favoritos');
    }
  }

  // Verificar se produto é favorito
  Future<bool> isFavorito(String userId, String produtoId) async {
    try {
      final doc = await _favoritos.doc('${userId}_$produtoId').get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  // Buscar favoritos do usuário
  Future<List<String>> getFavoritos(String userId) async {
    try {
      final snapshot = await _favoritos
          .where('userId', isEqualTo: userId)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return data['produtoId'] as String;
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // ===== PEDIDOS =====

  // Criar pedido
  Future<String> criarPedido(String userId, Map<String, dynamic> dadosPedido) async {
    try {
      final docRef = await _pedidos.add({
        'userId': userId,
        'status': 'pendente',
        'dataCriacao': FieldValue.serverTimestamp(),
        ...dadosPedido,
      });
      return docRef.id;
    } catch (e) {
      throw Exception('Erro ao criar pedido');
    }
  }

  // Buscar pedidos do usuário
  Future<List<Map<String, dynamic>>> getPedidosUsuario(String userId) async {
    try {
      final snapshot = await _pedidos
          .where('userId', isEqualTo: userId)
          .orderBy('dataCriacao', descending: true)
          .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // Atualizar status do pedido
  Future<void> atualizarStatusPedido(String pedidoId, String status) async {
    try {
      await _pedidos.doc(pedidoId).update({
        'status': status,
        'dataAtualizacao': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Erro ao atualizar pedido');
    }
  }

  // ===== UTILITÁRIOS =====

  // Buscar produtos com favoritos marcados
  Future<List<Produto>> getProdutosComFavoritos(String userId) async {
    try {
      final produtos = await getProdutos();
      final favoritos = await getFavoritos(userId);
      
      return produtos.map((produto) {
        return produto.copyWith(favorito: favoritos.contains(produto.id));
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // Buscar categorias disponíveis
  Future<List<String>> getCategorias() async {
    try {
      final snapshot = await _produtos.get();
      final categorias = <String>{};
      
      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['categoria'] != null) {
          categorias.add(data['categoria']);
        }
      }
      
      return categorias.toList()..sort();
    } catch (e) {
      return [];
    }
  }
}