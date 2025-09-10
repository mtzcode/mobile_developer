import '../models/produto.dart';
import 'cache_service.dart';
import 'memory_cache_service.dart';
import 'firestore_service.dart';

/// Serviço responsável por gerenciar produtos com estratégia de cache inteligente.
/// 
/// Este serviço implementa uma estratégia de cache em múltiplas camadas:
/// 1. Cache local (SharedPreferences) - persistente
/// 2. Cache em memória - rápido acesso
/// 3. Firestore - fonte de dados principal
/// 4. Dados mock - fallback final
/// 
/// A estratégia garante que o app funcione mesmo offline e tenha
/// performance otimizada com dados sempre atualizados quando possível.
class ProdutosService {
  /// Instância do serviço Firestore para operações de banco de dados
  static final FirestoreService _firestoreService = FirestoreService();

  /// Retorna uma lista de produtos mock para uso como fallback.
  /// 
  /// Estes dados são utilizados quando todas as outras fontes falham,
  /// garantindo que o app sempre tenha produtos para exibir.
  /// 
  /// Retorna [List<Produto>] com dados de exemplo.
  static List<Produto> getProdutosMock() {
    return [
      Produto(
        id: '1',
        nome: 'Arroz Integral',
        preco: 8.50,
        imagemUrl: 'https://picsum.photos/150/150?random=1',
        categoria: 'Grãos',
        destaque: 'oferta',
        precoPromocional: 6.99,
        favorito: false,
      ),
      Produto(
        id: '2',
        nome: 'Feijão Preto',
        preco: 6.90,
        imagemUrl: 'https://picsum.photos/150/150?random=2',
        categoria: 'Grãos',
        destaque: 'oferta',
        precoPromocional: 5.49,
        favorito: false,
      ),
      Produto(
        id: '3',
        nome: 'Leite Integral',
        preco: 4.20,
        imagemUrl: 'https://picsum.photos/150/150?random=3',
        categoria: 'Laticínios',
        destaque: 'novo',
        favorito: false,
      ),
      Produto(
        id: '4',
        nome: 'Pão de Forma',
        preco: 5.80,
        imagemUrl: 'https://picsum.photos/150/150?random=4',
        categoria: 'Pães',
        favorito: false,
      ),
      Produto(
        id: '5',
        nome: 'Banana Prata',
        preco: 3.50,
        imagemUrl: 'https://picsum.photos/150/150?random=5',
        categoria: 'Frutas',
        destaque: 'mais vendido',
        favorito: false,
      ),
      Produto(
        id: '6',
        nome: 'Tomate',
        preco: 2.80,
        imagemUrl: 'https://picsum.photos/150/150?random=6',
        categoria: 'Verduras',
        favorito: false,
      ),
      Produto(
        id: '7',
        nome: 'Coca-Cola 2L',
        preco: 7.90,
        imagemUrl: 'https://picsum.photos/150/150?random=7',
        categoria: 'Bebidas',
        destaque: 'novo',
        favorito: false,
      ),
      Produto(
        id: '8',
        nome: 'Sabão em Pó',
        preco: 12.50,
        imagemUrl: 'https://picsum.photos/150/150?random=8',
        categoria: 'Limpeza',
        favorito: false,
      ),
    ];
  }

