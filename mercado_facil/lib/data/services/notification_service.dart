import 'dart:convert';
import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/utils/logger.dart';
import '../models/notification_model.dart' as models;
import 'user_notification_settings_service.dart';

/// Serviço responsável por gerenciar notificações push via Firebase Cloud Messaging
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final UserNotificationSettingsService _userSettingsService = 
      UserNotificationSettingsService();
  String? _fcmToken;
  
  /// Callback para quando uma notificação é recebida em foreground
  Function(RemoteMessage)? onMessageReceived;
  
  /// Callback para quando uma notificação é tocada
  Function(RemoteMessage)? onMessageTapped;

  /// Inicializa o serviço de notificações
  Future<void> initialize() async {
    try {
      AppLogger.info('Inicializando NotificationService');
      
      // Solicitar permissões
      await _requestPermissions();
      
      // Obter token FCM
      await _getFCMToken();
      
      // Configurar handlers
      _setupMessageHandlers();
      
      AppLogger.success('NotificationService inicializado com sucesso');
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao inicializar NotificationService', e, stackTrace);
      rethrow;
    }
  }

  /// Solicita permissões para notificações
  Future<bool> _requestPermissions() async {
    try {
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      final isAuthorized = settings.authorizationStatus == AuthorizationStatus.authorized ||
                          settings.authorizationStatus == AuthorizationStatus.provisional;
      
      AppLogger.info('Permissões de notificação: ${settings.authorizationStatus}');
      return isAuthorized;
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao solicitar permissões', e, stackTrace);
      return false;
    }
  }

  /// Obtém o token FCM do dispositivo
  Future<String?> _getFCMToken() async {
    try {
      _fcmToken = await _firebaseMessaging.getToken();
      AppLogger.info('FCM Token obtido: ${_fcmToken?.substring(0, 20)}...');
      
      // Salvar token localmente
      if (_fcmToken != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('fcm_token', _fcmToken!);
      }
      
      return _fcmToken;
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao obter FCM token', e, stackTrace);
      return null;
    }
  }

  /// Configura os handlers de mensagens
  void _setupMessageHandlers() {
    // Mensagens em foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      AppLogger.info('Notificação recebida em foreground: ${message.notification?.title}');
      _handleForegroundMessage(message);
    });

    // Mensagens quando o app é aberto via notificação
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      AppLogger.info('App aberto via notificação: ${message.notification?.title}');
      _handleMessageTapped(message);
    });

    // Verificar se o app foi aberto via notificação (cold start)
    _checkInitialMessage();
  }

  /// Verifica se o app foi aberto via notificação (cold start)
  Future<void> _checkInitialMessage() async {
    try {
      final initialMessage = await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        AppLogger.info('App iniciado via notificação: ${initialMessage.notification?.title}');
        _handleMessageTapped(initialMessage);
      }
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao verificar mensagem inicial', e, stackTrace);
    }
  }

  /// Manipula mensagens recebidas em foreground
  void _handleForegroundMessage(RemoteMessage message) {
    // Salvar notificação no histórico
    _saveNotificationToHistory(message);
    
    // Chamar callback se definido
    onMessageReceived?.call(message);
  }

  /// Manipula quando uma notificação é tocada
  void _handleMessageTapped(RemoteMessage message) {
    // Salvar notificação no histórico
    _saveNotificationToHistory(message);
    
    // Chamar callback se definido
    onMessageTapped?.call(message);
  }

  /// Salva notificação no histórico local
  Future<void> _saveNotificationToHistory(RemoteMessage message) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notifications = prefs.getStringList('notification_history') ?? [];
      
      final notificationData = {
        'id': message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
        'title': message.notification?.title ?? '',
        'body': message.notification?.body ?? '',
        'data': message.data,
        'timestamp': DateTime.now().toIso8601String(),
        'read': false,
      };
      
      notifications.insert(0, jsonEncode(notificationData));
      
      // Manter apenas as últimas 50 notificações
      if (notifications.length > 50) {
        notifications.removeRange(50, notifications.length);
      }
      
      await prefs.setStringList('notification_history', notifications);
      AppLogger.info('Notificação salva no histórico');
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao salvar notificação no histórico', e, stackTrace);
    }
  }

  /// Obtém o histórico de notificações
  Future<List<Map<String, dynamic>>> getNotificationHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notifications = prefs.getStringList('notification_history') ?? [];
      
      return notifications.map((notification) {
        return Map<String, dynamic>.from(jsonDecode(notification));
      }).toList();
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao obter histórico de notificações', e, stackTrace);
      return [];
    }
  }

  /// Marca uma notificação como lida
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notifications = prefs.getStringList('notification_history') ?? [];
      
      final updatedNotifications = notifications.map((notification) {
        final data = Map<String, dynamic>.from(jsonDecode(notification));
        if (data['id'] == notificationId) {
          data['read'] = true;
        }
        return jsonEncode(data);
      }).toList();
      
      await prefs.setStringList('notification_history', updatedNotifications);
      AppLogger.info('Notificação marcada como lida: $notificationId');
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao marcar notificação como lida', e, stackTrace);
    }
  }

  /// Limpa o histórico de notificações
  Future<void> clearNotificationHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('notification_history');
      AppLogger.info('Histórico de notificações limpo');
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao limpar histórico de notificações', e, stackTrace);
    }
  }

  /// Envia notificação para um usuário específico
  /// 
  /// [userId] - ID do usuário que receberá a notificação
  /// [title] - Título da notificação
  /// [body] - Corpo da notificação
  /// [data] - Dados adicionais da notificação
  Future<bool> sendNotificationToUser({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      AppLogger.info('Enviando notificação push para usuário $userId: $title');
      
      // Por enquanto, apenas simula o envio
      // Em uma implementação real, você usaria o Firebase Admin SDK
      // ou uma API backend para enviar a notificação
      
      // Simular delay de rede
      await Future.delayed(const Duration(milliseconds: 500));
      
      AppLogger.success('Notificação push enviada com sucesso para $userId');
      return true;
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao enviar notificação push para $userId', e, stackTrace);
      return false;
    }
  }

  /// Obtém o token FCM atual
  String? get fcmToken => _fcmToken;

  /// Atualiza o token FCM
  Future<String?> refreshToken() async {
    try {
      await _firebaseMessaging.deleteToken();
      return await _getFCMToken();
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao atualizar token FCM', e, stackTrace);
      return null;
    }
  }

  /// Subscreve a um tópico
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      AppLogger.info('Subscrito ao tópico: $topic');
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao subscrever ao tópico $topic', e, stackTrace);
    }
  }

  /// Remove subscrição de um tópico
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      AppLogger.info('Removida subscrição do tópico: $topic');
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao remover subscrição do tópico $topic', e, stackTrace);
    }
  }



  /// Obtém configurações de notificação para um usuário específico
  /// Carrega do Firestore/cache local ou retorna configurações padrão
  Future<models.NotificationSettings> getNotificationSettings(String userId) async {
    try {
      return await _userSettingsService.getUserNotificationSettings(userId);
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao obter configurações de notificação para usuário $userId', e, stackTrace);
      return const models.NotificationSettings();
    }
  }

  /// Salva configurações de notificação para um usuário específico
  Future<void> saveUserNotificationSettings(
    String userId, 
    models.NotificationSettings settings
  ) async {
    try {
      await _userSettingsService.saveUserNotificationSettings(userId, settings);
      
      // Gerenciar subscrições de tópicos baseado nas configurações
      await _manageTopicSubscriptionsFromSettings(settings);
      
      AppLogger.info('Configurações de notificação salvas para usuário $userId');
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao salvar configurações de notificação', e, stackTrace);
    }
  }

  /// Salva configurações de notificação (método legado)
  @Deprecated('Use saveUserNotificationSettings instead')
  Future<void> saveNotificationSettings(Map<String, Map<String, bool>> settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('notification_settings', jsonEncode(settings));
      
      // Gerenciar subscrições de tópicos baseado nas configurações
      await _manageTopicSubscriptions(settings);
      
      AppLogger.info('Configurações de notificação salvas (método legado)');
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao salvar configurações de notificação', e, stackTrace);
    }
  }

  /// Gerencia subscrições de tópicos baseado no modelo NotificationSettings
  Future<void> _manageTopicSubscriptionsFromSettings(models.NotificationSettings settings) async {
    try {
      // Subscrever/desinscrever de tópicos baseado nas configurações
      if (settings.promotions) {
        await subscribeToTopic('promotions');
      } else {
        await unsubscribeFromTopic('promotions');
      }
      
      if (settings.favoritePromotions) {
        await subscribeToTopic('favorite_promotions');
      } else {
        await unsubscribeFromTopic('favorite_promotions');
      }
      
      if (settings.newProducts) {
        await subscribeToTopic('new_products');
      } else {
        await unsubscribeFromTopic('new_products');
      }
      
      if (settings.systemNotifications) {
        await subscribeToTopic('system_notifications');
      } else {
        await unsubscribeFromTopic('system_notifications');
      }
      
      AppLogger.info('Subscrições de tópicos atualizadas baseado nas configurações');
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao gerenciar subscrições de tópicos', e, stackTrace);
    }
  }

  /// Gerencia subscrições de tópicos baseado nas configurações (método legado)
  @Deprecated('Use _manageTopicSubscriptionsFromSettings instead')
  Future<void> _manageTopicSubscriptions(Map<String, Map<String, bool>> settings) async {
    try {
      for (final entry in settings.entries) {
        final tipo = entry.key;
        final canais = entry.value;
        
        if (canais['push'] == true) {
          await subscribeToTopic(tipo);
        } else {
          await unsubscribeFromTopic(tipo);
        }
      }
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao gerenciar subscrições de tópicos (método legado)', e, stackTrace);
    }
  }

  /// Sincroniza configurações de notificação com o Firestore
  Future<void> syncNotificationSettings(String userId) async {
    try {
      await _userSettingsService.syncWithFirestore(userId);
      AppLogger.info('Configurações de notificação sincronizadas para usuário $userId');
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao sincronizar configurações de notificação', e, stackTrace);
    }
  }

  /// Remove configurações de notificação de um usuário
  Future<void> clearUserNotificationSettings(String userId) async {
    try {
      await _userSettingsService.clearUserSettings(userId);
      AppLogger.info('Configurações de notificação removidas para usuário $userId');
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao remover configurações de notificação', e, stackTrace);
    }
  }

  /// Verifica se há configurações pendentes de sincronização
  Future<bool> hasPendingSync(String userId) async {
    try {
      return await _userSettingsService.hasPendingSync(userId);
    } catch (e) {
      return false;
    }
  }

  /// Obtém estatísticas de configurações para debug
  Future<Map<String, dynamic>> getSettingsStats(String userId) async {
    try {
      return await _userSettingsService.getSettingsStats(userId);
    } catch (e) {
      return {'error': true};
    }
  }

  /// Conta notificações não lidas
  Future<int> getUnreadNotificationCount() async {
    try {
      final notifications = await getNotificationHistory();
      return notifications.where((notification) => notification['read'] == false).length;
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao contar notificações não lidas', e, stackTrace);
      return 0;
    }
  }
}

/// Handler para notificações em background (deve ser uma função top-level)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  AppLogger.info('Notificação recebida em background: ${message.notification?.title}');
  
  // Aqui você pode processar a notificação em background
  // Por exemplo, salvar no banco de dados local, etc.
}