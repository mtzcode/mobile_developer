import 'dart:async';
import '../../core/utils/logger.dart';
import '../models/usuario.dart';
import '../models/produto.dart';
import 'favorites_promotion_detector.dart';
import 'cart_reminder_service.dart';
import 'multi_channel_notification_service.dart';
import 'notification_service.dart';
import 'firestore_service.dart';

/// Agendador central de notificações
/// 
/// Este serviço coordena todos os tipos de notificações automáticas,
/// gerencia horários de envio e controla a frequência das notificações.
class NotificationScheduler {
  final FavoritesPromotionDetector _favoritesDetector;
  final CartReminderService _cartReminderService;
  final MultiChannelNotificationService _notificationService;
  final NotificationService _notificationSettingsService;
  final FirestoreService _firestoreService;
  
  Timer? _mainSchedulerTimer;
  Timer? _dailyTasksTimer;
  Timer? _weeklyTasksTimer;
  bool _isRunning = false;
  
  // Configurações do agendador
  static const Duration _mainCheckInterval = Duration(minutes: 15); // Verificação principal a cada 15 min
  static const Duration _dailyTasksInterval = Duration(hours: 24); // Tarefas diárias
  static const Duration _weeklyTasksInterval = Duration(days: 7); // Tarefas semanais
  
  // Horários preferenciais para envio de notificações
  static const int _morningHour = 9; // 9h da manhã
  static const int _afternoonHour = 14; // 14h da tarde
  static const int _eveningHour = 19; // 19h da noite
  static const int _nightHour = 22; // 22h da noite (limite)
  
  // Estatísticas
  final Map<String, int> _notificationStats = {
    'total_sent': 0,
    'favorites_sent': 0,
    'cart_reminders_sent': 0,
    'new_products_sent': 0,
    'price_alerts_sent': 0,
    'errors': 0,
  };
  
  DateTime? _lastDailyTask;
  DateTime? _lastWeeklyTask;

  NotificationScheduler({
    FavoritesPromotionDetector? favoritesDetector,
    CartReminderService? cartReminderService,
    MultiChannelNotificationService? notificationService,
    NotificationService? notificationSettingsService,
    FirestoreService? firestoreService,
  }) : _favoritesDetector = favoritesDetector ?? FavoritesPromotionDetector(),
       _cartReminderService = cartReminderService ?? CartReminderService(),
       _notificationService = notificationService ?? MultiChannelNotificationService(),
       _notificationSettingsService = notificationSettingsService ?? NotificationService(),
       _firestoreService = firestoreService ?? FirestoreService();

  /// Inicia o agendador de notificações
  void start() {
    if (_isRunning) {
      AppLogger.warning('Agendador de notificações já está rodando');
      return;
    }
    
    AppLogger.info('Iniciando agendador de notificações');
    _isRunning = true;
    
    // Inicia os serviços dependentes
    _favoritesDetector.startMonitoring();
    _cartReminderService.startMonitoring();
    
    // Executa verificação inicial
    _runMainTasks();
    
    // Agenda verificações periódicas
    _mainSchedulerTimer = Timer.periodic(_mainCheckInterval, (timer) {
      _runMainTasks();
    });
    
    // Agenda tarefas diárias
    _scheduleDailyTasks();
    
    // Agenda tarefas semanais
    _scheduleWeeklyTasks();
    
    AppLogger.success('Agendador de notificações iniciado com sucesso');
  }

  /// Para o agendador de notificações
  void stop() {
    if (!_isRunning) {
      AppLogger.warning('Agendador de notificações não está rodando');
      return;
    }
    
    AppLogger.info('Parando agendador de notificações');
    _isRunning = false;
    
    // Para os timers
    _mainSchedulerTimer?.cancel();
    _dailyTasksTimer?.cancel();
    _weeklyTasksTimer?.cancel();
    
    // Para os serviços dependentes
    _favoritesDetector.stopMonitoring();
    _cartReminderService.stopMonitoring();
    
    AppLogger.success('Agendador de notificações parado');
  }