  /// Carrega produtos com estratégia de cache inteligente.
  /// 
  /// Implementa uma estratégia de fallback em cascata:
  /// 1. Tenta cache local (se válido e não forçar atualização)
  /// 2. Tenta cache em memória (se válido)
  /// 3. Carrega do Firestore (fonte principal)
  /// 4. Salva no cache local e memória
  /// 5. Fallback para cache local (mesmo expirado)
  /// 6. Fallback para cache em memória
  /// 7. Fallback para dados mock
  /// 
  /// [forcarAtualizacao] - Se true, ignora cache e força atualização do Firestore
  /// 
  /// Retorna [List<Produto>] com os produtos carregados.
  /// 
  /// Lança [Exception] apenas se todos os fallbacks falharem.
  static Future<List<Produto>> carregarProdutosComCache({bool forcarAtualizacao = false}) async {
    try {
      // Se não forçar atualização, tenta carregar do cache primeiro
      if (!forcarAtualizacao) {
        // Tenta cache local (shared_preferences)
        try {
          final temCache = await CacheService.temCache();
          final cacheValido = await CacheService.isCacheValido();
          
          if (temCache && cacheValido) {
            final produtosCache = await CacheService.carregarProdutos();
            if (produtosCache.isNotEmpty) {
              return produtosCache;
            }
          }
        } catch (cacheError) {
          // Erro silencioso ao acessar cache local
        }

        // Tenta cache em memória como fallback
        if (MemoryCacheService.temCache() && MemoryCacheService.isCacheValido()) {
          final produtosCache = MemoryCacheService.carregarProdutos();
          if (produtosCache.isNotEmpty) {
            return produtosCache;
          }
        }
      }

      // Se não tem cache válido ou forçou atualização, carrega do Firestore
      final produtos = await _carregarProdutosDoFirestore();
      
      // Salva no cache local (tenta, mas não falha se der erro)
      if (produtos.isNotEmpty) {
        try {
          await CacheService.salvarProdutos(produtos);
        } catch (cacheError) {
          // Erro silencioso ao salvar no cache local
        }

        // Sempre salva no cache em memória como backup
        MemoryCacheService.salvarProdutos(produtos);
      }
      
      return produtos;
    } catch (e) {
      // Fallback para cache local mesmo que expirado
      try {
        final produtosCache = await CacheService.carregarProdutos();
        if (produtosCache.isNotEmpty) {
          return produtosCache;
        }
      } catch (cacheError) {
        // Erro silencioso ao carregar cache local como fallback
      }

      // Fallback para cache em memória
      if (MemoryCacheService.temCache()) {
        final produtosCache = MemoryCacheService.carregarProdutos();
        if (produtosCache.isNotEmpty) {
          return produtosCache;
        }
      }
      
      // Último fallback: dados mock
      return getProdutosMock();
    }
  }

  /// Carrega produtos diretamente do Firestore.
  /// 
  /// Método privado que encapsula a lógica de carregamento do Firestore.
  /// Se o Firestore não retornar dados, usa dados mock como fallback.
  /// 
  /// Retorna [List<Produto>] do Firestore ou dados mock.
  /// 
  /// Lança [Exception] se houver erro na comunicação com Firestore.
  static Future<List<Produto>> _carregarProdutosDoFirestore() async {
    try {
      final produtosData = await _firestoreService.getProdutos();
      
      if (produtosData.isEmpty) {
        return getProdutosMock();
      }

      return produtosData;
    } catch (e) {
      rethrow;
    }
  }

  /// Carrega produtos com paginação.
  /// 
  /// Implementa paginação inteligente que tenta usar cache quando possível
  /// e só vai ao Firestore quando necessário (cache expirado ou forçar atualização).
  /// 
  /// [page] - Número da página (começa em 1)
  /// [pageSize] - Quantidade de itens por página (padrão: 8)
  /// [forcarAtualizacao] - Se true, ignora cache e força atualização
  /// 
  /// Retorna [List<Produto>] da página solicitada.
  static Future<List<Produto>> getProdutosPaginados({required int page, int pageSize = 8, bool forcarAtualizacao = false}) async {
    try {
      // Se forçar atualização ou não tem cache válido, carrega do Firestore
      if (forcarAtualizacao || !await CacheService.isCacheValido()) {
        return await _getProdutosPaginadosDoFirestore(page: page, pageSize: pageSize);
      }

      // Tenta carregar do cache primeiro
      final todos = await carregarProdutosComCache(forcarAtualizacao: false);
      final start = (page - 1) * pageSize;
      if (start >= todos.length) return [];
      final end = (start + pageSize) > todos.length ? todos.length : (start + pageSize);
      return todos.sublist(start, end);
    } catch (e) {
      // Fallback para dados mock paginados
      final todos = getProdutosMock();
      final start = (page - 1) * pageSize;
      if (start >= todos.length) return [];
      final end = (start + pageSize) > todos.length ? todos.length : (start + pageSize);
      return todos.sublist(start, end);
    }
  }

