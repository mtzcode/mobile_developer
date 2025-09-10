import 'package:flutter/material.dart';
import '../../data/models/pedido.dart';

class PedidoStatusWidget extends StatelessWidget {
  final Pedido pedido;
  final bool showTimeline;

  const PedidoStatusWidget({
    super.key,
    required this.pedido,
    this.showTimeline = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Status atual
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: pedido.statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: pedido.statusColor),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                pedido.statusIcon,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(width: 8),
              Text(
                pedido.statusText,
                style: TextStyle(
                  color: pedido.statusColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        
        if (showTimeline) ...[
          const SizedBox(height: 16),
          _buildTimeline(),
        ],
      ],
    );
  }

  Widget _buildTimeline() {
    final steps = [
      _TimelineStep(
        title: 'Pedido Realizado',
        description: 'Pedido criado com sucesso',
        isCompleted: true,
        date: pedido.dataCriacao,
        icon: Icons.shopping_cart,
        color: Colors.green,
      ),
      _TimelineStep(
        title: 'Pedido Confirmado',
        description: 'Pedido confirmado pelo estabelecimento',
        isCompleted: pedido.status != StatusPedido.pendente,
        date: pedido.dataConfirmacao,
        icon: Icons.check_circle,
        color: Colors.blue,
      ),
      _TimelineStep(
        title: 'Em Preparação',
        description: 'Pedido está sendo preparado',
        isCompleted: pedido.status == StatusPedido.emPreparacao || 
                    pedido.status == StatusPedido.emEntrega || 
                    pedido.status == StatusPedido.entregue,
        date: null, // Não temos data específica para este status
        icon: Icons.restaurant,
        color: Colors.orange,
      ),
      _TimelineStep(
        title: 'Em Entrega',
        description: 'Pedido está a caminho',
        isCompleted: pedido.status == StatusPedido.emEntrega || 
                    pedido.status == StatusPedido.entregue,
        date: null, // Não temos data específica para este status
        icon: Icons.local_shipping,
        color: Colors.purple,
      ),
      _TimelineStep(
        title: 'Entregue',
        description: 'Pedido entregue com sucesso',
        isCompleted: pedido.status == StatusPedido.entregue,
        date: pedido.dataEntrega,
        icon: Icons.home,
        color: Colors.green,
      ),
    ];

    return Column(
      children: steps.asMap().entries.map((entry) {
        final index = entry.key;
        final step = entry.value;
        final isLast = index == steps.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Linha vertical
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: step.isCompleted ? step.color : Colors.grey[300],
                margin: const EdgeInsets.only(left: 15),
              ),
            
            // Ícone do passo
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: step.isCompleted ? step.color : Colors.grey[300],
                shape: BoxShape.circle,
              ),
              child: Icon(
                step.icon,
                color: Colors.white,
                size: 16,
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Informações do passo
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: step.isCompleted ? Colors.black : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    step.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  if (step.date != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(step.date!),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} às ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _TimelineStep {
  final String title;
  final String description;
  final bool isCompleted;
  final DateTime? date;
  final IconData icon;
  final Color color;

  _TimelineStep({
    required this.title,
    required this.description,
    required this.isCompleted,
    this.date,
    required this.icon,
    required this.color,
  });
}