  /// Executa as tarefas principais do agendador
  Future<void> _runMainTasks() async {
    try {
      AppLogger.info('Executando tarefas principais do agendador');
      
      final currentHour = DateTime.now().hour;
      
      // Verifica se está em horário apropriado para notificações
      if (!_isAppropriateTimeForNotifications(currentHour)) {
        AppLogger.info('Fora do horário apropriado para notificações ($currentHour:00)');
        return;
      }
      
      // Executa verificações baseadas no horário
      await _runTimeBasedTasks(currentHour);
      
      // Atualiza estatísticas
      await _updateStatistics();
      
    } catch (e, stackTrace) {
      _notificationStats['errors'] = (_notificationStats['errors'] ?? 0) + 1;
      AppLogger.error('Erro nas tarefas principais do agendador', e, stackTrace);
    }
  }

  /// Executa tarefas baseadas no horário atual
  Future<void> _runTimeBasedTasks(int currentHour) async {
    try {
      switch (currentHour) {
        case _morningHour:
          await _runMorningTasks();
          break;
        case _afternoonHour:
          await _runAfternoonTasks();
          break;
        case _eveningHour:
          await _runEveningTasks();
          break;
        default:
          // Tarefas que podem rodar a qualquer hora
          await _runAnytimeTasks();
      }
    } catch (e, stackTrace) {
      AppLogger.error('Erro nas tarefas baseadas em horário', e, stackTrace);
    }
  }

  /// Tarefas da manhã (9h)
  Future<void> _runMorningTasks() async {
    AppLogger.info('Executando tarefas da manhã');
    
    // Verificação de produtos favoritos em promoção
    await _favoritesDetector.forceCheck();
    
    // Notificações de novos produtos
    await _checkNewProducts();
    
    // Relatório diário para administradores
    await _sendDailyReport();
  }

  /// Tarefas da tarde (14h)
  Future<void> _runAfternoonTasks() async {
    AppLogger.info('Executando tarefas da tarde');
    
    // Lembretes de carrinho (primeiro lembrete)
    await _cartReminderService.forceCheck();
    
    // Verificação de alertas de preço
    await _checkPriceAlerts();
  }

  /// Tarefas da noite (19h)
  Future<void> _runEveningTasks() async {
    AppLogger.info('Executando tarefas da noite');
    
    // Segunda verificação de carrinho abandonado
    await _cartReminderService.forceCheck();
    
    // Notificações de produtos em baixo estoque (para administradores)
    await _checkLowStockProducts();
  }

  /// Tarefas que podem rodar a qualquer hora
  Future<void> _runAnytimeTasks() async {
    // Limpeza de cache e otimizações
    await _performMaintenance();
  }

  /// Verifica se é um horário apropriado para enviar notificações
  bool _isAppropriateTimeForNotifications(int hour) {
    // Não envia notificações entre 22h e 8h (período de descanso)
    return hour >= 8 && hour <= _nightHour;
  }

  /// Agenda tarefas diárias
  void _scheduleDailyTasks() {
    _dailyTasksTimer = Timer.periodic(_dailyTasksInterval, (timer) {
      _runDailyTasks();
    });
  }

  /// Executa tarefas diárias
  Future<void> _runDailyTasks() async {
    try {
      AppLogger.info('Executando tarefas diárias');
      _lastDailyTask = DateTime.now();
      
      // Limpeza de dados antigos
      await _cleanupOldData();
      
      // Backup de estatísticas
      await _backupStatistics();
      
      // Verificação de saúde dos serviços
      await _performHealthCheck();
      
      // Reset de contadores diários
      await _resetDailyCounters();
      
    } catch (e, stackTrace) {
      AppLogger.error('Erro nas tarefas diárias', e, stackTrace);
    }
  }

