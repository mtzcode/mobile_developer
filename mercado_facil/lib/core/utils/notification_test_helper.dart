import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'logger.dart';

/// Helper para testes de notificação FCM
class NotificationTestHelper {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// Obtém o token FCM atual e copia para o clipboard
  static Future<String?> getAndCopyToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        await Clipboard.setData(ClipboardData(text: token));
        AppLogger.info('Token FCM copiado para clipboard: ${token.substring(0, 20)}...');
        return token;
      }
    } catch (e) {
      AppLogger.error('Erro ao obter token FCM', e);
    }
    return null;
  }

  /// Inscreve em um tópico de teste
  static Future<void> subscribeToTestTopic(String topic) async {
    if (kIsWeb) {
      AppLogger.info('⚠️ Inscrição em tópicos não suportada no web. Tópico: $topic');
      return;
    }
    
    try {
      await _messaging.subscribeToTopic(topic);
      AppLogger.info('Inscrito no tópico: $topic');
    } catch (e) {
      AppLogger.error('Erro ao se inscrever no tópico $topic', e);
    }
  }

  /// Desinscreve de um tópico
  static Future<void> unsubscribeFromTopic(String topic) async {
    if (kIsWeb) {
      AppLogger.info('⚠️ Desinscrição de tópicos não suportada no web. Tópico: $topic');
      return;
    }
    
    try {
      await _messaging.unsubscribeFromTopic(topic);
      AppLogger.info('Desinscrito do tópico: $topic');
    } catch (e) {
      AppLogger.error('Erro ao se desinscrever do tópico $topic', e);
    }
  }

  /// Lista de tópicos de teste disponíveis
  static const List<String> testTopics = [
    'promocoes',
    'pedidos',
    'ofertas',
    'novidades',
    'teste'
  ];

  /// Inscreve em todos os tópicos de teste
  static Future<void> subscribeToAllTestTopics() async {
    for (final topic in testTopics) {
      await subscribeToTestTopic(topic);
    }
  }

  /// Desinscreve de todos os tópicos de teste
  static Future<void> unsubscribeFromAllTestTopics() async {
    for (final topic in testTopics) {
      await unsubscribeFromTopic(topic);
    }
  }

  /// Simula uma notificação local para teste
  static void simulateLocalNotification() {
    if (kDebugMode) {
      AppLogger.info('🔔 Simulando notificação local...');
      // Aqui você pode adicionar lógica para mostrar uma notificação simulada
    }
  }

  /// Obtém informações de debug sobre FCM
  static Future<Map<String, dynamic>> getDebugInfo() async {
    final token = await _messaging.getToken();
    final settings = await _messaging.getNotificationSettings();
    
    return {
      'token': token,
      'tokenPreview': token?.substring(0, 20) ?? 'null',
      'authorizationStatus': settings.authorizationStatus.toString(),
      'alert': settings.alert.toString(),
      'badge': settings.badge.toString(),
      'sound': settings.sound.toString(),
      'isSupported': await _messaging.isSupported(),
      'platform': defaultTargetPlatform.toString(),
      'isWeb': kIsWeb,
    };
  }

  /// Força a atualização do token FCM
  static Future<String?> refreshToken() async {
    try {
      await _messaging.deleteToken();
      final newToken = await _messaging.getToken();
      AppLogger.info('Token FCM atualizado: ${newToken?.substring(0, 20)}...');
      return newToken;
    } catch (e) {
      AppLogger.error('Erro ao atualizar token FCM', e);
      return null;
    }
  }

  /// Testa as permissões de notificação
  static Future<bool> testPermissions() async {
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      final isAuthorized = settings.authorizationStatus == AuthorizationStatus.authorized;
      
      AppLogger.info('Permissões FCM: ${settings.authorizationStatus}');
      AppLogger.info('Alert: ${settings.alert}');
      AppLogger.info('Badge: ${settings.badge}');
      AppLogger.info('Sound: ${settings.sound}');
      
      return isAuthorized;
    } catch (e) {
      AppLogger.error('Erro ao testar permissões FCM', e);
      return false;
    }
  }

  /// Gera um relatório completo de teste
  static Future<String> generateTestReport() async {
    final debugInfo = await getDebugInfo();
    final hasPermissions = await testPermissions();
    
    final report = StringBuffer();
    report.writeln('🔥 RELATÓRIO DE TESTE FCM - MERCADO FÁCIL');
    report.writeln('=' * 50);
    report.writeln('📱 Plataforma: ${debugInfo['platform']}');
    report.writeln('🌐 Web: ${debugInfo['isWeb']}');
    report.writeln('✅ Suportado: ${debugInfo['isSupported']}');
    report.writeln('🔑 Token: ${debugInfo['tokenPreview']}...');
    report.writeln('🔐 Autorização: ${debugInfo['authorizationStatus']}');
    report.writeln('🔔 Alert: ${debugInfo['alert']}');
    report.writeln('🏷️ Badge: ${debugInfo['badge']}');
    report.writeln('🔊 Sound: ${debugInfo['sound']}');
    report.writeln('✅ Permissões OK: $hasPermissions');
    report.writeln('=' * 50);
    report.writeln('📋 Tópicos disponíveis:');
    for (final topic in testTopics) {
      report.writeln('  - $topic');
    }
    report.writeln('=' * 50);
    report.writeln('🕒 Gerado em: ${DateTime.now()}');
    
    final reportText = report.toString();
    AppLogger.info(reportText);
    
    return reportText;
  }
}