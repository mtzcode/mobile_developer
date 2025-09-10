import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/utils/notification_test_helper.dart';
import '../../core/utils/snackbar_utils.dart';

/// Tela para testar funcionalidades de notificação FCM
class NotificationTestScreen extends StatefulWidget {
  const NotificationTestScreen({super.key});

  @override
  State<NotificationTestScreen> createState() => _NotificationTestScreenState();
}

class _NotificationTestScreenState extends State<NotificationTestScreen> {
  String? _currentToken;
  Map<String, dynamic>? _debugInfo;
  bool _isLoading = false;
  final Set<String> _subscribedTopics = {};

  @override
  void initState() {
    super.initState();
    _loadDebugInfo();
  }

  Future<void> _loadDebugInfo() async {
    setState(() => _isLoading = true);
    try {
      final debugInfo = await NotificationTestHelper.getDebugInfo();
      setState(() {
        _debugInfo = debugInfo;
        _currentToken = debugInfo['token'];
      });
    } catch (e) {
      if (mounted) {
        SnackBarUtils.showError(context, 'Erro ao carregar informações: $e');
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _copyToken() async {
    final token = await NotificationTestHelper.getAndCopyToken();
    if (token != null && mounted) {
      SnackBarUtils.showSuccess(context, 'Token copiado para clipboard!');
      setState(() => _currentToken = token);
    }
  }

  Future<void> _refreshToken() async {
    setState(() => _isLoading = true);
    final newToken = await NotificationTestHelper.refreshToken();
    if (newToken != null && mounted) {
      SnackBarUtils.showSuccess(context, 'Token atualizado!');
      setState(() => _currentToken = newToken);
      await _loadDebugInfo();
    }
    setState(() => _isLoading = false);
  }

  Future<void> _testPermissions() async {
    setState(() => _isLoading = true);
    final hasPermissions = await NotificationTestHelper.testPermissions();
    if (mounted) {
      if (hasPermissions) {
        SnackBarUtils.showSuccess(context, 'Permissões concedidas!');
      } else {
        SnackBarUtils.showError(context, 'Permissões negadas ou limitadas');
      }
      await _loadDebugInfo();
    }
    setState(() => _isLoading = false);
  }

  Future<void> _subscribeToTopic(String topic) async {
    await NotificationTestHelper.subscribeToTestTopic(topic);
    setState(() => _subscribedTopics.add(topic));
    if (mounted) {
      SnackBarUtils.showSuccess(context, 'Inscrito no tópico: $topic');
    }
  }

  Future<void> _unsubscribeFromTopic(String topic) async {
    await NotificationTestHelper.unsubscribeFromTopic(topic);
    setState(() => _subscribedTopics.remove(topic));
    if (mounted) {
      SnackBarUtils.showInfo(context, 'Desinscrito do tópico: $topic');
    }
  }

  Future<void> _generateReport() async {
    setState(() => _isLoading = true);
    final report = await NotificationTestHelper.generateTestReport();
    await Clipboard.setData(ClipboardData(text: report));
    if (mounted) {
      SnackBarUtils.showSuccess(context, 'Relatório copiado para clipboard!');
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🔥 Teste FCM'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadDebugInfo,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoSection(),
                  const SizedBox(height: 24),
                  _buildTokenSection(),
                  const SizedBox(height: 24),
                  _buildPermissionsSection(),
                  const SizedBox(height: 24),
                  _buildTopicsSection(),
                  const SizedBox(height: 24),
                  _buildActionsSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[600]),
                const SizedBox(width: 8),
                Text(
                  'Informações do FCM',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_debugInfo != null) ...
              _debugInfo!.entries.map((entry) {
                if (entry.key == 'token') return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 120,
                        child: Text(
                          '${entry.key}:',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          entry.value.toString(),
                          style: TextStyle(color: Colors.grey[600]),
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

  Widget _buildTokenSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.key, color: Colors.green[600]),
                const SizedBox(width: 8),
                Text(
                  'Token FCM',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Text(
                _currentToken ?? 'Token não disponível',
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _copyToken,
                    icon: const Icon(Icons.copy),
                    label: const Text('Copiar Token'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _refreshToken,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Atualizar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.security, color: Colors.orange[600]),
                const SizedBox(width: 8),
                Text(
                  'Permissões',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _testPermissions,
                icon: const Icon(Icons.check_circle),
                label: const Text('Testar Permissões'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.topic, color: Colors.purple[600]),
                const SizedBox(width: 8),
                Text(
                  'Tópicos de Teste',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...NotificationTestHelper.testTopics.map((topic) {
              final isSubscribed = _subscribedTopics.contains(topic);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        topic,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    Switch(
                      value: isSubscribed,
                      onChanged: (value) {
                        if (value) {
                          _subscribeToTopic(topic);
                        } else {
                          _unsubscribeFromTopic(topic);
                        }
                      },
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

  Widget _buildActionsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.build, color: Colors.red[600]),
                const SizedBox(width: 8),
                Text(
                  'Ações de Teste',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _generateReport,
                icon: const Icon(Icons.description),
                label: const Text('Gerar Relatório Completo'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[600],
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '💡 Dica: Use o relatório para debug e compartilhamento com a equipe.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}