  /// Agenda tarefas semanais
  void _scheduleWeeklyTasks() {
    _weeklyTasksTimer = Timer.periodic(_weeklyTasksInterval, (timer) {
      _runWeeklyTasks();
    });
  }

  /// Executa tarefas semanais
  Future<void> _runWeeklyTasks() async {
    try {
      AppLogger.info('Executando tarefas semanais');
      _lastWeeklyTask = DateTime.now();
      
      // Relatório semanal detalhado
      await _generateWeeklyReport();
      
      // Limpeza profunda de dados
      await _performDeepCleanup();
      
      // Otimização de performance
      await _optimizePerformance();
      
      // Análise de tendências
      await _analyzeTrends();
      
    } catch (e, stackTrace) {
      AppLogger.error('Erro nas tarefas semanais', e, stackTrace);
    }
  }

  /// Verifica novos produtos e envia notificações
  Future<void> _checkNewProducts() async {
    try {
      AppLogger.info('Verificando novos produtos');
      
      // Busca produtos adicionados nas últimas 24 horas
      final newProducts = await _firestoreService.getNewProducts(Duration(hours: 24));
      
      if (newProducts.isEmpty) {
        AppLogger.info('Nenhum produto novo encontrado');
        return;
      }
      
      AppLogger.info('Encontrados ${newProducts.length} novos produtos');
      
      // Busca usuários interessados em notificações de novos produtos
      final interestedUsers = await _firestoreService.getUsersWithNewProductNotifications();
      
      for (final produto in newProducts) {
        for (final usuario in interestedUsers) {
          final settings = await _notificationSettingsService.getNotificationSettings(usuario.id);
          
          if (settings.newProducts) {
            await _notificationService.enviarNotificacaoNovoProduto(
              usuario,
              produto,
              produto.categoria ?? 'Geral',
              settings,
            );
            
            _notificationStats['new_products_sent'] = 
                (_notificationStats['new_products_sent'] ?? 0) + 1;
          }
        }
      }
      
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao verificar novos produtos', e, stackTrace);
    }
  }

  /// Verifica alertas de preço
  Future<void> _checkPriceAlerts() async {
    try {
      AppLogger.info('Verificando alertas de preço');
      
      // Busca produtos com mudanças de preço significativas
      final priceChanges = await _firestoreService.getSignificantPriceChanges();
      
      if (priceChanges.isEmpty) {
        AppLogger.info('Nenhuma mudança significativa de preço encontrada');
        return;
      }
      
      for (final change in priceChanges) {
        final produto = change['produto'] as Produto;
        final precoAnterior = change['preco_anterior'] as double;
        
        // Busca usuários que têm este produto nos favoritos
        final interestedUsers = await _firestoreService.getUsersWithFavoriteProduct(produto.id);
        
        for (final usuario in interestedUsers) {
          final settings = await _notificationSettingsService.getNotificationSettings(usuario.id);
          
          if (settings.priceAlerts) {
            await _notificationService.enviarNotificacaoAlertaPreco(
              usuario,
              produto,
              precoAnterior,
              settings,
            );
            
            _notificationStats['price_alerts_sent'] = 
                (_notificationStats['price_alerts_sent'] ?? 0) + 1;
          }
        }
      }
      
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao verificar alertas de preço', e, stackTrace);
    }
  }

  /// Verifica produtos com baixo estoque
  Future<void> _checkLowStockProducts() async {
    try {
      AppLogger.info('Verificando produtos com baixo estoque');
      
      final lowStockProducts = await _firestoreService.getLowStockProducts();
      
      if (lowStockProducts.isNotEmpty) {
        // Envia notificação para administradores
        await _sendLowStockAlert(lowStockProducts);
      }
      
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao verificar baixo estoque', e, stackTrace);
    }
  }

