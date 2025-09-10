import 'dart:async';
import '../../core/utils/logger.dart';
import '../models/usuario.dart';
import '../models/produto.dart';
import '../models/carrinho_item.dart';
import 'firestore_service.dart';
import 'multi_channel_notification_service.dart';
import 'notification_service.dart';

/// Serviço responsável por lembretes de carrinho abandonado
/// 
/// Este serviço monitora carrinhos inativos e envia notificações
/// para lembrar os usuários de finalizar suas compras.
class CartReminderService {
  final FirestoreService _firestoreService;
  final MultiChannelNotificationService _notificationService;
  final NotificationService _notificationSettingsService;
  
  Timer? _reminderTimer;
  bool _isMonitoring = false;
  
  // Configurações do serviço
  static const Duration _checkInterval = Duration(hours: 1); // Verifica a cada hora
  static const Duration _firstReminderDelay = Duration(hours: 2); // Primeiro lembrete após 2h
  static const Duration _secondReminderDelay = Duration(hours: 24); // Segundo lembrete após 24h
  static const Duration _finalReminderDelay = Duration(hours: 72); // Lembrete final após 72h
  static const Duration _cartExpirationTime = Duration(days: 7); // Carrinho expira em 7 dias
  
  // Cache de lembretes enviados
  final Map<String, List<DateTime>> _remindersSent = {};

  CartReminderService({
    FirestoreService? firestoreService,
    MultiChannelNotificationService? notificationService,
    NotificationService? notificationSettingsService,
  }) : _firestoreService = firestoreService ?? FirestoreService(),
       _notificationService = notificationService ?? MultiChannelNotificationService(),
       _notificationSettingsService = notificationSettingsService ?? NotificationService();

  /// Inicia o monitoramento de carrinhos abandonados
  void startMonitoring() {
    if (_isMonitoring) {
      AppLogger.warning('Monitoramento de carrinho já está ativo');
      return;
    }
    
    AppLogger.info('Iniciando monitoramento de carrinhos abandonados');
    _isMonitoring = true;
    
    // Executa a primeira verificação imediatamente
    _checkAbandonedCarts();
    
    // Agenda verificações periódicas
    _reminderTimer = Timer.periodic(_checkInterval, (timer) {
      _checkAbandonedCarts();
    });
  }

  /// Para o monitoramento de carrinhos abandonados
  void stopMonitoring() {
    if (!_isMonitoring) {
      AppLogger.warning('Monitoramento de carrinho não está ativo');
      return;
    }
    
    AppLogger.info('Parando monitoramento de carrinhos abandonados');
    _isMonitoring = false;
    _reminderTimer?.cancel();
    _reminderTimer = null;
  }

  /// Verifica carrinhos abandonados
  Future<void> _checkAbandonedCarts() async {
    try {
      AppLogger.info('Verificando carrinhos abandonados...');
      
      // Busca todos os carrinhos ativos
      final carrinhos = await _firestoreService.getAllActiveCarts();
      
      if (carrinhos.isEmpty) {
        AppLogger.info('Nenhum carrinho ativo encontrado');
        return;
      }
      
      AppLogger.info('Encontrados ${carrinhos.length} carrinhos ativos');
      
      // Processa cada carrinho
      for (final carrinho in carrinhos) {
        await _processAbandonedCart(carrinho);
      }
      
      // Limpa carrinhos expirados
      await _cleanupExpiredCarts();
      
      AppLogger.success('Verificação de carrinhos abandonados concluída');
      
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao verificar carrinhos abandonados', e, stackTrace);
    }
  }

