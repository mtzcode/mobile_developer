/// Modelo para representar uma notificação no sistema
class NotificationModel {
  final String id;
  final String title;
  final String body;
  final Map<String, dynamic>? data;
  final DateTime timestamp;
  final bool isRead;
  final String? imageUrl;
  final String? actionUrl;
  final NotificationType type;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    this.data,
    required this.timestamp,
    this.isRead = false,
    this.imageUrl,
    this.actionUrl,
    this.type = NotificationType.general,
  });

  /// Cria uma instância a partir de um Map
  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      data: map['data'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] ?? 0),
      isRead: map['isRead'] ?? false,
      imageUrl: map['imageUrl'],
      actionUrl: map['actionUrl'],
      type: NotificationType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => NotificationType.general,
      ),
    );
  }

  /// Converte para Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'data': data,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'isRead': isRead,
      'imageUrl': imageUrl,
      'actionUrl': actionUrl,
      'type': type.name,
    };
  }

  /// Cria uma cópia com campos modificados
  NotificationModel copyWith({
    String? id,
    String? title,
    String? body,
    Map<String, dynamic>? data,
    DateTime? timestamp,
    bool? isRead,
    String? imageUrl,
    String? actionUrl,
    NotificationType? type,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      data: data ?? this.data,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      imageUrl: imageUrl ?? this.imageUrl,
      actionUrl: actionUrl ?? this.actionUrl,
      type: type ?? this.type,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'NotificationModel(id: $id, title: $title, body: $body, timestamp: $timestamp, isRead: $isRead, type: $type)';
  }
}

/// Tipos de notificação disponíveis
enum NotificationType {
  general('Geral'),
  order('Pedido'),
  promotion('Promoção'),
  system('Sistema'),
  delivery('Entrega'),
  favoritePromotion('Favorito em Oferta'),
  cartReminder('Lembrete de Carrinho'),
  newProduct('Novo Produto'),
  priceAlert('Alerta de Preço');

  const NotificationType(this.displayName);
  final String displayName;
}

/// Configurações de notificação do usuário
class NotificationSettings {
  final bool pushEnabled;
  final bool emailEnabled;
  final bool orderUpdates;
  final bool promotions;
  final bool systemNotifications;
  final bool deliveryUpdates;
  final bool favoritePromotions;
  final bool cartReminders;
  final bool newProducts;
  final bool priceAlerts;
  final String? soundType;
  final bool vibrationEnabled;

  const NotificationSettings({
    this.pushEnabled = true,
    this.emailEnabled = true,
    this.orderUpdates = true,
    this.promotions = true,
    this.systemNotifications = true,
    this.deliveryUpdates = true,
    this.favoritePromotions = true,
    this.cartReminders = true,
    this.newProducts = false,
    this.priceAlerts = false,
    this.soundType,
    this.vibrationEnabled = true,
  });

  /// Cria uma instância a partir de um Map
  factory NotificationSettings.fromMap(Map<String, dynamic> map) {
    return NotificationSettings(
      pushEnabled: map['pushEnabled'] ?? true,
      emailEnabled: map['emailEnabled'] ?? true,
      orderUpdates: map['orderUpdates'] ?? true,
      promotions: map['promotions'] ?? true,
      systemNotifications: map['systemNotifications'] ?? true,
      deliveryUpdates: map['deliveryUpdates'] ?? true,
      favoritePromotions: map['favoritePromotions'] ?? true,
      cartReminders: map['cartReminders'] ?? true,
      newProducts: map['newProducts'] ?? false,
      priceAlerts: map['priceAlerts'] ?? false,
      soundType: map['soundType'],
      vibrationEnabled: map['vibrationEnabled'] ?? true,
    );
  }

  /// Converte para Map
  Map<String, dynamic> toMap() {
    return {
      'pushEnabled': pushEnabled,
      'emailEnabled': emailEnabled,
      'orderUpdates': orderUpdates,
      'promotions': promotions,
      'systemNotifications': systemNotifications,
      'deliveryUpdates': deliveryUpdates,
      'favoritePromotions': favoritePromotions,
      'cartReminders': cartReminders,
      'newProducts': newProducts,
      'priceAlerts': priceAlerts,
      'soundType': soundType,
      'vibrationEnabled': vibrationEnabled,
    };
  }

  /// Cria uma cópia com campos modificados
  NotificationSettings copyWith({
    bool? pushEnabled,
    bool? emailEnabled,
    bool? orderUpdates,
    bool? promotions,
    bool? systemNotifications,
    bool? deliveryUpdates,
    bool? favoritePromotions,
    bool? cartReminders,
    bool? newProducts,
    bool? priceAlerts,
    String? soundType,
    bool? vibrationEnabled,
  }) {
    return NotificationSettings(
      pushEnabled: pushEnabled ?? this.pushEnabled,
      emailEnabled: emailEnabled ?? this.emailEnabled,
      orderUpdates: orderUpdates ?? this.orderUpdates,
      promotions: promotions ?? this.promotions,
      systemNotifications: systemNotifications ?? this.systemNotifications,
      deliveryUpdates: deliveryUpdates ?? this.deliveryUpdates,
      favoritePromotions: favoritePromotions ?? this.favoritePromotions,
      cartReminders: cartReminders ?? this.cartReminders,
      newProducts: newProducts ?? this.newProducts,
      priceAlerts: priceAlerts ?? this.priceAlerts,
      soundType: soundType ?? this.soundType,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
    );
  }

  @override
  String toString() {
    return 'NotificationSettings(pushEnabled: $pushEnabled, emailEnabled: $emailEnabled)';
  }
}