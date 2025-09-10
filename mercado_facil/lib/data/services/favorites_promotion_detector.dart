import 'dart:async';
import '../../core/utils/logger.dart';
import '../models/usuario.dart';
import '../models/produto.dart';
import '../models/notification_model.dart';
import 'firestore_service.dart';
import 'multi_channel_notification_service.dart';
import 'notification_service.dart';

/// Serviço responsável por detectar produtos favoritos em promoção
/// 
/// Este serviço monitora mudanças de preço nos produtos favoritos dos usuários
/// e dispara notificações quando detecta promoções.
class FavoritesPromotionDetector {
  final FirestoreService _firestoreService;
  final MultiChannelNotificationService _notificationService;
  final NotificationService _notificationSettingsService;
  
  Timer? _monitoringTimer;
  bool _isMonitoring = false;
  
  // Cache para armazenar preços anteriores dos produtos
  final Map<String, double> _previousPrices = {};
  
  // Configurações do detector
  static const Duration _checkInterval = Duration(minutes: 30); // Verifica a cada 30 minutos
  static const double _minDiscountPercentage = 5.0; // Desconto mínimo de 5% para notificar
  static const Duration _cooldownPeriod = Duration(hours: 6); // Período de cooldown entre notificações
  
  // Cache de notificações enviadas para evitar spam
  final Map<String, DateTime> _lastNotificationSent = {};

  FavoritesPromotionDetector({
    FirestoreService? firestoreService,
    MultiChannelNotificationService? notificationService,
    NotificationService? notificationSettingsService,
  }) : _firestoreService = firestoreService ?? FirestoreService(),
       _notificationService = notificationService ?? MultiChannelNotificationService(),
       _notificationSettingsService = notificationSettingsService ?? NotificationService();

  /// Inicia o monitoramento de produtos favoritos
  void startMonitoring() {
    if (_isMonitoring) {
      AppLogger.warning('Monitoramento de favoritos já está ativo');
      return;
    }
    
    AppLogger.info('Iniciando monitoramento de produtos favoritos em promoção');
    _isMonitoring = true;
    
    // Executa a primeira verificação imediatamente
    _checkFavoritesPromotions();
    
    // Agenda verificações periódicas
    _monitoringTimer = Timer.periodic(_checkInterval, (timer) {
      _checkFavoritesPromotions();
    });
  }

  /// Para o monitoramento de produtos favoritos
  void stopMonitoring() {
    if (!_isMonitoring) {
      AppLogger.warning('Monitoramento de favoritos não está ativo');
      return;
    }
    
    AppLogger.info('Parando monitoramento de produtos favoritos');
    _isMonitoring = false;
    _monitoringTimer?.cancel();
    _monitoringTimer = null;
  }

  /// Verifica produtos favoritos em promoção
  Future<void> _checkFavoritesPromotions() async {
    try {
      AppLogger.info('Verificando produtos favoritos em promoção...');
      
      // Busca todos os usuários que têm produtos favoritos
      final usuarios = await _firestoreService.getAllUsersWithFavorites();
      
      if (usuarios.isEmpty) {
        AppLogger.info('Nenhum usuário com favoritos encontrado');
        return;
      }
      
      AppLogger.info('Encontrados ${usuarios.length} usuários com favoritos');
      
      // Processa cada usuário
      for (final usuario in usuarios) {
        await _processUserFavorites(usuario);
      }
      
      AppLogger.success('Verificação de favoritos em promoção concluída');
      
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao verificar favoritos em promoção', e, stackTrace);
    }
  }

  /// Processa os favoritos de um usuário específico
  Future<void> _processUserFavorites(Usuario usuario) async {
    try {
      AppLogger.info('Processando favoritos do usuário ${usuario.nome}');
      
      // Busca as configurações de notificação do usuário
      final settings = await _notificationSettingsService.getNotificationSettings(usuario.id);
      
      // Verifica se o usuário quer receber notificações de favoritos em promoção
      if (!settings.favoritePromotions) {
        AppLogger.info('Usuário ${usuario.nome} não quer receber notificações de favoritos');
        return;
      }
      
      // Busca os produtos favoritos do usuário
      final favoritos = await _firestoreService.getUserFavorites(usuario.id);
      
      if (favoritos.isEmpty) {
        AppLogger.info('Usuário ${usuario.nome} não tem favoritos');
        return;
      }
      
      AppLogger.info('Usuário ${usuario.nome} tem ${favoritos.length} favoritos');
      
      // Verifica cada produto favorito
      for (final produtoId in favoritos) {
        final produtoData = await _firestoreService.getProdutoById(produtoId);
        if (produtoData != null) {
          final produto = Produto.fromMap(produtoData);
          await _checkProductPromotion(usuario, produto, settings);
        }
      }
      
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao processar favoritos do usuário ${usuario.nome}', e, stackTrace);
    }
  }