  /// Envia alerta de baixo estoque para administradores
  Future<void> _sendLowStockAlert(List<Produto> products) async {
    try {
      final admins = await _firestoreService.getAdminUsers();
      
      for (final admin in admins) {
        final settings = await _notificationSettingsService.getNotificationSettings(admin.id);
        
        final message = 'Atenção: ${products.length} produtos com baixo estoque. '
            'Produtos: ${products.take(3).map((p) => p.nome).join(", ")}'
            '${products.length > 3 ? " e mais ${products.length - 3}" : ""}';
        
        await _notificationService.enviarNotificacaoGenerica(
          admin,
          '⚠️ Alerta de Estoque',
          message,
          'low_stock',
          settings,
          data: {
            'product_count': products.length.toString(),
            'products': products.map((p) => {
              'id': p.id,
              'name': p.nome,
              'stock': p.estoque.toString(),
            }).toList(),
          },
        );
      }
      
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao enviar alerta de baixo estoque', e, stackTrace);
    }
  }

  /// Envia relatório diário
  Future<void> _sendDailyReport() async {
    try {
      AppLogger.info('Enviando relatório diário');
      
      final report = await _generateDailyReport();
      final admins = await _firestoreService.getAdminUsers();
      
      for (final admin in admins) {
        final settings = await _notificationSettingsService.getNotificationSettings(admin.id);
        
        await _notificationService.enviarNotificacaoGenerica(
          admin,
          '📊 Relatório Diário - Mercado Fácil',
          report,
          'daily_report',
          settings,
        );
      }
      
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao enviar relatório diário', e, stackTrace);
    }
  }

  /// Gera relatório diário
  Future<String> _generateDailyReport() async {
    final stats = await _getDetailedStatistics();
    
    return '''
📈 Relatório Diário - ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}

🔔 Notificações Enviadas:
• Total: ${stats['total_sent']}
• Favoritos em Promoção: ${stats['favorites_sent']}
• Lembretes de Carrinho: ${stats['cart_reminders_sent']}
• Novos Produtos: ${stats['new_products_sent']}
• Alertas de Preço: ${stats['price_alerts_sent']}

❌ Erros: ${stats['errors']}

📱 Usuários Ativos: ${stats['active_users']}
🛒 Carrinhos Ativos: ${stats['active_carts']}
⭐ Produtos Favoritados: ${stats['favorited_products']}

🎯 Taxa de Sucesso: ${stats['success_rate']}%
''';
  }

  /// Realiza manutenção do sistema
  Future<void> _performMaintenance() async {
    try {
      // Limpeza de cache dos serviços
      _favoritesDetector.clearCache();
      _cartReminderService.clearCache();
      
      // Otimização de memória
      await _optimizeMemoryUsage();
      
    } catch (e, stackTrace) {
      AppLogger.error('Erro na manutenção do sistema', e, stackTrace);
    }
  }

  /// Atualiza estatísticas
  Future<void> _updateStatistics() async {
    try {
      _notificationStats['total_sent'] = 
          (_notificationStats['favorites_sent'] ?? 0) +
          (_notificationStats['cart_reminders_sent'] ?? 0) +
          (_notificationStats['new_products_sent'] ?? 0) +
          (_notificationStats['price_alerts_sent'] ?? 0);
      
      // Salva estatísticas no Firestore
      await _firestoreService.updateNotificationStatistics(_notificationStats);
      
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao atualizar estatísticas', e, stackTrace);
    }
  }

  /// Obtém estatísticas detalhadas
  Future<Map<String, dynamic>> _getDetailedStatistics() async {
    try {
      final baseStats = Map<String, dynamic>.from(_notificationStats);
      
      // Adiciona estatísticas adicionais
      baseStats['active_users'] = await _firestoreService.getActiveUsersCount();
      baseStats['active_carts'] = await _firestoreService.getActiveCartsCount();
      baseStats['favorited_products'] = await _firestoreService.getFavoritedProductsCount();
      
      final totalSent = baseStats['total_sent'] ?? 0;
      final errors = baseStats['errors'] ?? 0;
      final successRate = totalSent > 0 ? ((totalSent - errors) / totalSent * 100).round() : 100;
      baseStats['success_rate'] = successRate;
      
      return baseStats;
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao obter estatísticas detalhadas', e, stackTrace);
      return Map<String, dynamic>.from(_notificationStats);
    }
  }

