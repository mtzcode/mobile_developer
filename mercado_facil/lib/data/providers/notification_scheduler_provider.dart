import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/notification_scheduler.dart';
import '../services/favorites_promotion_detector.dart';
import '../services/cart_reminder_service.dart';
import '../services/multi_channel_notification_service.dart';

import '../../core/utils/logger.dart';
import 'providers_config.dart';

/// Provider para o agendador de notificações
final notificationSchedulerProvider = Provider<NotificationScheduler>((ref) {
  final favoritesDetector = ref.watch(favoritesPromotionDetectorProvider);
  final cartReminderService = ref.watch(cartReminderServiceProvider);
  final multiChannelService = ref.watch(multiChannelNotificationServiceProvider);
  final notificationService = ref.watch(notificationServiceProvider);
  final firestoreService = ref.watch(firestoreServiceProvider);
  
  return NotificationScheduler(
    favoritesDetector: favoritesDetector,
    cartReminderService: cartReminderService,
    notificationService: multiChannelService,
    notificationSettingsService: notificationService,
    firestoreService: firestoreService,
  );
});

/// Provider para o detector de promoções em favoritos
final favoritesPromotionDetectorProvider = Provider<FavoritesPromotionDetector>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  final multiChannelService = ref.watch(multiChannelNotificationServiceProvider);
  final notificationService = ref.watch(notificationServiceProvider);
  
  return FavoritesPromotionDetector(
    firestoreService: firestoreService,
    notificationService: multiChannelService,
    notificationSettingsService: notificationService,
  );
});

/// Provider para o serviço de lembretes de carrinho
final cartReminderServiceProvider = Provider<CartReminderService>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  final multiChannelService = ref.watch(multiChannelNotificationServiceProvider);
  final notificationService = ref.watch(notificationServiceProvider);
  
  return CartReminderService(
    firestoreService: firestoreService,
    notificationService: multiChannelService,
    notificationSettingsService: notificationService,
  );
});

/// Provider para o serviço de notificações multi-canal
final multiChannelNotificationServiceProvider = Provider<MultiChannelNotificationService>((ref) {
  return MultiChannelNotificationService();
});

/// Provider para controlar o estado do agendador
final notificationSchedulerStateProvider = StateNotifierProvider<NotificationSchedulerStateNotifier, NotificationSchedulerState>((ref) {
  final scheduler = ref.watch(notificationSchedulerProvider);
  return NotificationSchedulerStateNotifier(scheduler);
});

/// Estado do agendador de notificações
class NotificationSchedulerState {
  final bool isRunning;
  final Map<String, dynamic> statistics;
  final Map<String, dynamic> status;
  final DateTime? lastUpdate;
  final String? error;
  
  const NotificationSchedulerState({
    this.isRunning = false,
    this.statistics = const {},
    this.status = const {},
    this.lastUpdate,
    this.error,
  });
  
  NotificationSchedulerState copyWith({
    bool? isRunning,
    Map<String, dynamic>? statistics,
    Map<String, dynamic>? status,
    DateTime? lastUpdate,
    String? error,
  }) {
    return NotificationSchedulerState(
      isRunning: isRunning ?? this.isRunning,
      statistics: statistics ?? this.statistics,
      status: status ?? this.status,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      error: error,
    );
  }
}

/// Notifier para gerenciar o estado do agendador
class NotificationSchedulerStateNotifier extends StateNotifier<NotificationSchedulerState> {
  final NotificationScheduler _scheduler;
  
  NotificationSchedulerStateNotifier(this._scheduler) : super(const NotificationSchedulerState()) {
    _initializeScheduler();
  }
  
  /// Inicializa o agendador
  void _initializeScheduler() {
    try {
      _updateStatus();
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao inicializar agendador', e, stackTrace);
      state = state.copyWith(
        error: 'Erro ao inicializar: ${e.toString()}',
        lastUpdate: DateTime.now(),
      );
    }
  }
  
