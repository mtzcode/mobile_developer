import '../data/services/cache_service.dart';
import '../data/services/memory_cache_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/utils/logger.dart';

/// Utilitário para limpar todos os caches do aplicativo
class ClearCacheUtil {
  /// Limpa todos os tipos de cache do aplicativo
  static Future<void> clearAllCaches() async {
    try {
      // Limpa cache local (SharedPreferences)
      await CacheService.limparCache();
      
      // Limpa cache em memória
      MemoryCacheService.limparCache();
      
      // Limpa todas as SharedPreferences (incluindo outras configurações)
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      AppLogger.success('Todos os caches foram limpos com sucesso!');
    } catch (e) {
      AppLogger.error('Erro ao limpar caches', e);
    }
  }
  
  /// Limpa apenas o cache de produtos
  static Future<void> clearProductCache() async {
    try {
      // Limpa cache local de produtos
      await CacheService.limparCache();
      
      // Limpa cache em memória de produtos
      MemoryCacheService.limparCache();
      
      AppLogger.success('Cache de produtos limpo com sucesso!');
    } catch (e) {
      AppLogger.error('Erro ao limpar cache de produtos', e);
    }
  }
  
  /// Força atualização do cache (marca como expirado)
  static Future<void> forceRefresh() async {
    try {
      // Força atualização do cache local
      await CacheService.forcarAtualizacao();
      
      // Limpa cache em memória
      MemoryCacheService.limparCache();
      
      AppLogger.success('Cache marcado para atualização!');
    } catch (e) {
      AppLogger.error('Erro ao forçar atualização', e);
    }
  }
  
  /// Obtém informações sobre o estado atual dos caches
  static Future<Map<String, dynamic>> getCacheStatus() async {
    try {
      final localCacheInfo = await CacheService.getCacheInfo();
      final memoryCacheInfo = MemoryCacheService.getCacheInfo();
      
      return {
        'localCache': localCacheInfo,
        'memoryCache': memoryCacheInfo,
      };
    } catch (e) {
      return {
        'error': 'Erro ao obter status do cache: $e',
      };
    }
  }
}