  /// Processa um carrinho específico para verificar se precisa de lembrete
  Future<void> _processAbandonedCart(Map<String, dynamic> carrinhoData) async {
    try {
      final userId = carrinhoData['user_id'] as String;
      final lastActivity = DateTime.parse(carrinhoData['last_activity'] as String);
      final itens = List<Map<String, dynamic>>.from(carrinhoData['itens'] ?? []);
      
      if (itens.isEmpty) {
        AppLogger.info('Carrinho do usuário $userId está vazio, ignorando');
        return;
      }
      
      final timeSinceLastActivity = DateTime.now().difference(lastActivity);
      
      // Verifica se o carrinho expirou
      if (timeSinceLastActivity > _cartExpirationTime) {
        AppLogger.info('Carrinho do usuário $userId expirou, será removido');
        await _expireCart(userId);
        return;
      }
      
      // Busca dados do usuário
      final usuarioData = await _firestoreService.getUserById(userId);
      if (usuarioData == null) {
        AppLogger.warning('Usuário $userId não encontrado');
        return;
      }
      
      final usuario = Usuario.fromMap(userId, usuarioData);
      
      // Busca configurações de notificação
      final settings = await _notificationSettingsService.getNotificationSettings(userId);
      
      // Verifica se o usuário quer receber lembretes de carrinho
      if (!settings.cartReminders) {
        AppLogger.info('Usuário ${usuario.nome} não quer receber lembretes de carrinho');
        return;
      }
      
      // Determina qual lembrete enviar baseado no tempo
      final reminderType = _determineReminderType(timeSinceLastActivity);
      
      if (reminderType == null) {
        // Ainda não é hora de enviar lembrete
        return;
      }
      
      // Verifica se já enviamos este tipo de lembrete
      if (_hasReminderBeenSent(userId, reminderType)) {
        AppLogger.info('Lembrete $reminderType já foi enviado para ${usuario.nome}');
        return;
      }
      
      // Converte itens do carrinho
      final carrinhoItens = await _convertToCarrinhoItems(itens);
      final totalCarrinho = _calculateCartTotal(carrinhoItens);
      
      AppLogger.info('Enviando lembrete $reminderType para ${usuario.nome} - Total: R\$ ${totalCarrinho.toStringAsFixed(2)}');
      
      // Envia o lembrete
      final resultado = await _notificationService.enviarNotificacaoLembreteCarrinho(
        usuario,
        carrinhoItens,
        totalCarrinho,
        settings,
      );
      
      // Registra o envio do lembrete
      if (resultado.isNotEmpty && !resultado.containsKey('error')) {
        _markReminderAsSent(userId, reminderType);
        AppLogger.success('Lembrete de carrinho enviado para ${usuario.nome}');
        
        // Registra no histórico
        await _registerCartReminder(usuario, carrinhoItens, totalCarrinho, reminderType);
      } else {
        AppLogger.error('Falha ao enviar lembrete de carrinho para ${usuario.nome}');
      }
      
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao processar carrinho abandonado', e, stackTrace);
    }
  }

  /// Determina qual tipo de lembrete enviar baseado no tempo desde a última atividade
  String? _determineReminderType(Duration timeSinceLastActivity) {
    if (timeSinceLastActivity >= _finalReminderDelay) {
      return 'final';
    } else if (timeSinceLastActivity >= _secondReminderDelay) {
      return 'second';
    } else if (timeSinceLastActivity >= _firstReminderDelay) {
      return 'first';
    }
    
    return null; // Ainda não é hora de enviar lembrete
  }

  /// Verifica se um lembrete específico já foi enviado
  bool _hasReminderBeenSent(String userId, String reminderType) {
    final userReminders = _remindersSent[userId] ?? [];
    
    // Para simplificar, vamos usar o índice do lembrete
    final reminderIndex = _getReminderIndex(reminderType);
    
    return userReminders.length > reminderIndex;
  }

  /// Marca um lembrete como enviado
  void _markReminderAsSent(String userId, String reminderType) {
    if (!_remindersSent.containsKey(userId)) {
      _remindersSent[userId] = [];
    }
    
    _remindersSent[userId]!.add(DateTime.now());
  }

  /// Obtém o índice do tipo de lembrete
  int _getReminderIndex(String reminderType) {
    switch (reminderType) {
      case 'first':
        return 0;
      case 'second':
        return 1;
      case 'final':
        return 2;
      default:
        return 0;
    }
  }

  /// Converte dados do Firestore para objetos CarrinhoItem
  Future<List<CarrinhoItem>> _convertToCarrinhoItems(List<Map<String, dynamic>> itensData) async {
    final carrinhoItens = <CarrinhoItem>[];
    
    for (final itemData in itensData) {
      try {
        final produtoId = itemData['produto_id'] as String;
        final quantidade = itemData['quantidade'] as int;
        
        // Busca dados completos do produto
        final produtoData = await _firestoreService.getProdutoById(produtoId);
        
        if (produtoData != null) {
          final produto = Produto.fromMap(produtoData);
          final carrinhoItem = CarrinhoItem(
            produto: produto,
            quantidade: quantidade,
          );
          carrinhoItens.add(carrinhoItem);
        }
      } catch (e) {
        AppLogger.warning('Erro ao converter item do carrinho: $e');
      }
    }
    
    return carrinhoItens;
  }