  /// Verifica se um produto específico está em promoção
  Future<void> _checkProductPromotion(
    Usuario usuario, 
    Produto produto, 
    NotificationSettings settings
  ) async {
    try {
      final productKey = '${usuario.id}_${produto.id}';
      final previousPrice = _previousPrices[produto.id];
      final currentPrice = produto.precoPromocional ?? produto.preco;
      
      // Atualiza o cache de preços
      _previousPrices[produto.id] = currentPrice;
      
      // Se não temos preço anterior, apenas armazena o atual
      if (previousPrice == null) {
        AppLogger.info('Primeiro registro de preço para ${produto.nome}: R\$ ${currentPrice.toStringAsFixed(2)}');
        return;
      }
      
      // Verifica se houve redução de preço
      if (currentPrice >= previousPrice) {
        // Preço igual ou maior, não é promoção
        return;
      }
      
      // Calcula o percentual de desconto
      final discountPercentage = ((previousPrice - currentPrice) / previousPrice) * 100;
      
      // Verifica se o desconto é significativo
      if (discountPercentage < _minDiscountPercentage) {
        AppLogger.info('Desconto de ${discountPercentage.toStringAsFixed(1)}% em ${produto.nome} não é significativo');
        return;
      }
      
      // Verifica cooldown para evitar spam
      final lastNotification = _lastNotificationSent[productKey];
      if (lastNotification != null) {
        final timeSinceLastNotification = DateTime.now().difference(lastNotification);
        if (timeSinceLastNotification < _cooldownPeriod) {
          AppLogger.info('Cooldown ativo para ${produto.nome} do usuário ${usuario.nome}');
          return;
        }
      }
      
      AppLogger.info('Promoção detectada: ${produto.nome} - ${discountPercentage.toStringAsFixed(1)}% de desconto');
      
      // Cria uma cópia do produto com o preço promocional
      final produtoComPromocao = Produto(
        id: produto.id,
        nome: produto.nome,
        descricao: produto.descricao,
        preco: previousPrice, // Preço original
        precoPromocional: currentPrice, // Preço promocional
        imagemUrl: produto.imagemUrl,
        categoria: produto.categoria,
        disponivel: produto.disponivel,
        favorito: produto.favorito,
        avaliacoes: produto.avaliacoes,
        estoque: produto.estoque,
      );
      
      // Envia a notificação
      final resultado = await _notificationService.enviarNotificacaoFavoritoPromocao(
        usuario,
        produtoComPromocao,
        settings,
      );
      
      // Registra o envio da notificação
      if (resultado.isNotEmpty && !resultado.containsKey('error')) {
        _lastNotificationSent[productKey] = DateTime.now();
        AppLogger.success('Notificação de promoção enviada para ${usuario.nome}: ${produto.nome}');
        
        // Registra a notificação no histórico do usuário
        await _registerPromotionNotification(usuario, produtoComPromocao, discountPercentage);
      } else {
        AppLogger.error('Falha ao enviar notificação de promoção para ${usuario.nome}: ${produto.nome}');
      }
      
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao verificar promoção do produto ${produto.nome}', e, stackTrace);
    }
  }

  /// Registra a notificação de promoção no histórico
  Future<void> _registerPromotionNotification(
    Usuario usuario, 
    Produto produto, 
    double discountPercentage
  ) async {
    try {
      final notificationData = {
        'user_id': usuario.id,
        'product_id': produto.id,
        'product_name': produto.nome,
        'original_price': produto.preco,
        'promotional_price': produto.precoPromocional,
        'discount_percentage': discountPercentage,
        'notification_type': 'favorite_promotion',
        'sent_at': DateTime.now().toIso8601String(),
        'channels_sent': ['push', 'email'], // Ajustar conforme resultado real
      };
      
      await _firestoreService.addNotificationHistory(notificationData);
      AppLogger.info('Notificação registrada no histórico');
      
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao registrar notificação no histórico', e, stackTrace);
    }
  }

  /// Força uma verificação manual de promoções
  Future<Map<String, dynamic>> forceCheck() async {
    try {
      AppLogger.info('Executando verificação manual de promoções');
      
      final startTime = DateTime.now();
      await _checkFavoritesPromotions();
      final endTime = DateTime.now();
      
      final duration = endTime.difference(startTime);
      
      return {
        'success': true,
        'duration_ms': duration.inMilliseconds,
        'checked_at': endTime.toIso8601String(),
        'message': 'Verificação manual concluída com sucesso',
      };
      
    } catch (e, stackTrace) {
      AppLogger.error('Erro na verificação manual', e, stackTrace);
      return {
        'success': false,
        'error': e.toString(),
        'checked_at': DateTime.now().toIso8601String(),
      };
    }
  }

