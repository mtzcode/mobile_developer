import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../core/utils/logger.dart';
import '../services/notification_service.dart';
import 'user_provider_riverpod.dart';

/// Estado das notificações
class NotificationState {
  final bool isInitialized;
  final String? fcmToken;
  final List<Map<String, dynamic>> notifications;
  final int unreadCount;
  final Map<String, Map<String, bool>> settings;
  final bool isLoading;
  final String? error;

  const NotificationState({
    this.isInitialized = false,
    this.fcmToken,
    this.notifications = const [],
    this.unreadCount = 0,
    this.settings = const {},
    this.isLoading = false,
    this.error,
  });

  NotificationState copyWith({
    bool? isInitialized,
    String? fcmToken,
    List<Map<String, dynamic>>? notifications,
    int? unreadCount,
    Map<String, Map<String, bool>>? settings,
    bool? isLoading,
    String? error,
  }) {
    return NotificationState(
      isInitialized: isInitialized ?? this.isInitialized,
      fcmToken: fcmToken ?? this.fcmToken,
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      settings: settings ?? this.settings,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Provider do NotificationService
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

/// Provider do estado das notificações
final notificationProvider = StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  final service = ref.watch(notificationServiceProvider);
  return NotificationNotifier(service);
});

/// Notifier para gerenciar o estado das notificações
class NotificationNotifier extends StateNotifier<NotificationState> {
  final NotificationService _service;

  NotificationNotifier(this._service) : super(const NotificationState()) {
    _initialize();
  }

  /// Inicializa o serviço de notificações
  Future<void> _initialize() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      // Configurar callbacks
      _service.onMessageReceived = _handleMessageReceived;
      _service.onMessageTapped = _handleMessageTapped;
      
      // Inicializar serviço
      await _service.initialize();
      
      // Carregar dados iniciais
      await _loadInitialData();
      
      state = state.copyWith(
        isInitialized: true,
        isLoading: false,
        fcmToken: _service.fcmToken,
      );
      
