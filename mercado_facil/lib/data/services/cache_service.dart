import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/produto.dart';

class CacheService {
  static const String _produtosKey = 'produtos_cache';
  static const String _lastUpdateKey = 'produtos_last_update';
  static const Duration _cacheValidity = Duration(hours: 24); // Cache válido por 24 horas

  // Salva produtos no cache local
  static Future<void> salvarProdutos(List<Produto> produtos) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Converte produtos para JSON
      final produtosJson = produtos.map((produto) => {
        'id': produto.id,
        'nome': produto.nome,
        'preco': produto.preco,
        'imagemUrl': produto.imagemUrl,
        'descricao': produto.descricao,
        'categoria': produto.categoria,
        'destaque': produto.destaque,
        'precoPromocional': produto.precoPromocional,
        'favorito': produto.favorito,
      }).toList();

      await prefs.setString(_produtosKey, jsonEncode(produtosJson));
      await prefs.setInt(_lastUpdateKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      // Erro silencioso ao salvar no cache
    }
  }

  // Carrega produtos do cache local
  static Future<List<Produto>> carregarProdutos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final produtosJson = prefs.getString(_produtosKey);
      if (produtosJson == null) return [];

      final List<dynamic> produtosList = jsonDecode(produtosJson);
      return produtosList.map((json) => Produto(
        id: json['id'],
        nome: json['nome'],
        preco: json['preco'].toDouble(),
        imagemUrl: json['imagemUrl'],
        descricao: json['descricao'],
        categoria: json['categoria'],
        destaque: json['destaque'],
        precoPromocional: json['precoPromocional']?.toDouble(),
        favorito: json['favorito'] ?? false,
      )).toList();
    } catch (e) {
      return [];
    }
  }

  // Verifica se o cache está válido (não expirou)
  static Future<bool> isCacheValido() async {
    final prefs = await SharedPreferences.getInstance();
    final lastUpdate = prefs.getInt(_lastUpdateKey);
    
    if (lastUpdate == null) return false;
    
    final lastUpdateTime = DateTime.fromMillisecondsSinceEpoch(lastUpdate);
    final now = DateTime.now();
    
    return now.difference(lastUpdateTime) < _cacheValidity;
  }

  // Verifica se existe cache de produtos
  static Future<bool> temCache() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_produtosKey) != null;
  }

  // Limpa o cache
  static Future<void> limparCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_produtosKey);
    await prefs.remove(_lastUpdateKey);
  }

  // Força atualização do cache (marca como expirado)
  static Future<void> forcarAtualizacao() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastUpdateKey);
  }

  // Obtém informações sobre o cache
  static Future<Map<String, dynamic>> getCacheInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final lastUpdate = prefs.getInt(_lastUpdateKey);
    final produtosJson = prefs.getString(_produtosKey);
    
    if (lastUpdate == null || produtosJson == null) {
      return {
        'temCache': false,
        'valido': false,
        'ultimaAtualizacao': null,
        'quantidadeProdutos': 0,
      };
    }

    final lastUpdateTime = DateTime.fromMillisecondsSinceEpoch(lastUpdate);
    final produtos = jsonDecode(produtosJson) as List;
    
    return {
      'temCache': true,
      'valido': await isCacheValido(),
      'ultimaAtualizacao': lastUpdateTime,
      'quantidadeProdutos': produtos.length,
    };
  }
} 