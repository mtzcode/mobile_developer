import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/produto.dart';
import 'produtos_service.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Coleções
  CollectionReference get _produtos => _firestore.collection('produtos');
  CollectionReference get _usuarios => _firestore.collection('usuarios');
  CollectionReference get _pedidos => _firestore.collection('pedidos');
  CollectionReference get _favoritos => _firestore.collection('favoritos');

  // ===== PRODUTOS =====

  // Buscar todos os produtos
  Future<List<Produto>> getProdutos() async {
    try {
      final snapshot = await _produtos.get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data == null) return null;
        return Produto(
          id: doc.id,
          nome: data['nome'] ?? '',
          preco: (data['preco'] ?? 0).toDouble(),
          imagemUrl: data['imagemUrl'] ?? '',
          descricao: data['descricao'] ?? '',
          categoria: data['categoria'] ?? '',
          destaque: data['destaque'] ?? false,
          precoPromocional: data['precoPromocional']?.toDouble(),
          favorito: false, // Será definido separadamente
          estoque: data['estoque'] ?? 0,
          disponivel: data['disponivel'] ?? true,
          avaliacoes: data['avaliacoes'] != null 
              ? List<double>.from(data['avaliacoes'].map((x) => (x as num).toDouble()))
              : [],
        );
      }).whereType<Produto>().toList();
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
        final data = doc.data() as Map<String, dynamic>?;
        if (data == null) return null;
        return Produto(
          id: doc.id,
          nome: data['nome'] ?? '',
          preco: (data['preco'] ?? 0).toDouble(),
          imagemUrl: data['imagemUrl'] ?? '',
          descricao: data['descricao'] ?? '',
          categoria: data['categoria'] ?? '',
          destaque: data['destaque'] ?? false,
          precoPromocional: data['precoPromocional']?.toDouble(),
          favorito: false,
          estoque: data['estoque'] ?? 0,
          disponivel: data['disponivel'] ?? true,
          avaliacoes: data['avaliacoes'] != null 
              ? List<double>.from(data['avaliacoes'].map((x) => (x as num).toDouble()))
              : [],
        );
      }).whereType<Produto>().toList();
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
        final data = doc.data() as Map<String, dynamic>?;
        if (data == null) return null;
        return Produto(
          id: doc.id,
          nome: data['nome'] ?? '',
          preco: (data['preco'] ?? 0).toDouble(),
          imagemUrl: data['imagemUrl'] ?? '',
          descricao: data['descricao'] ?? '',
          categoria: data['categoria'] ?? '',
          destaque: data['destaque'] ?? false,
          precoPromocional: data['precoPromocional']?.toDouble(),
          favorito: false,
          estoque: data['estoque'] ?? 0,
          disponivel: data['disponivel'] ?? true,
          avaliacoes: data['avaliacoes'] != null 
              ? List<double>.from(data['avaliacoes'].map((x) => (x as num).toDouble()))
              : [],
        );
      }).whereType<Produto>().toList();
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

  // Buscar produtos paginados
  Future<List<Produto>> getProdutosPaginados({required int page, int pageSize = 8}) async {
    try {
      // Carrega todos os produtos e faz paginação em memória
      final snapshot = await _produtos.orderBy('nome').get();
      final allProducts = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data == null) return null;
        return Produto(
          id: doc.id,
          nome: data['nome'] ?? '',
          preco: (data['preco'] ?? 0).toDouble(),
          imagemUrl: data['imagemUrl'] ?? '',
          descricao: data['descricao'] ?? '',
          categoria: data['categoria'] ?? '',
          destaque: data['destaque'] ?? false,
          precoPromocional: data['precoPromocional']?.toDouble(),
          favorito: false,
          estoque: data['estoque'] ?? 0,
          disponivel: data['disponivel'] ?? true,
          avaliacoes: data['avaliacoes'] != null 
              ? List<double>.from(data['avaliacoes'].map((x) => (x as num).toDouble()))
              : [],
        );
      }).whereType<Produto>().toList();
      
      // Aplica paginação em memória
      final start = (page - 1) * pageSize;
      if (start >= allProducts.length) return [];
      final end = (start + pageSize) > allProducts.length ? allProducts.length : (start + pageSize);
      return allProducts.sublist(start, end);
    } catch (e) {
      throw Exception('Erro ao carregar produtos paginados');
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
        final data = doc.data() as Map<String, dynamic>?;
        return data?['produtoId'] as String? ?? '';
      }).where((id) => id.isNotEmpty).toList();
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
        final data = doc.data() as Map<String, dynamic>?;
        return <String, dynamic>{
          'id': doc.id,
          ...?data,
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
      
      // Se não há produtos no Firestore, usa fallback do ProdutosService
      if (produtos.isEmpty) {
        final produtosMock = ProdutosService.getProdutosMock();
        final favoritos = await getFavoritos(userId);
        
        return produtosMock.map((produto) {
          return produto.copyWith(favorito: favoritos.contains(produto.id));
        }).toList();
      }
      
      final favoritos = await getFavoritos(userId);
      
      return produtos.map((produto) {
        return produto.copyWith(favorito: favoritos.contains(produto.id));
      }).toList();
    } catch (e) {
      // Fallback para dados mock em caso de erro
      try {
        final produtosMock = ProdutosService.getProdutosMock();
        return produtosMock;
      } catch (fallbackError) {
        return [];
      }
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

  // ===== MÉTODOS PARA NOTIFICATION SCHEDULER =====

  // Buscar todos os produtos (alias para getProdutos)
  Future<List<Produto>> getAllProducts() async {
    return await getProdutos();
  }

  // Buscar todos os usuários
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final snapshot = await _usuarios.get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>?;
        return <String, dynamic>{
          'id': doc.id,
          ...?data,
        };
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // Buscar favoritos do usuário (retorna lista de produtos)
  Future<List<String>> getUserFavorites(String userId) async {
    return await getFavoritos(userId);
  }

  // Atualizar documento genérico
  Future<void> updateDocument(String collection, String docId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(collection).doc(docId).update(data);
    } catch (e) {
      throw Exception('Erro ao atualizar documento');
    }
  }

  // Adicionar documento genérico
  Future<String> addDocument(String collection, Map<String, dynamic> data) async {
    try {
      final docRef = await _firestore.collection(collection).add(data);
      return docRef.id;
    } catch (e) {
      throw Exception('Erro ao adicionar documento');
    }
  }

  // Buscar coleção genérica
  Future<List<Map<String, dynamic>>> getCollection(String collection) async {
    try {
      final snapshot = await _firestore.collection(collection).get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>?;
        return <String, dynamic>{
          'id': doc.id,
          ...?data,
        };
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // ===== MÉTODOS AUXILIARES =====

  /// Busca usuário por ID
  Future<Map<String, dynamic>?> getUserById(String userId) async {
    try {
      final doc = await _usuarios.doc(userId).get();
      if (doc.exists) {
        return {
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        };
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Busca produto por ID
  Future<Map<String, dynamic>?> getProdutoById(String produtoId) async {
    try {
      final doc = await _produtos.doc(produtoId).get();
      if (doc.exists) {
        return {
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        };
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Adiciona histórico de notificação
  Future<void> addNotificationHistory(Map<String, dynamic> notification) async {
    try {
      await _firestore.collection('notification_history').add({
        ...notification,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Erro silencioso
    }
  }

  /// Busca histórico de notificações
  Future<List<Map<String, dynamic>>> getNotificationHistory({String? userId, int limit = 50}) async {
    try {
      Query query = _firestore.collection('notification_history');
      
      if (userId != null) {
        query = query.where('userId', isEqualTo: userId);
      }
      
      final snapshot = await query
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();
      
      return snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        };
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// Busca documento genérico
  Future<Map<String, dynamic>?> getDocument(String collection, String docId) async {
    try {
      final doc = await _firestore.collection(collection).doc(docId).get();
      if (doc.exists) {
        return {
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        };
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Deleta documento genérico
  Future<void> deleteDocument(String collection, String docId) async {
    try {
      await _firestore.collection(collection).doc(docId).delete();
    } catch (e) {
      // Erro silencioso
    }
  }

  }