      AppLogger.success('NotificationProvider inicializado com sucesso');
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao inicializar NotificationProvider', e, stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: 'Erro ao inicializar notificações: $e',
      );
    }
  }

  /// Carrega dados iniciais
  Future<void> _loadInitialData() async {
    try {
      final notifications = await _service.getNotificationHistory();
      final unreadCount = await _service.getUnreadNotificationCount();
      final settingsModel = await _service.getNotificationSettings('default');
      
      // Converter NotificationSettings para Map<String, Map<String, bool>>
      final settings = <String, Map<String, bool>>{
        'channels': {
          'push': settingsModel.pushEnabled,
          'email': settingsModel.emailEnabled,
        },
        'types': {
          'orderUpdates': settingsModel.orderUpdates,
          'promotions': settingsModel.promotions,
          'systemNotifications': settingsModel.systemNotifications,
          'favoritePromotions': settingsModel.favoritePromotions,
          'cartReminders': settingsModel.cartReminders,
        },
      };
      
      state = state.copyWith(
        notifications: notifications,
        unreadCount: unreadCount,
        settings: settings,
      );
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao carregar dados iniciais', e, stackTrace);
    }
  }

  /// Manipula mensagem recebida em foreground
  void _handleMessageReceived(RemoteMessage message) {
    // Atualizar lista de notificações
    refreshNotifications();
    
    // Aqui você pode mostrar uma notificação local ou snackbar
    // Por exemplo, usando um callback para a UI
  }

  /// Manipula quando uma notificação é tocada
  void _handleMessageTapped(RemoteMessage message) {
    // Navegar para a tela apropriada baseado nos dados da notificação
    _navigateBasedOnNotification(message);
    
    // Atualizar lista de notificações
    refreshNotifications();
  }

  /// Navega baseado no tipo de notificação
  void _navigateBasedOnNotification(RemoteMessage message) {
    try {
      final data = message.data;
      final type = data['type'];
      
      switch (type) {
        case 'pedido':
          // Navegar para tela de pedidos
          break;
        case 'promocao':
          // Navegar para produtos em promoção
          break;
        case 'carrinho':
          // Navegar para carrinho
          break;
        default:
          // Navegar para tela de notificações
          break;
      }
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao navegar baseado na notificação', e, stackTrace);
    }
  }

  /// Atualiza a lista de notificações
  Future<void> refreshNotifications() async {
    try {
      final notifications = await _service.getNotificationHistory();
      final unreadCount = await _service.getUnreadNotificationCount();
      
      state = state.copyWith(
        notifications: notifications,
        unreadCount: unreadCount,
      );
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao atualizar notificações', e, stackTrace);
    }
  }

  /// Marca uma notificação como lida
  Future<void> markAsRead(String notificationId) async {
    try {
      await _service.markNotificationAsRead(notificationId);
      await refreshNotifications();
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao marcar notificação como lida', e, stackTrace);
    }
  }

  /// Limpa o histórico de notificações
  Future<void> clearHistory() async {
    try {
      await _service.clearNotificationHistory();
      state = state.copyWith(
        notifications: [],
        unreadCount: 0,
      );
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao limpar histórico', e, stackTrace);
    }
  }

  /// Atualiza configurações de notificação (método legado)
  @Deprecated('Use saveUserSettings instead')
  Future<void> updateSettings(Map<String, Map<String, bool>> settings) async {
    try {
      state = state.copyWith(isLoading: true);
      
      await _service.saveNotificationSettings(settings);
      
      state = state.copyWith(
        settings: settings,
        isLoading: false,
      );
      
      AppLogger.success('Configurações de notificação atualizadas');
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao atualizar configurações', e, stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: 'Erro ao salvar configurações: $e',
      );
    }
  }

  /// Salva configurações do usuário usando o novo sistema
  Future<void> saveUserSettings(String userId, Map<String, dynamic> settingsData) async {
    try {
      state = state.copyWith(isLoading: true);
      
      // Converter Map para NotificationSettings
      final settingsModel = await _service.getNotificationSettings(userId);
      final updatedSettings = settingsModel.copyWith(
        pushEnabled: settingsData['pushEnabled'] ?? settingsModel.pushEnabled,
        emailEnabled: settingsData['emailEnabled'] ?? settingsModel.emailEnabled,
        orderUpdates: settingsData['orderUpdates'] ?? settingsModel.orderUpdates,
        promotions: settingsData['promotions'] ?? settingsModel.promotions,
        systemNotifications: settingsData['systemNotifications'] ?? settingsModel.systemNotifications,
        favoritePromotions: settingsData['favoritePromotions'] ?? settingsModel.favoritePromotions,
        cartReminders: settingsData['cartReminders'] ?? settingsModel.cartReminders,
      );
      
      await _service.saveUserNotificationSettings(userId, updatedSettings);
      
      // Atualizar estado local
      final newSettings = <String, Map<String, bool>>{
        'channels': {
          'push': updatedSettings.pushEnabled,
          'email': updatedSettings.emailEnabled,
        },
        'types': {
          'orderUpdates': updatedSettings.orderUpdates,
          'promotions': updatedSettings.promotions,
          'systemNotifications': updatedSettings.systemNotifications,
          'favoritePromotions': updatedSettings.favoritePromotions,
          'cartReminders': updatedSettings.cartReminders,
        },
      };
      
      state = state.copyWith(
        settings: newSettings,
        isLoading: false,
      );
      
      AppLogger.success('Configurações do usuário salvas com sucesso');
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao salvar configurações do usuário', e, stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: 'Erro ao salvar configurações: $e',
      );
    }
  }

  /// Sincroniza configurações offline com Firestore
  Future<void> syncUserSettings(String userId) async {
    try {
      await _service.syncNotificationSettings(userId);
      // Recarregar configurações após sincronização
      await _loadUserSettings(userId);
      AppLogger.success('Configurações sincronizadas com sucesso');
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao sincronizar configurações', e, stackTrace);
    }
  }

  /// Carrega configurações específicas do usuário
  Future<void> _loadUserSettings(String userId) async {
    try {
      final settingsModel = await _service.getNotificationSettings(userId);
      
      final settings = <String, Map<String, bool>>{
        'channels': {
          'push': settingsModel.pushEnabled,
          'email': settingsModel.emailEnabled,
        },
        'types': {
          'orderUpdates': settingsModel.orderUpdates,
          'promotions': settingsModel.promotions,
          'systemNotifications': settingsModel.systemNotifications,
          'favoritePromotions': settingsModel.favoritePromotions,
          'cartReminders': settingsModel.cartReminders,
        },
      };
      
      state = state.copyWith(settings: settings);
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao carregar configurações do usuário', e, stackTrace);
    }
  }

  /// Atualiza uma configuração específica
  Future<void> updateChannelSetting(String type, String channel, bool enabled) async {
    try {
      final currentSettings = Map<String, Map<String, bool>>.from(state.settings);
      
      if (!currentSettings.containsKey(type)) {
        currentSettings[type] = {};
      }
      
      currentSettings[type]![channel] = enabled;
      
      // Converter para Map e usar o novo método
      final settingsData = {
        'orderUpdates': currentSettings['orderUpdates']?['push'] ?? true,
        'promotions': currentSettings['promotions']?['push'] ?? true,
        'systemNotifications': currentSettings['systemNotifications']?['push'] ?? true,
        'favoritePromotions': currentSettings['favoritePromotions']?['push'] ?? true,
        'cartReminders': currentSettings['cartReminders']?['push'] ?? true,
      };
      
      // Obter userId do provider de autenticação
      final container = ProviderContainer();
      final userState = container.read(userProvider);
      final userId = userState.usuario?.id;
      
      if (userId != null) {
        await saveUserSettings(userId, settingsData);
      } else {
        AppLogger.warning('Usuário não autenticado - não foi possível salvar configurações');
      }
      container.dispose();
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao atualizar configuração do canal', e, stackTrace);
    }
  }

  /// Subscreve a um tópico
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _service.subscribeToTopic(topic);
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao subscrever ao tópico', e, stackTrace);
    }
  }

  /// Remove subscrição de um tópico
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _service.unsubscribeFromTopic(topic);
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao remover subscrição do tópico', e, stackTrace);
    }
  }

  /// Atualiza o token FCM
  Future<void> refreshToken() async {
    try {
      final newToken = await _service.refreshToken();
      state = state.copyWith(fcmToken: newToken);
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao atualizar token FCM', e, stackTrace);
    }
  }

  /// Limpa erros
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Provider para contar notificações não lidas
final unreadNotificationCountProvider = Provider<int>((ref) {
  final notificationState = ref.watch(notificationProvider);
  return notificationState.unreadCount;
});

/// Provider para verificar se há notificações não lidas
final hasUnreadNotificationsProvider = Provider<bool>((ref) {
  final count = ref.watch(unreadNotificationCountProvider);
  return count > 0;
});

/// Provider para as configurações de notificação
final notificationSettingsProvider = Provider<Map<String, Map<String, bool>>>((ref) {
  final notificationState = ref.watch(notificationProvider);
  return notificationState.settings;
});

/// Provider para verificar se as notificações estão inicializadas
final notificationInitializedProvider = Provider<bool>((ref) {
  final notificationState = ref.watch(notificationProvider);
  return notificationState.isInitialized;
});

/// Provider para o token FCM
final fcmTokenProvider = Provider<String?>((ref) {
  final notificationState = ref.watch(notificationProvider);
  return notificationState.fcmToken;
});