  /// Carrega produtos paginados diretamente do Firestore.
  /// 
  /// Método privado que encapsula a lógica de paginação do Firestore.
  /// 
  /// [page] - Número da página
  /// [pageSize] - Quantidade de itens por página
  /// 
  /// Retorna [List<Produto>] da página solicitada.
  /// 
  /// Lança [Exception] se houver erro na comunicação com Firestore.
  static Future<List<Produto>> _getProdutosPaginadosDoFirestore({required int page, int pageSize = 8}) async {
    try {
      final produtosData = await _firestoreService.getProdutosPaginados(page: page, pageSize: pageSize);
      return produtosData;
    } catch (e) {
      rethrow;
    }
  }

  // Verifica se há mais produtos disponíveis
  static Future<bool> temMaisProdutos({required int page, int pageSize = 8}) async {
    try {
      final produtos = await _getProdutosPaginadosDoFirestore(page: page + 1, pageSize: pageSize);
      return produtos.isNotEmpty;
    } catch (e) {
      // Fallback: verifica no cache
      try {
        final todos = await carregarProdutosComCache(forcarAtualizacao: false);
        final start = page * pageSize;
        return start < todos.length;
      } catch (cacheError) {
        // Fallback final: verifica nos dados mock
        final todos = getProdutosMock();
        final start = page * pageSize;
        return start < todos.length;
      }
    }
  }

  // Buscar produtos por categoria
  static Future<List<Produto>> getProdutosPorCategoria(String categoria, {bool forcarAtualizacao = false}) async {
    try {
      final produtos = await carregarProdutosComCache(forcarAtualizacao: forcarAtualizacao);
      return produtos.where((produto) => produto.categoria == categoria).toList();
    } catch (e) {
      return [];
    }
  }

  // Buscar produtos por nome
  static Future<List<Produto>> buscarProdutos(String query, {bool forcarAtualizacao = false}) async {
    try {
      final produtos = await carregarProdutosComCache(forcarAtualizacao: forcarAtualizacao);
      final queryLower = query.toLowerCase();
      
      return produtos.where((produto) => 
        produto.nome.toLowerCase().contains(queryLower) ||
        (produto.categoria?.toLowerCase().contains(queryLower) ?? false)
      ).toList();
    } catch (e) {
      return [];
    }
  }

  // Buscar produtos em destaque
  static Future<List<Produto>> getProdutosDestaque({bool forcarAtualizacao = false}) async {
    try {
      final produtos = await carregarProdutosComCache(forcarAtualizacao: forcarAtualizacao);
      return produtos.where((produto) => produto.destaque != null).toList();
    } catch (e) {
      return [];
    }
  }

  // Método para atualizar favoritos no cache
  static Future<void> atualizarFavorito(String produtoId, bool favorito) async {
    // Atualiza no cache local
    try {
      final produtos = await CacheService.carregarProdutos();
      final index = produtos.indexWhere((p) => p.id == produtoId);
      
      if (index != -1) {
        produtos[index] = produtos[index].copyWith(favorito: favorito);
        await CacheService.salvarProdutos(produtos);
      }
    } catch (e) {
      // Erro silencioso ao atualizar favorito no cache local
    }

    // Atualiza no cache em memória
    MemoryCacheService.atualizarFavorito(produtoId, favorito);
  }

  // Método para limpar cache
  static Future<void> limparCache() async {
    try {
      await CacheService.limparCache();
    } catch (e) {
      // Erro silencioso ao limpar cache local
    }
    MemoryCacheService.limparCache();
  }

  // Método para obter informações do cache
  static Future<Map<String, dynamic>> getCacheInfo() async {
    try {
      return await CacheService.getCacheInfo();
    } catch (e) {
      return MemoryCacheService.getCacheInfo();
    }
  }

  // Migrar dados mock para Firestore
  static Future<void> migrarDadosMock() async {
    try {
      final produtosMock = getProdutosMock();
      
      for (final produto in produtosMock) {
        await _firestoreService.adicionarProduto(produto.toMap());
      }
    } catch (e) {
      rethrow;
    }
  }

  // Limpar todos os produtos do Firestore
  static Future<void> limparProdutosFirestore() async {
    try {
      await _firestoreService.limparProdutos();
    } catch (e) {
      rethrow;
    }
  }
}