  /// Inicia o agendador
  Future<void> start() async {
    try {
      if (state.isRunning) {
        AppLogger.warning('Agendador já está rodando');
        return;
      }
      
      _scheduler.start();
      
      state = state.copyWith(
        isRunning: true,
        error: null,
        lastUpdate: DateTime.now(),
      );
      
      // Atualiza status após iniciar
      await Future.delayed(const Duration(seconds: 1));
      _updateStatus();
      
      AppLogger.success('Agendador de notificações iniciado via provider');
      
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao iniciar agendador via provider', e, stackTrace);
      state = state.copyWith(
        error: 'Erro ao iniciar: ${e.toString()}',
        lastUpdate: DateTime.now(),
      );
    }
  }
  
  /// Para o agendador
  void stop() {
    try {
      if (!state.isRunning) {
        AppLogger.warning('Agendador não está rodando');
        return;
      }
      
      _scheduler.stop();
      
      state = state.copyWith(
        isRunning: false,
        error: null,
        lastUpdate: DateTime.now(),
      );
      
      AppLogger.success('Agendador de notificações parado via provider');
      
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao parar agendador via provider', e, stackTrace);
      state = state.copyWith(
        error: 'Erro ao parar: ${e.toString()}',
        lastUpdate: DateTime.now(),
      );
    }
  }
  
  /// Força execução de todas as tarefas
  Future<Map<String, dynamic>> forceRunAllTasks() async {
    try {
      final result = await _scheduler.forceRunAllTasks();
      
      // Atualiza status após execução
      _updateStatus();
      
      state = state.copyWith(
        error: null,
        lastUpdate: DateTime.now(),
      );
      
      return result;
      
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao executar tarefas manualmente', e, stackTrace);
      
      state = state.copyWith(
        error: 'Erro na execução manual: ${e.toString()}',
        lastUpdate: DateTime.now(),
      );
      
      return {
        'success': false,
        'error': e.toString(),
        'executed_at': DateTime.now().toIso8601String(),
      };
    }
  }
  
  /// Atualiza o status do agendador
  void _updateStatus() {
    try {
      final status = _scheduler.getStatus();
      
      state = state.copyWith(
        isRunning: status['is_running'] ?? false,
        statistics: status['statistics'] ?? {},
        status: status,
        lastUpdate: DateTime.now(),
        error: null,
      );
      
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao atualizar status do agendador', e, stackTrace);
      state = state.copyWith(
        error: 'Erro ao atualizar status: ${e.toString()}',
        lastUpdate: DateTime.now(),
      );
    }
  }
  
  /// Atualiza status periodicamente
  void refreshStatus() {
    _updateStatus();
  }
  
  /// Reinicia o agendador
  Future<void> restart() async {
    try {
      AppLogger.info('Reiniciando agendador de notificações');
      
      if (state.isRunning) {
        stop();
        await Future.delayed(const Duration(seconds: 2));
      }
      
      await start();
      
      AppLogger.success('Agendador reiniciado com sucesso');
      
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao reiniciar agendador', e, stackTrace);
      state = state.copyWith(
        error: 'Erro ao reiniciar: ${e.toString()}',
        lastUpdate: DateTime.now(),
      );
    }
  }
  
  @override
  void dispose() {
    try {
      if (state.isRunning) {
        _scheduler.stop();
      }
      _scheduler.dispose();
    } catch (e) {
      AppLogger.error('Erro ao fazer dispose do agendador', e);
    }
    super.dispose();
  }
}

