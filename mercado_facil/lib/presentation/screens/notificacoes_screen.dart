import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/snackbar_utils.dart';
import '../../data/providers/notification_provider.dart';

class NotificacoesScreen extends ConsumerStatefulWidget {
  const NotificacoesScreen({super.key});

  @override
  ConsumerState<NotificacoesScreen> createState() => _NotificacoesScreenState();
}

class _NotificacoesScreenState extends ConsumerState<NotificacoesScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _canalSwitchLinha(String canal, bool value, void Function(bool) onChanged, {bool enabled = true}) {
    IconData icon;
    String label;
    switch (canal) {
      case 'email':
        icon = Icons.email_outlined;
        label = 'E-mail';
        break;

      case 'push':
      default:
        icon = Icons.notifications_active_outlined;
        label = 'No aparelho';
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 24.0),
      child: Row(
        children: [
          const SizedBox(width: 8),
          Icon(icon, color: Colors.grey[600], size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 15))),
          Switch(
            value: value,
            onChanged: enabled ? onChanged : null,
            activeThumbColor: Theme.of(context).colorScheme.primary,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }

  Widget _notificacaoTile({
    required String titulo,
    required String descricao,
    required String tipo,
    required List<String> canais,
  }) {
    Color accentColor;
    IconData iconData;
    switch (tipo) {
      case 'promo':
        accentColor = Colors.orange;
        iconData = Icons.local_offer;
        break;
      case 'status':
        accentColor = Colors.blue;
        iconData = Icons.shopping_bag;
        break;
      case 'novidades':
        accentColor = Colors.purple;
        iconData = Icons.new_releases;
        break;
      case 'carrinho':
      default:
        accentColor = Colors.green;
        iconData = Icons.shopping_cart;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(iconData, color: accentColor, size: 28),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(titulo, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    if (descricao.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2.0, bottom: 8.0),
                        child: Text(descricao, style: const TextStyle(fontSize: 13, color: Colors.black54)),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        ...canais.map((canal) {
          final notificationState = ref.watch(notificationProvider);
          final settings = notificationState.settings;
          final isEnabled = notificationState.isInitialized && !notificationState.isLoading;
          
          return _canalSwitchLinha(
            canal,
            settings[tipo]?[canal] ?? false,
            (val) => ref.read(notificationProvider.notifier).updateChannelSetting(tipo, canal, val),
            enabled: isEnabled,
          );
        }),
        const SizedBox(height: 8),
        const Divider(height: 1, thickness: 0.5, indent: 20, endIndent: 20),
      ],
    );
  }

  Widget _buildConfigTab() {
    final notificationState = ref.watch(notificationProvider);
    
    if (!notificationState.isInitialized) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Inicializando notificações...'),
          ],
        ),
      );
    }
    
    if (notificationState.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Erro ao carregar notificações',
              style: TextStyle(fontSize: 18, color: Colors.red[700]),
            ),
            const SizedBox(height: 8),
            Text(
              notificationState.error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(notificationProvider.notifier).clearError(),
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }
    
    return ListView(
        children: [
          _notificacaoTile(
            titulo: 'Promoções e ofertas',
            descricao: 'Receba novidades e descontos exclusivos.',
            tipo: 'promo',
            canais: ['email', 'push'],
          ),
          _notificacaoTile(
            titulo: 'Status de pedidos',
            descricao: 'Acompanhe o andamento dos seus pedidos.',
            tipo: 'status',
            canais: ['email', 'push'],
          ),
          _notificacaoTile(
            titulo: 'Novidades do app',
            descricao: 'Fique por dentro das novas funcionalidades.',
            tipo: 'novidades',
            canais: ['email', 'push'],
          ),
          _notificacaoTile(
            titulo: 'Lembretes de carrinho',
            descricao: 'Receba lembretes para não esquecer suas compras.',
            tipo: 'carrinho',
            canais: ['push'],
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              children: [
                if (notificationState.fcmToken != null) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info_outline, size: 16, color: Colors.blue[600]),
                              const SizedBox(width: 8),
                              Text(
                                'Status das notificações',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue[600],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Dispositivo conectado e pronto para receber notificações push.',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: notificationState.isLoading ? null : () async {
                    if (context.mounted) {
                      showAppSnackBar(
                        context,
                        'Preferências salvas!',
                        icon: Icons.check_circle,
                        backgroundColor: Colors.green.shade600,
                      );
                    }
                  },
                  child: notificationState.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Salvar preferências'),
                ),
              ],
            ),
          ),
        ],
      );
  }
  
  Widget _buildHistoryTab() {
    final notificationState = ref.watch(notificationProvider);
    final notifications = notificationState.notifications;
    
    if (notifications.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Nenhuma notificação ainda',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Suas notificações aparecerão aqui',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        final isRead = notification['read'] ?? false;
        final timestamp = DateTime.tryParse(notification['timestamp'] ?? '') ?? DateTime.now();
        
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isRead ? Colors.grey[300] : Theme.of(context).colorScheme.primary,
              child: Icon(
                Icons.notifications,
                color: isRead ? Colors.grey[600] : Colors.white,
                size: 20,
              ),
            ),
            title: Text(
              notification['title'] ?? 'Notificação',
              style: TextStyle(
                fontWeight: isRead ? FontWeight.normal : FontWeight.w600,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (notification['body'] != null && notification['body'].isNotEmpty)
                  Text(
                    notification['body'],
                    style: TextStyle(
                      color: isRead ? Colors.grey[600] : Colors.black87,
                    ),
                  ),
                const SizedBox(height: 4),
                Text(
                  _formatTimestamp(timestamp),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
            trailing: !isRead
                ? Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  )
                : null,
            onTap: () {
              if (!isRead) {
                ref.read(notificationProvider.notifier).markAsRead(notification['id']);
              }
            },
          ),
        );
      },
    );
  }
  
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d atrás';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h atrás';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}min atrás';
    } else {
      return 'Agora';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final unreadCount = ref.watch(unreadNotificationCountProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificações'),
        centerTitle: true,
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            const Tab(
              icon: Icon(Icons.settings),
              text: 'Configurações',
            ),
            Tab(
              icon: Stack(
                children: [
                  const Icon(Icons.history),
                  if (unreadCount > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          unreadCount > 99 ? '99+' : unreadCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              text: 'Histórico',
            ),
          ],
        ),
        actions: [
          if (_tabController.index == 1)
            IconButton(
              icon: const Icon(Icons.clear_all),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Limpar histórico'),
                    content: const Text('Tem certeza que deseja limpar todo o histórico de notificações?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () {
                          ref.read(notificationProvider.notifier).clearHistory();
                          Navigator.pop(context);
                        },
                        child: const Text('Limpar'),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildConfigTab(),
          _buildHistoryTab(),
        ],
      ),
    );
  }
}