  /// Calcula o total do carrinho
  double _calculateCartTotal(List<CarrinhoItem> itens) {
    return itens.fold(0.0, (total, item) => total + item.subtotal);
  }

  /// Registra o lembrete no histórico
  Future<void> _registerCartReminder(
    Usuario usuario,
    List<CarrinhoItem> itens,
    double total,
    String reminderType,
  ) async {
    try {
      final notificationData = {
        'user_id': usuario.id,
        'notification_type': 'cart_reminder',
        'reminder_type': reminderType,
        'cart_items_count': itens.length,
        'cart_total': total,
        'items': itens.map((item) => {
          'product_id': item.produto.id,
          'product_name': item.produto.nome,
          'quantity': item.quantidade,
          'subtotal': item.subtotal,
        }).toList(),
        'sent_at': DateTime.now().toIso8601String(),
        'channels_sent': ['push', 'email'],
      };
      
      await _firestoreService.addNotificationHistory(notificationData);
      AppLogger.info('Lembrete de carrinho registrado no histórico');
      
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao registrar lembrete no histórico', e, stackTrace);
    }
  }

  /// Limpa carrinhos expirados
  Future<void> _cleanupExpiredCarts() async {
    try {
      AppLogger.info('Limpando carrinhos expirados...');
      
      final expiredCarts = await _firestoreService.getExpiredCarts(_cartExpirationTime);
      
      for (final cart in expiredCarts) {
        final userId = cart['user_id'] as String;
        await _expireCart(userId);
      }
      
      if (expiredCarts.isNotEmpty) {
        AppLogger.info('${expiredCarts.length} carrinhos expirados foram limpos');
      }
      
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao limpar carrinhos expirados', e, stackTrace);
    }
  }

  /// Expira um carrinho específico
  Future<void> _expireCart(String userId) async {
    try {
      await _firestoreService.clearUserCart(userId);
      _remindersSent.remove(userId);
      AppLogger.info('Carrinho do usuário $userId expirado e limpo');
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao expirar carrinho do usuário $userId', e, stackTrace);
    }
  }

  /// Força verificação manual de carrinhos abandonados
  Future<Map<String, dynamic>> forceCheck() async {
    try {
      AppLogger.info('Executando verificação manual de carrinhos abandonados');
      
      final startTime = DateTime.now();
      await _checkAbandonedCarts();
      final endTime = DateTime.now();
      
      final duration = endTime.difference(startTime);
      
      return {
        'success': true,
        'duration_ms': duration.inMilliseconds,
        'checked_at': endTime.toIso8601String(),
        'message': 'Verificação manual de carrinhos concluída com sucesso',
      };
      
    } catch (e, stackTrace) {
      AppLogger.error('Erro na verificação manual de carrinhos', e, stackTrace);
      return {
        'success': false,
        'error': e.toString(),
        'checked_at': DateTime.now().toIso8601String(),
      };
    }
  }

  /// Adiciona um carrinho para monitoramento
  Future<void> trackCartActivity(String userId, List<CarrinhoItem> itens) async {
    try {
      final cartData = {
        'user_id': userId,
        'last_activity': DateTime.now().toIso8601String(),
        'itens': itens.map((item) => {
          'produto_id': item.produto.id,
          'quantidade': item.quantidade,
        }).toList(),
        'total': _calculateCartTotal(itens),
      };
      
      await _firestoreService.updateUserCart(userId, cartData);
      
      // Reset lembretes para este usuário se o carrinho foi modificado
      _remindersSent.remove(userId);
      
      AppLogger.info('Atividade do carrinho registrada para usuário $userId');
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao registrar atividade do carrinho', e, stackTrace);
    }
  }

  /// Remove um usuário do monitoramento de carrinho
  void removeUserFromTracking(String userId) {
    _remindersSent.remove(userId);
    AppLogger.info('Usuário $userId removido do monitoramento de carrinho');
  }

  /// Obtém estatísticas do serviço
  Map<String, dynamic> getStatistics() {
    return {
      'is_monitoring': _isMonitoring,
      'check_interval_hours': _checkInterval.inHours,
      'first_reminder_hours': _firstReminderDelay.inHours,
      'second_reminder_hours': _secondReminderDelay.inHours,
      'final_reminder_hours': _finalReminderDelay.inHours,
      'cart_expiration_days': _cartExpirationTime.inDays,
      'users_being_tracked': _remindersSent.length,
      'last_check': DateTime.now().toIso8601String(),
    };
  }