/// Provider para estatísticas de notificação em tempo real
final notificationStatisticsProvider = StreamProvider<Map<String, dynamic>>((ref) async* {
  final schedulerState = ref.watch(notificationSchedulerStateProvider);
  
  // Emite estatísticas a cada mudança de estado
  yield schedulerState.statistics;
  
  // Atualiza estatísticas a cada 30 segundos se o agendador estiver rodando
  if (schedulerState.isRunning) {
    await for (final _ in Stream.periodic(const Duration(seconds: 30))) {
      final currentState = ref.read(notificationSchedulerStateProvider);
      if (currentState.isRunning) {
        ref.read(notificationSchedulerStateProvider.notifier).refreshStatus();
        yield ref.read(notificationSchedulerStateProvider).statistics;
      } else {
        break;
      }
    }
  }
});

/// Provider para verificar se o agendador está saudável
final schedulerHealthProvider = Provider<bool>((ref) {
  final state = ref.watch(notificationSchedulerStateProvider);
  
  // Considera saudável se:
  // 1. Está rodando
  // 2. Não tem erros
  // 3. Foi atualizado recentemente (últimos 5 minutos)
  final isHealthy = state.isRunning && 
                   state.error == null && 
                   state.lastUpdate != null &&
                   DateTime.now().difference(state.lastUpdate!).inMinutes < 5;
  
  return isHealthy;
});

/// Provider para obter resumo das estatísticas
final notificationSummaryProvider = Provider<Map<String, dynamic>>((ref) {
  final statistics = ref.watch(notificationStatisticsProvider).asData?.value ?? {};
  
  final totalSent = statistics['total_sent'] ?? 0;
  final errors = statistics['errors'] ?? 0;
  final successRate = totalSent > 0 ? ((totalSent - errors) / totalSent * 100).round() : 100;
  
  return {
    'total_notifications': totalSent,
    'success_rate': successRate,
    'error_count': errors,
    'favorites_notifications': statistics['favorites_sent'] ?? 0,
    'cart_reminders': statistics['cart_reminders_sent'] ?? 0,
    'new_products': statistics['new_products_sent'] ?? 0,
    'price_alerts': statistics['price_alerts_sent'] ?? 0,
  };
});

/// Provider para controle automático do agendador baseado em configurações do usuário
final autoSchedulerControlProvider = Provider<void>((ref) {
  final schedulerNotifier = ref.read(notificationSchedulerStateProvider.notifier);
  
  // Auto-inicia o agendador quando há um usuário logado
  ref.listen(usuarioLogadoProvider, (previous, next) {
    if (previous == null && next != null) {
      // Usuário fez login - inicia agendador
      Future.microtask(() => schedulerNotifier.start());
      AppLogger.info('Auto-iniciando agendador para usuário: ${next.nome}');
    } else if (previous != null && next == null) {
      // Usuário fez logout - para agendador
      schedulerNotifier.stop();
      AppLogger.info('Auto-parando agendador - usuário fez logout');
    }
  });
});

/// Provider para configurações do agendador
final schedulerConfigProvider = StateProvider<SchedulerConfig>((ref) {
  return const SchedulerConfig();
});

/// Configurações do agendador
class SchedulerConfig {
  final bool autoStart;
  final bool enableDailyReports;
  final bool enableWeeklyReports;
  final Duration checkInterval;
  final List<int> allowedHours;
  
  const SchedulerConfig({
    this.autoStart = true,
    this.enableDailyReports = true,
    this.enableWeeklyReports = true,
    this.checkInterval = const Duration(minutes: 15),
    this.allowedHours = const [8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22],
  });
  
  SchedulerConfig copyWith({
    bool? autoStart,
    bool? enableDailyReports,
    bool? enableWeeklyReports,
    Duration? checkInterval,
    List<int>? allowedHours,
  }) {
    return SchedulerConfig(
      autoStart: autoStart ?? this.autoStart,
      enableDailyReports: enableDailyReports ?? this.enableDailyReports,
      enableWeeklyReports: enableWeeklyReports ?? this.enableWeeklyReports,
      checkInterval: checkInterval ?? this.checkInterval,
      allowedHours: allowedHours ?? this.allowedHours,
    );
  }
}