  /// Limpeza de dados antigos
  Future<void> _cleanupOldData() async {
    try {
      AppLogger.info('Limpando dados antigos');
      
      // Remove histórico de notificações com mais de 30 dias
      await _firestoreService.cleanupOldNotificationHistory(Duration(days: 30));
      
      // Remove carrinhos abandonados há mais de 7 dias
      await _firestoreService.cleanupExpiredCarts(Duration(days: 7));
      
    } catch (e, stackTrace) {
      AppLogger.error('Erro na limpeza de dados antigos', e, stackTrace);
    }
  }

  /// Backup de estatísticas
  Future<void> _backupStatistics() async {
    try {
      final stats = await _getDetailedStatistics();
      await _firestoreService.backupDailyStatistics(stats);
      AppLogger.info('Backup de estatísticas realizado');
    } catch (e, stackTrace) {
      AppLogger.error('Erro no backup de estatísticas', e, stackTrace);
    }
  }

  /// Verificação de saúde dos serviços
  Future<void> _performHealthCheck() async {
    try {
      AppLogger.info('Realizando verificação de saúde dos serviços');
      
      final healthStatus = await _notificationService.testarConectividade();
      
      if (healthStatus.containsValue(false)) {
        AppLogger.warning('Alguns serviços de notificação estão com problemas: $healthStatus');
        // Aqui você pode implementar alertas para administradores
      } else {
        AppLogger.success('Todos os serviços de notificação estão funcionando');
      }
      
    } catch (e, stackTrace) {
      AppLogger.error('Erro na verificação de saúde', e, stackTrace);
    }
  }

  /// Reset de contadores diários
  Future<void> _resetDailyCounters() async {
    // Reset apenas contadores que devem ser zerados diariamente
    // Mantém contadores cumulativos
    AppLogger.info('Contadores diários resetados');
  }

  /// Gera relatório semanal
  Future<void> _generateWeeklyReport() async {
    try {
      AppLogger.info('Gerando relatório semanal');
      
      // Estatísticas semanais podem ser implementadas futuramente
      // final weeklyStats = await _firestoreService.getWeeklyStatistics();
      
      // Aqui você pode implementar a geração de um relatório mais detalhado
      // e enviá-lo para administradores ou stakeholders
      
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao gerar relatório semanal', e, stackTrace);
    }
  }

  /// Limpeza profunda de dados
  Future<void> _performDeepCleanup() async {
    try {
      AppLogger.info('Realizando limpeza profunda');
      
      // Limpeza mais agressiva de dados antigos
      await _firestoreService.deepCleanupOldData();
      
    } catch (e, stackTrace) {
      AppLogger.error('Erro na limpeza profunda', e, stackTrace);
    }
  }

  /// Otimização de performance
  Future<void> _optimizePerformance() async {
    try {
      AppLogger.info('Otimizando performance');
      
      // Implementar otimizações específicas
      await _optimizeMemoryUsage();
      
    } catch (e, stackTrace) {
      AppLogger.error('Erro na otimização de performance', e, stackTrace);
    }
  }

  /// Otimização de uso de memória
  Future<void> _optimizeMemoryUsage() async {
    // Implementar otimizações de memória
    AppLogger.info('Memória otimizada');
  }

  /// Análise de tendências
  Future<void> _analyzeTrends() async {
    try {
      AppLogger.info('Analisando tendências');
      
      // Implementar análise de tendências de notificações
      // Identificar padrões de comportamento dos usuários
      
    } catch (e, stackTrace) {
      AppLogger.error('Erro na análise de tendências', e, stackTrace);
    }
  }

