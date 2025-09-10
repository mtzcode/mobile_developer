import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/providers/notification_scheduler_provider.dart';

/// Tela de administração do sistema de notificações
class NotificationAdminScreen extends ConsumerStatefulWidget {
  const NotificationAdminScreen({super.key});

  @override
  ConsumerState<NotificationAdminScreen> createState() => _NotificationAdminScreenState();
}

class _NotificationAdminScreenState extends ConsumerState<NotificationAdminScreen> {
  bool _isExecutingTasks = false;
  String? _lastExecutionResult;
  
  @override
  void initState() {
    super.initState();
    // Garante que o controle automático está ativo
    ref.read(autoSchedulerControlProvider);
  }

  @override
  Widget build(BuildContext context) {
    final schedulerState = ref.watch(notificationSchedulerStateProvider);
    final statistics = ref.watch(notificationStatisticsProvider);
    final summary = ref.watch(notificationSummaryProvider);
    final isHealthy = ref.watch(schedulerHealthProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administração de Notificações'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(notificationSchedulerStateProvider.notifier).refreshStatus();
            },
            tooltip: 'Atualizar Status',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.read(notificationSchedulerStateProvider.notifier).refreshStatus();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status do Agendador
              _buildStatusCard(schedulerState, isHealthy),
              const SizedBox(height: 16),
              
              // Controles do Agendador
              _buildControlsCard(schedulerState),
              const SizedBox(height: 16),
              
              // Estatísticas Resumidas
              _buildSummaryCard(summary),
              const SizedBox(height: 16),
              
              // Estatísticas Detalhadas
              statistics.when(
                data: (stats) => _buildDetailedStatsCard(stats),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Erro ao carregar estatísticas: ${error.toString()}'),
                      ElevatedButton(
                        onPressed: () => ref.invalidate(notificationStatisticsProvider),
                        child: const Text('Tentar Novamente'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Informações do Sistema
              _buildSystemInfoCard(schedulerState),
              const SizedBox(height: 16),
              
              // Logs e Execução Manual
              _buildManualExecutionCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard(NotificationSchedulerState state, bool isHealthy) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isHealthy ? Icons.check_circle : Icons.error,
                  color: isHealthy ? Colors.green : Colors.red,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Status do Agendador',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: state.isRunning ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    state.isRunning ? 'ATIVO' : 'INATIVO',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                if (state.lastUpdate != null)
                  Text(
                    'Última atualização: ${_formatDateTime(state.lastUpdate!)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
            
            if (state.error != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  border: Border.all(color: Colors.red.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        state.error!,
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildControlsCard(NotificationSchedulerState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Controles',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: state.isRunning ? null : () {
                      ref.read(notificationSchedulerStateProvider.notifier).start();
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Iniciar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: !state.isRunning ? null : () {
                      ref.read(notificationSchedulerStateProvider.notifier).stop();
                    },
                    icon: const Icon(Icons.stop),
                    label: const Text('Parar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ref.read(notificationSchedulerStateProvider.notifier).restart();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Reiniciar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(Map<String, dynamic> summary) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumo das Notificações',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    'Total Enviadas',
                    summary['total_notifications']?.toString() ?? '0',
                    Icons.send,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    'Taxa de Sucesso',
                    '${summary['success_rate'] ?? 100}%',
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    'Favoritos',
                    summary['favorites_notifications']?.toString() ?? '0',
                    Icons.favorite,
                    Colors.red,
                  ),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    'Carrinho',
                    summary['cart_reminders']?.toString() ?? '0',
                    Icons.shopping_cart,
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedStatsCard(Map<String, dynamic> stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Estatísticas Detalhadas',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            
            ...stats.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      entry.key.replaceAll('_', ' ').split(' ').map((word) => 
                          word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : ''
                      ).join(' '),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      entry.value.toString(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemInfoCard(NotificationSchedulerState state) {
    final status = state.status;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informações do Sistema',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            
            if (status.isNotEmpty) ...[
              ...status.entries.where((e) => e.key != 'statistics' && e.key != 'services_status').map((entry) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        entry.key.replaceAll('_', ' ').split(' ').map((word) => 
                            word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : ''
                        ).join(' '),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        entry.value.toString(),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ] else ...[
              const Text('Nenhuma informação disponível'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildManualExecutionCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Execução Manual',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isExecutingTasks ? null : _executeAllTasks,
                icon: _isExecutingTasks 
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.play_circle_filled),
                label: Text(_isExecutingTasks ? 'Executando...' : 'Executar Todas as Tarefas'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            
            if (_lastExecutionResult != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Resultado da Última Execução:',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _lastExecutionResult!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _executeAllTasks() async {
    setState(() {
      _isExecutingTasks = true;
      _lastExecutionResult = null;
    });
    
    try {
      final result = await ref.read(notificationSchedulerStateProvider.notifier).forceRunAllTasks();
      
      setState(() {
        _lastExecutionResult = result['success'] == true 
            ? 'Execução concluída com sucesso em ${result['duration_ms']}ms'
            : 'Erro na execução: ${result['error']}';
      });
      
      if (result['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Todas as tarefas foram executadas com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro na execução: ${result['error']}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
      
    } catch (e) {
      setState(() {
        _lastExecutionResult = 'Erro inesperado: $e';
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro inesperado: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isExecutingTasks = false;
      });
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

}