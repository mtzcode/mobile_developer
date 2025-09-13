import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/notification_model.dart';
import '../../core/utils/logger.dart';

/// Serviço responsável por gerenciar configurações de notificação do usuário
/// 
/// Este serviço implementa uma estratégia híbrida de armazenamento:
/// 1. Firestore - para persistência permanente vinculada ao usuário
/// 2. SharedPreferences - para cache local e acesso offline
/// 
/// Isso garante que as configurações sejam mantidas mesmo após reinstalação
/// do app e também funcionem offline.
class UserNotificationSettingsService {
  static const String _localStorageKey = 'user_notification_settings';
  static const String _firestoreCollection = 'user_settings';
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  /// Salva configurações de notificação para um usuário específico
  /// 
  /// [userId] - ID do usuário
  /// [settings] - Configurações de notificação
  Future<void> saveUserNotificationSettings(
    String userId, 
    NotificationSettings settings
  ) async {
    try {
      AppLogger.info('Salvando configurações de notificação para usuário $userId');
      
      final settingsMap = settings.toMap();
      
      // 1. Salvar no Firestore (persistência permanente)
      await _firestore
          .collection(_firestoreCollection)
          .doc(userId)
          .set({
        'notificationSettings': settingsMap,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
      // 2. Salvar no cache local (acesso rápido)
      await _saveToLocalCache(userId, settingsMap);
      
      AppLogger.info('Configurações de notificação salvas com sucesso');
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao salvar configurações de notificação', e, stackTrace);
      
      // Fallback: salvar apenas localmente se Firestore falhar
      try {
        await _saveToLocalCache(userId, settings.toMap());
        AppLogger.warning('Configurações salvas apenas localmente devido a erro no Firestore');
      } catch (localError) {
        AppLogger.error('Erro crítico: falha ao salvar configurações', localError);
        rethrow;
      }
    }
  }
  
  /// Carrega configurações de notificação para um usuário específico
  /// 
  /// [userId] - ID do usuário
  /// Retorna configurações do Firestore, cache local ou padrão (nesta ordem)
  Future<NotificationSettings> getUserNotificationSettings(String userId) async {
    try {
      AppLogger.info('Carregando configurações de notificação para usuário $userId');
      
      // 1. Tentar carregar do Firestore primeiro
      try {
        final doc = await _firestore
            .collection(_firestoreCollection)
            .doc(userId)
            .get();
            
        if (doc.exists && doc.data()?['notificationSettings'] != null) {
          final settingsMap = Map<String, dynamic>.from(
            doc.data()!['notificationSettings']
          );
          
          // Atualizar cache local com dados do Firestore
          await _saveToLocalCache(userId, settingsMap);
          
          AppLogger.info('Configurações carregadas do Firestore');
          return NotificationSettings.fromMap(settingsMap);
        }
      } catch (firestoreError) {
        AppLogger.warning('Erro ao carregar do Firestore, tentando cache local', firestoreError);
      }
      
      // 2. Fallback para cache local
      final localSettings = await _loadFromLocalCache(userId);
      if (localSettings != null) {
        AppLogger.info('Configurações carregadas do cache local');
        return NotificationSettings.fromMap(localSettings);
      }
      
      // 3. Retornar configurações padrão
      AppLogger.info('Usando configurações padrão para usuário $userId');
      const defaultSettings = NotificationSettings();
      
      // Salvar configurações padrão para uso futuro
      await saveUserNotificationSettings(userId, defaultSettings);
      
      return defaultSettings;
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao carregar configurações de notificação', e, stackTrace);
      return const NotificationSettings(); // Configurações padrão em caso de erro
    }
  }
  
  /// Sincroniza configurações locais com o Firestore
  /// 
  /// Útil para garantir que mudanças offline sejam enviadas quando
  /// a conectividade for restaurada
  Future<void> syncWithFirestore(String userId) async {
    try {
      AppLogger.info('Sincronizando configurações com Firestore para usuário $userId');
      
      final localSettings = await _loadFromLocalCache(userId);
      if (localSettings != null) {
        await _firestore
            .collection(_firestoreCollection)
            .doc(userId)
            .set({
          'notificationSettings': localSettings,
          'lastUpdated': FieldValue.serverTimestamp(),
          'syncedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        
        AppLogger.info('Sincronização concluída com sucesso');
      }
    } catch (e, stackTrace) {
      AppLogger.error('Erro na sincronização com Firestore', e, stackTrace);
    }
  }
  
  /// Remove configurações de um usuário (útil para logout/exclusão de conta)
  Future<void> clearUserSettings(String userId) async {
    try {
      AppLogger.info('Removendo configurações do usuário $userId');
      
      // Remover do Firestore
      await _firestore
          .collection(_firestoreCollection)
          .doc(userId)
          .delete();
      
      // Remover do cache local
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('${_localStorageKey}_$userId');
      
      AppLogger.info('Configurações removidas com sucesso');
    } catch (e, stackTrace) {
      AppLogger.error('Erro ao remover configurações do usuário', e, stackTrace);
    }
  }
  
  /// Salva configurações no cache local
  Future<void> _saveToLocalCache(String userId, Map<String, dynamic> settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '${_localStorageKey}_$userId',
      jsonEncode(settings),
    );
  }
  
  /// Carrega configurações do cache local
  Future<Map<String, dynamic>?> _loadFromLocalCache(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString('${_localStorageKey}_$userId');
      
      if (settingsJson != null) {
        return Map<String, dynamic>.from(jsonDecode(settingsJson));
      }
    } catch (e) {
      AppLogger.warning('Erro ao carregar configurações do cache local', e);
    }
    return null;
  }
  
  /// Verifica se há configurações pendentes de sincronização
  Future<bool> hasPendingSync(String userId) async {
    try {
      final localSettings = await _loadFromLocalCache(userId);
      if (localSettings == null) return false;
      
      final doc = await _firestore
          .collection(_firestoreCollection)
          .doc(userId)
          .get();
          
      if (!doc.exists) return true;
      
      final firestoreSettings = doc.data()?['notificationSettings'];
      return !_mapsAreEqual(localSettings, firestoreSettings);
    } catch (e) {
      return false;
    }
  }
  
  /// Compara dois mapas para verificar igualdade
  bool _mapsAreEqual(Map<String, dynamic> map1, Map<String, dynamic>? map2) {
    if (map2 == null) return false;
    if (map1.length != map2.length) return false;
    
    for (final key in map1.keys) {
      if (map1[key] != map2[key]) return false;
    }
    
    return true;
  }
  
  /// Obtém estatísticas de uso das configurações (para debug)
  Future<Map<String, dynamic>> getSettingsStats(String userId) async {
    try {
      final doc = await _firestore
          .collection(_firestoreCollection)
          .doc(userId)
          .get();
          
      if (doc.exists) {
        final data = doc.data()!;
        return {
          'hasFirestoreSettings': data['notificationSettings'] != null,
          'lastUpdated': data['lastUpdated']?.toDate()?.toIso8601String(),
          'syncedAt': data['syncedAt']?.toDate()?.toIso8601String(),
          'hasLocalCache': await _loadFromLocalCache(userId) != null,
          'pendingSync': await hasPendingSync(userId),
        };
      }
    } catch (e) {
      AppLogger.error('Erro ao obter estatísticas de configurações', e);
    }
    
    return {
      'hasFirestoreSettings': false,
      'hasLocalCache': await _loadFromLocalCache(userId) != null,
      'error': true,
    };
  }
}