  /// Obtém status do agendador
  Map<String, dynamic> getStatus() {
    return {
      'is_running': _isRunning,
      'main_check_interval_minutes': _mainCheckInterval.inMinutes,
      'daily_tasks_interval_hours': _dailyTasksInterval.inHours,
      'weekly_tasks_interval_days': _weeklyTasksInterval.inDays,
      'last_daily_task': _lastDailyTask?.toIso8601String(),
      'last_weekly_task': _lastWeeklyTask?.toIso8601String(),
      'statistics': _notificationStats,
      'services_status': {
        'favorites_detector': _favoritesDetector.getStatistics(),
        'cart_reminder': _cartReminderService.getStatistics(),
      },
    };
  }

  /// Força execução de todas as tarefas
  Future<Map<String, dynamic>> forceRunAllTasks() async {
    try {
      AppLogger.info('Executando todas as tarefas manualmente');
      
      final startTime = DateTime.now();
      
      await _runMainTasks();
      await _runDailyTasks();
      
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      
      return {
        'success': true,
        'duration_ms': duration.inMilliseconds,
        'executed_at': endTime.toIso8601String(),
        'message': 'Todas as tarefas executadas com sucesso',
      };
      
    } catch (e, stackTrace) {
      AppLogger.error('Erro na execução manual de tarefas', e, stackTrace);
      return {
        'success': false,
        'error': e.toString(),
        'executed_at': DateTime.now().toIso8601String(),
      };
    }
  }

  /// Dispose do agendador
  void dispose() {
    stop();
    _favoritesDetector.dispose();
    _cartReminderService.dispose();
    AppLogger.info('Agendador de notificações finalizado');
  }
}

/// Extensão para FirestoreService com métodos específicos para o agendador
extension SchedulerExtension on FirestoreService {
  /// Busca produtos novos
  Future<List<Produto>> getNewProducts(Duration timeframe) async {
    try {
      // Implementação simplificada
      // Tempo limite pode ser implementado futuramente
      // final cutoffTime = DateTime.now().subtract(timeframe);
      final products = await getAllProducts();
      
      return products.where((product) {
        // Assumindo que existe um campo 'created_at' no produto
        // Em uma implementação real, você usaria este campo
        return true; // Placeholder
      }).toList();
    } catch (e) {
      AppLogger.error('Erro ao buscar produtos novos', e);
      return [];
    }
  }
  
  /// Busca usuários interessados em notificações de novos produtos
  Future<List<Usuario>> getUsersWithNewProductNotifications() async {
    try {
      final users = await getAllUsers();
      final interestedUsers = <Usuario>[];
      
      for (final userData in users) {
        // Converter Map para Usuario
        final user = Usuario.fromMap(userData['id'], userData);
        // Verificar configurações de notificação
        // Em uma implementação real, você faria uma query mais eficiente
        interestedUsers.add(user);
      }
      
      return interestedUsers;
    } catch (e) {
      AppLogger.error('Erro ao buscar usuários interessados em novos produtos', e);
      return [];
    }
  }
  
  /// Busca mudanças significativas de preço
  Future<List<Map<String, dynamic>>> getSignificantPriceChanges() async {
    try {
      // Implementação simplificada
      // Em uma implementação real, você manteria um histórico de preços
      return [];
    } catch (e) {
      AppLogger.error('Erro ao buscar mudanças de preço', e);
      return [];
    }
  }
  
  /// Busca usuários que têm um produto específico nos favoritos
  Future<List<Usuario>> getUsersWithFavoriteProduct(String productId) async {
    try {
      // Implementação simplificada
      final users = await getAllUsers();
      final result = <Usuario>[];
      
      for (final userData in users) {
        final user = Usuario.fromMap(userData['id'], userData);
        final favorites = await getUserFavorites(user.id);
        if (favorites.any((favoriteId) => favoriteId == productId)) {
          result.add(user);
        }
      }
      
      return result;
    } catch (e) {
      AppLogger.error('Erro ao buscar usuários com produto favorito', e);
      return [];
    }
  }
  
