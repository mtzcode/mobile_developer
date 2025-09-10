import '../models/produto.dart';

class MemoryCacheService {
  static List<Produto>? _produtosCache;
  static DateTime? _lastUpdate;

  static const Duration _cacheValidity = Duration(hours: 24);

  // Salva produtos no cache em memória
  static void salvarProdutos(List<Produto> produtos) {
    _produtosCache = List.from(produtos);
    _lastUpdate = DateTime.now();
  }

  // Carrega produtos do cache em memória
  static List<Produto> carregarProdutos() {
    return _produtosCache ?? [];
  }

  // Verifica se o cache está válido
  static bool isCacheValido() {
    if (_lastUpdate == null || _produtosCache == null) return false;
    
    final now = DateTime.now();
    return now.difference(_lastUpdate!) < _cacheValidity;
  }

  // Verifica se existe cache
  static bool temCache() {
    return _produtosCache != null && _produtosCache!.isNotEmpty;
  }

  // Limpa o cache
  static void limparCache() {
    _produtosCache = null;
    _lastUpdate = null;
  }

  // Força atualização do cache (marca como expirado)
  static void forcarAtualizacao() {
    _lastUpdate = null;
  }

  // Obtém informações sobre o cache
  static Map<String, dynamic> getCacheInfo() {
    if (_produtosCache == null) {
      return {
        'temCache': false,
        'valido': false,
        'ultimaAtualizacao': null,
        'quantidadeProdutos': 0,
      };
    }

    return {
      'temCache': true,
      'valido': isCacheValido(),
      'ultimaAtualizacao': _lastUpdate,
      'quantidadeProdutos': _produtosCache!.length,
    };
  }

  // Atualiza favorito no cache
  static void atualizarFavorito(String produtoId, bool favorito) {
    if (_produtosCache != null) {
      final index = _produtosCache!.indexWhere((p) => p.id == produtoId);
      if (index != -1) {
        _produtosCache![index] = _produtosCache![index].copyWith(favorito: favorito);
      }
    }
  }
} 