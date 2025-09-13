import 'package:flutter/foundation.dart';

/// Configuração de variáveis de ambiente para o aplicativo
class EnvironmentConfig {
  // Configurações do Firebase
  static const String firebaseProjectId = String.fromEnvironment(
    'FIREBASE_PROJECT_ID',
    defaultValue: 'mercadofacilweb',
  );
  
  static const String firebaseApiKey = String.fromEnvironment(
    'FIREBASE_API_KEY',
    defaultValue: '', // Deve ser definido via --dart-define
  );
  
  static const String firebaseMessagingSenderId = String.fromEnvironment(
    'FIREBASE_MESSAGING_SENDER_ID',
    defaultValue: '10443024714',
  );
  
  static const String firebaseAppId = String.fromEnvironment(
    'FIREBASE_APP_ID',
    defaultValue: '', // Deve ser definido via --dart-define
  );
  
  // Configurações de segurança
  static const String recaptchaSiteKey = String.fromEnvironment(
    'RECAPTCHA_SITE_KEY',
    defaultValue: '', // Deve ser configurado para produção
  );
  
  static const String encryptionKey = String.fromEnvironment(
    'ENCRYPTION_KEY',
    defaultValue: '', // Chave para criptografia local
  );
  
  // Configurações de ambiente
  static const bool isProduction = bool.fromEnvironment(
    'PRODUCTION',
    defaultValue: false,
  );
  
  static const bool enableDebugLogs = bool.fromEnvironment(
    'DEBUG_LOGS',
    defaultValue: kDebugMode,
  );
  
  static const bool enableAnalytics = bool.fromEnvironment(
    'ENABLE_ANALYTICS',
    defaultValue: true,
  );
  
  // URLs da API
  static const String baseApiUrl = String.fromEnvironment(
    'BASE_API_URL',
    defaultValue: 'https://api.mercadofacil.com',
  );
  
  static const String paymentApiUrl = String.fromEnvironment(
    'PAYMENT_API_URL',
    defaultValue: 'https://payment.mercadofacil.com',
  );
  
  // Configurações de cache
  static const int cacheMaxAge = int.fromEnvironment(
    'CACHE_MAX_AGE_HOURS',
    defaultValue: 24,
  );
  
  static const int maxCacheSize = int.fromEnvironment(
    'MAX_CACHE_SIZE_MB',
    defaultValue: 100,
  );

  // Configurações de Email (SendGrid)
  static const String sendGridApiKey = String.fromEnvironment(
    'SENDGRID_API_KEY',
    defaultValue: 'SG.YOUR_SENDGRID_API_KEY', // Deve ser configurado
  );

  static const String sendGridFromEmail = String.fromEnvironment(
    'SENDGRID_FROM_EMAIL',
    defaultValue: 'noreply@mercadofacil.com',
  );

  static const String sendGridFromName = String.fromEnvironment(
    'SENDGRID_FROM_NAME',
    defaultValue: 'Mercado Fácil',
  );

  // Configurações de Notificações
  static const bool notificationsEnabled = bool.fromEnvironment(
    'NOTIFICATIONS_ENABLED',
    defaultValue: true,
  );

  static const bool emailNotificationsEnabled = bool.fromEnvironment(
    'EMAIL_NOTIFICATIONS_ENABLED',
    defaultValue: true,
  );

  static const bool pushNotificationsEnabled = bool.fromEnvironment(
    'PUSH_NOTIFICATIONS_ENABLED',
    defaultValue: true,
  );
  
  // Validações
  static bool get isConfigurationValid {
    if (isProduction) {
      return firebaseApiKey.isNotEmpty &&
             firebaseAppId.isNotEmpty &&
             recaptchaSiteKey.isNotEmpty &&
             encryptionKey.isNotEmpty &&
             sendGridApiKey != 'SG.YOUR_SENDGRID_API_KEY' &&
             sendGridApiKey.isNotEmpty;
    }
    return true; // Em desenvolvimento, permite configuração parcial
  }

  static bool get isEmailConfigurationValid {
    return sendGridApiKey != 'SG.YOUR_SENDGRID_API_KEY' &&
           sendGridApiKey.isNotEmpty &&
           sendGridFromEmail.isNotEmpty;
  }
  
  static String get environmentName {
    if (isProduction) return 'production';
    if (kDebugMode) return 'debug';
    return 'development';
  }
  
  /// Retorna as configurações atuais para debug
  static Map<String, dynamic> getDebugInfo() {
    if (!kDebugMode) return {};
    
    return {
      'environment': environmentName,
      'isProduction': isProduction,
      'enableDebugLogs': enableDebugLogs,
      'enableAnalytics': enableAnalytics,
      'firebaseProjectId': firebaseProjectId,
      'hasApiKey': firebaseApiKey.isNotEmpty,
      'hasAppId': firebaseAppId.isNotEmpty,
      'hasRecaptchaKey': recaptchaSiteKey.isNotEmpty,
      'hasEncryptionKey': encryptionKey.isNotEmpty,
      'isConfigurationValid': isConfigurationValid,
      'cacheMaxAge': cacheMaxAge,
      'maxCacheSize': maxCacheSize,
      // Configurações de Email
      'hasSendGridKey': sendGridApiKey != 'SG.YOUR_SENDGRID_API_KEY' && sendGridApiKey.isNotEmpty,
      'sendGridFromEmail': sendGridFromEmail,
      'sendGridFromName': sendGridFromName,
      'isEmailConfigurationValid': isEmailConfigurationValid,
      'notificationsEnabled': notificationsEnabled,
      'emailNotificationsEnabled': emailNotificationsEnabled,
      'pushNotificationsEnabled': pushNotificationsEnabled,
    };
  }
}