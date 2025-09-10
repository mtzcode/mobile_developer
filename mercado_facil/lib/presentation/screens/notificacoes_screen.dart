import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/utils/snackbar_utils.dart';

class NotificacoesScreen extends StatefulWidget {
  const NotificacoesScreen({super.key});

  @override
  State<NotificacoesScreen> createState() => _NotificacoesScreenState();
}

class _NotificacoesScreenState extends State<NotificacoesScreen> {
  // Estado dos switches
  Map<String, Map<String, bool>> notificacoes = {
    'promo': {'email': true, 'whatsapp': false, 'push': true},
    'status': {'email': true, 'whatsapp': false, 'push': true},
    'novidades': {'email': false, 'whatsapp': false, 'push': true},
    'carrinho': {'whatsapp': true, 'push': true},
  };

  Widget _canalSwitchLinha(String canal, bool value, void Function(bool) onChanged) {
    IconData icon;
    String label;
    switch (canal) {
      case 'email':
        icon = Icons.email_outlined;
        label = 'E-mail';
        break;
      case 'whatsapp':
        icon = Icons.chat;
        label = 'WhatsApp';
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
            onChanged: onChanged,
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
        ...canais.map((canal) => _canalSwitchLinha(
          canal,
          notificacoes[tipo]![canal]!,
          (val) => setState(() => notificacoes[tipo]![canal] = val),
        )),
        const SizedBox(height: 8),
        const Divider(height: 1, thickness: 0.5, indent: 20, endIndent: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificações'),
        centerTitle: true,
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          _notificacaoTile(
            titulo: 'Promoções e ofertas',
            descricao: 'Receba novidades e descontos exclusivos.',
            tipo: 'promo',
            canais: ['email', 'whatsapp', 'push'],
          ),
          _notificacaoTile(
            titulo: 'Status de pedidos',
            descricao: 'Acompanhe o andamento dos seus pedidos.',
            tipo: 'status',
            canais: ['email', 'whatsapp', 'push'],
          ),
          _notificacaoTile(
            titulo: 'Novidades do app',
            descricao: 'Fique por dentro das novas funcionalidades.',
            tipo: 'novidades',
            canais: ['email', 'whatsapp', 'push'],
          ),
          _notificacaoTile(
            titulo: 'Lembretes de carrinho',
            descricao: 'Receba lembretes para não esquecer suas compras.',
            tipo: 'carrinho',
            canais: ['whatsapp', 'push'],
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                // Save notification preferences to local storage
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('notification_preferences', jsonEncode(notificacoes));
                
                if (mounted) {
                  if (context.mounted) {
                    showAppSnackBar(
                      context,
                      'Preferências salvas!',
                      icon: Icons.check_circle,
                      backgroundColor: Colors.green.shade600,
                    );
                  }
                }
              },
              child: const Text('Salvar preferências'),
            ),
          ),
        ],
      ),
    );
  }
}