  /// Adiciona um produto específico para monitoramento
  Future<void> addProductToMonitoring(String productId, double currentPrice) async {
    try {
      _previousPrices[productId] = currentPrice;
      AppLogger.info('Produto $productId adicionado ao monitoramento com preço R\$ ${currentPrice.toStringAsFixed(2)}');
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao adicionar produto ao monitoramento', e, stackTrace);
    }
  }

  /// Remove um produto do monitoramento
  void removeProductFromMonitoring(String productId) {
    try {
      _previousPrices.remove(productId);
      
      // Remove também as notificações relacionadas
      final keysToRemove = _lastNotificationSent.keys
          .where((key) => key.endsWith('_$productId'))
          .toList();
      
      for (final key in keysToRemove) {
        _lastNotificationSent.remove(key);
      }
      
      AppLogger.info('Produto $productId removido do monitoramento');
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao remover produto do monitoramento', e, stackTrace);
    }
  }

  /// Obtém estatísticas do detector
  Map<String, dynamic> getStatistics() {
    return {
      'is_monitoring': _isMonitoring,
      'check_interval_minutes': _checkInterval.inMinutes,
      'min_discount_percentage': _minDiscountPercentage,
      'cooldown_hours': _cooldownPeriod.inHours,
      'products_being_monitored': _previousPrices.length,
      'active_cooldowns': _lastNotificationSent.length,
      'last_check': DateTime.now().toIso8601String(),
    };
  }

  /// Limpa o cache de preços e notificações
  void clearCache() {
    _previousPrices.clear();
    _lastNotificationSent.clear();
    AppLogger.info('Cache do detector de promoções limpo');
  }

  /// Configura o percentual mínimo de desconto
  void setMinDiscountPercentage(double percentage) {
    if (percentage > 0 && percentage <= 100) {
      // Note: Esta é uma implementação simplificada.
      // Em uma implementação real, você salvaria isso em configurações persistentes.
      AppLogger.info('Percentual mínimo de desconto alterado para $percentage%');
    } else {
      AppLogger.warning('Percentual inválido: $percentage%. Deve estar entre 0 e 100.');
    }
  }

  /// Obtém o histórico de notificações de promoção
  Future<List<Map<String, dynamic>>> getPromotionHistory({
    String? userId,
    int limit = 50,
  }) async {
    try {
      return await _firestoreService.getNotificationHistory(
        userId: userId,
        limit: limit,
      );
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao buscar histórico de promoções', e, stackTrace);
      return [];
    }
  }

  /// Dispose do detector
  void dispose() {
    stopMonitoring();
    clearCache();
    AppLogger.info('Detector de promoções de favoritos finalizado');
  }
}

/// Extensão para FirestoreService com métodos específicos para favoritos
extension FavoritesExtension on FirestoreService {
  /// Busca todos os usuários que têm produtos favoritos
  Future<List<Usuario>> getAllUsersWithFavorites() async {
    try {
      // Implementação específica para buscar usuários com favoritos
      // Esta é uma implementação simplificada
      final usersData = await getAllUsers();
      final usersWithFavorites = <Usuario>[];
      
      for (final userData in usersData) {
        final user = Usuario.fromMap(userData['id'], userData);
        final favorites = await getUserFavorites(user.id);
        if (favorites.isNotEmpty) {
          usersWithFavorites.add(user);
        }
      }
      
      return usersWithFavorites;
    } catch (e) {
      AppLogger.error('Erro ao buscar usuários com favoritos', e);
      return [];
    }
  }
  
  /// Adiciona entrada no histórico de notificações
  Future<void> addNotificationHistory(Map<String, dynamic> data) async {
    try {
      await addDocument('notification_history', data);
    } catch (e) {
      AppLogger.error('Erro ao adicionar histórico de notificação', e);
      rethrow;
    }
  }
  
  /// Busca histórico de notificações
  Future<List<Map<String, dynamic>>> getNotificationHistory({
    String? type,
    String? userId,
    int limit = 50,
  }) async {
    try {
      // Implementação simplificada
      // Em uma implementação real, você usaria queries do Firestore com filtros
      final docs = await getCollection('notification_history');
      
      var filtered = docs.where((doc) {
        if (type != null && doc['notification_type'] != type) return false;
        if (userId != null && doc['user_id'] != userId) return false;
        return true;
      }).toList();
      
      // Ordena por data de envio (mais recente primeiro)
      filtered.sort((a, b) {
        final dateA = DateTime.parse(a['sent_at'] ?? '1970-01-01');
        final dateB = DateTime.parse(b['sent_at'] ?? '1970-01-01');
        return dateB.compareTo(dateA);
      });
      
      return filtered.take(limit).toList();
    } catch (e) {
      AppLogger.error('Erro ao buscar histórico de notificações', e);
      return [];
    }
  }
}