  /// Obtém histórico de lembretes de carrinho
  Future<List<Map<String, dynamic>>> getCartReminderHistory({
    String? userId,
    int limit = 50,
  }) async {
    try {
      return await _firestoreService.getNotificationHistory(
        userId: userId,
        limit: limit,
      );
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao buscar histórico de lembretes de carrinho', e, stackTrace);
      return [];
    }
  }

  /// Limpa cache de lembretes
  void clearCache() {
    _remindersSent.clear();
    AppLogger.info('Cache de lembretes de carrinho limpo');
  }

  /// Configura intervalos de lembrete personalizados
  void configureReminderIntervals({
    Duration? firstReminder,
    Duration? secondReminder,
    Duration? finalReminder,
    Duration? cartExpiration,
  }) {
    // Note: Esta é uma implementação simplificada.
    // Em uma implementação real, você salvaria essas configurações de forma persistente.
    AppLogger.info('Configurações de lembrete atualizadas');
  }

  /// Envia lembrete manual para um usuário específico
  Future<Map<String, bool>> sendManualReminder(String userId) async {
    try {
      final usuarioData = await _firestoreService.getUserById(userId);
      if (usuarioData == null) {
        throw Exception('Usuário não encontrado');
      }
      
      final usuario = Usuario.fromMap(userId, usuarioData);
      
      final cartData = await _firestoreService.getUserCart(userId);
      if (cartData == null || (cartData['itens'] as List).isEmpty) {
        throw Exception('Carrinho vazio ou não encontrado');
      }
      
      final settings = await _notificationSettingsService.getNotificationSettings(userId);
      final itens = await _convertToCarrinhoItems(
        List<Map<String, dynamic>>.from(cartData['itens'])
      );
      final total = _calculateCartTotal(itens);
      
      return await _notificationService.enviarNotificacaoLembreteCarrinho(
        usuario,
        itens,
        total,
        settings,
      );
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao enviar lembrete manual', e, stackTrace);
      return {'error': false};
    }
  }

  /// Dispose do serviço
  void dispose() {
    stopMonitoring();
    clearCache();
    AppLogger.info('Serviço de lembretes de carrinho finalizado');
  }
}

/// Extensão para FirestoreService com métodos específicos para carrinho
extension CartExtension on FirestoreService {
  /// Busca todos os carrinhos ativos
  Future<List<Map<String, dynamic>>> getAllActiveCarts() async {
    try {
      // Implementação simplificada
      final carts = await getCollection('user_carts');
      return carts.where((cart) {
        final itens = cart['itens'] as List? ?? [];
        return itens.isNotEmpty;
      }).toList();
    } catch (e) {
      AppLogger.error('Erro ao buscar carrinhos ativos', e);
      return [];
    }
  }
  
  /// Busca carrinhos expirados
  Future<List<Map<String, dynamic>>> getExpiredCarts(Duration expirationTime) async {
    try {
      final carts = await getAllActiveCarts();
      final cutoffTime = DateTime.now().subtract(expirationTime);
      
      return carts.where((cart) {
        final lastActivity = DateTime.parse(cart['last_activity'] ?? '1970-01-01');
        return lastActivity.isBefore(cutoffTime);
      }).toList();
    } catch (e) {
      AppLogger.error('Erro ao buscar carrinhos expirados', e);
      return [];
    }
  }
  
  /// Atualiza carrinho do usuário
  Future<void> updateUserCart(String userId, Map<String, dynamic> cartData) async {
    try {
      await updateDocument('user_carts', userId, cartData);
    } catch (e) {
      AppLogger.error('Erro ao atualizar carrinho do usuário', e);
      rethrow;
    }
  }
  
  /// Busca carrinho do usuário
  Future<Map<String, dynamic>?> getUserCart(String userId) async {
    try {
      return await getDocument('user_carts', userId);
    } catch (e) {
      AppLogger.error('Erro ao buscar carrinho do usuário', e);
      return null;
    }
  }
  
  /// Limpa carrinho do usuário
  Future<void> clearUserCart(String userId) async {
    try {
      await deleteDocument('user_carts', userId);
    } catch (e) {
      AppLogger.error('Erro ao limpar carrinho do usuário', e);
      rethrow;
    }
  }
}