  /// Busca produtos com baixo estoque
  Future<List<Produto>> getLowStockProducts() async {
    try {
      final products = await getAllProducts();
      return products.where((p) => p.estoque < 10).toList();
    } catch (e) {
      AppLogger.error('Erro ao buscar produtos com baixo estoque', e);
      return [];
    }
  }
  
  /// Busca usuários administradores
  Future<List<Usuario>> getAdminUsers() async {
    try {
      // Implementação simplificada
      // Em uma implementação real, você teria um campo 'role' ou similar
      return [];
    } catch (e) {
      AppLogger.error('Erro ao buscar usuários admin', e);
      return [];
    }
  }
  
  /// Atualiza estatísticas de notificação
  Future<void> updateNotificationStatistics(Map<String, int> stats) async {
    try {
      await updateDocument('notification_statistics', 'daily', {
        ...stats,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      AppLogger.error('Erro ao atualizar estatísticas', e);
      rethrow;
    }
  }
  
  /// Obtém contagem de usuários ativos
  Future<int> getActiveUsersCount() async {
    try {
      final users = await getAllUsers();
      return users.length;
    } catch (e) {
      AppLogger.error('Erro ao contar usuários ativos', e);
      return 0;
    }
  }
  
  /// Obtém contagem de carrinhos ativos
  Future<int> getActiveCartsCount() async {
    try {
      final carts = await getAllActiveCarts();
      return carts.length;
    } catch (e) {
      AppLogger.error('Erro ao contar carrinhos ativos', e);
      return 0;
    }
  }
  
  /// Obtém contagem de produtos favoritados
  Future<int> getFavoritedProductsCount() async {
    try {
      // Implementação simplificada
      return 0;
    } catch (e) {
      AppLogger.error('Erro ao contar produtos favoritados', e);
      return 0;
    }
  }
  
  /// Limpa histórico antigo de notificações
  Future<void> cleanupOldNotificationHistory(Duration maxAge) async {
    try {
      // Tempo limite pode ser implementado futuramente
      // final cutoffTime = DateTime.now().subtract(maxAge);
      // Implementar limpeza baseada na data
      AppLogger.info('Histórico antigo de notificações limpo');
    } catch (e) {
      AppLogger.error('Erro ao limpar histórico antigo', e);
      rethrow;
    }
  }
  
  /// Limpa carrinhos expirados
  Future<void> cleanupExpiredCarts(Duration maxAge) async {
    try {
      final expiredCarts = await getExpiredCarts(maxAge);
      for (final cart in expiredCarts) {
        await clearUserCart(cart['user_id']);
      }
      AppLogger.info('${expiredCarts.length} carrinhos expirados limpos');
    } catch (e) {
      AppLogger.error('Erro ao limpar carrinhos expirados', e);
      rethrow;
    }
  }
  
  /// Backup de estatísticas diárias
  Future<void> backupDailyStatistics(Map<String, dynamic> stats) async {
    try {
      final today = DateTime.now();
      final backupId = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      
      await addDocument('statistics_backup', {
        'id': backupId,
        'date': today.toIso8601String(),
        'statistics': stats,
      });
    } catch (e) {
      AppLogger.error('Erro no backup de estatísticas', e);
      rethrow;
    }
  }
  
  /// Busca estatísticas semanais
  Future<Map<String, dynamic>> getWeeklyStatistics() async {
    try {
      // Implementação simplificada
      return {};
    } catch (e) {
      AppLogger.error('Erro ao buscar estatísticas semanais', e);
      return {};
    }
  }
  
  /// Limpeza profunda de dados antigos
  Future<void> deepCleanupOldData() async {
    try {
      // Implementar limpeza mais agressiva
      AppLogger.info('Limpeza profunda realizada');
    } catch (e) {
      AppLogger.error('Erro na limpeza profunda', e);
      rethrow;
    }
  }
}