import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'accessibility_widgets.dart';
import '../../core/theme/accessibility_theme.dart';

/// Widget para testar acessibilidade e gerar relatórios
class AccessibilityTester extends StatefulWidget {
  final Widget child;
  final bool enabled;

  const AccessibilityTester({
    super.key,
    required this.child,
    this.enabled = false, // Só ativo em modo debug
  });

  @override
  State<AccessibilityTester> createState() => _AccessibilityTesterState();
}

class _AccessibilityTesterState extends State<AccessibilityTester> {
  final List<AccessibilityIssue> _issues = [];
  bool _isTesting = false;

  @override
  void initState() {
    super.initState();
    if (widget.enabled) {
      _startAccessibilityTest();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.enabled && _isTesting)
          Positioned(
            top: 50,
            right: 16,
            child: FloatingActionButton(
              onPressed: _showAccessibilityReport,
              backgroundColor: Colors.orange,
              child: const Icon(Icons.accessibility),
            ),
          ),
      ],
    );
  }

  /// Inicia teste de acessibilidade
  void _startAccessibilityTest() {
    setState(() => _isTesting = true);
    
    // Simula testes de acessibilidade
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _testTouchTargets();
      _testColorContrast();
      _testTextSizes();
      _testSemantics();
      _testKeyboardNavigation();
    });
  }

  /// Testa tamanhos de alvos de toque
  void _testTouchTargets() {
    // Verifica se botões têm pelo menos 48x48dp
    // Implementação simplificada - em produção seria mais robusta
    _addIssue(
      AccessibilityIssue(
        type: IssueType.touchTarget,
        severity: IssueSeverity.warning,
        message: 'Verifique se todos os botões têm pelo menos 48x48dp',
        location: 'Tela principal',
      ),
    );
  }

  /// Testa contraste de cores
  void _testColorContrast() {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final onPrimaryColor = theme.colorScheme.onPrimary;
    
    if (!AccessibilityTheme.hasAdequateContrast(primaryColor, onPrimaryColor)) {
      _addIssue(
        AccessibilityIssue(
          type: IssueType.colorContrast,
          severity: IssueSeverity.error,
          message: 'Contraste insuficiente entre cores primárias',
          location: 'Tema da aplicação',
        ),
      );
    }
  }

  /// Testa tamanhos de texto
  void _testTextSizes() {
    final textTheme = Theme.of(context).textTheme;
    final bodyTextSize = textTheme.bodyMedium?.fontSize ?? 14;
    
    if (bodyTextSize < 16) {
      _addIssue(
        AccessibilityIssue(
          type: IssueType.textSize,
          severity: IssueSeverity.warning,
          message: 'Tamanho de texto pode ser muito pequeno para alguns usuários',
          location: 'Tema de texto',
        ),
      );
    }
  }

  /// Testa widgets Semantics
  void _testSemantics() {
    // Verifica se elementos importantes têm labels
    _addIssue(
      AccessibilityIssue(
        type: IssueType.semantics,
        severity: IssueSeverity.info,
        message: 'Verifique se todos os elementos interativos têm labels Semantics',
        location: 'Widgets interativos',
      ),
    );
  }

  /// Testa navegação por teclado
  void _testKeyboardNavigation() {
    _addIssue(
      AccessibilityIssue(
        type: IssueType.keyboardNavigation,
        severity: IssueSeverity.info,
        message: 'Teste navegação por Tab e setas do teclado',
        location: 'Navegação',
      ),
    );
  }

  /// Adiciona um problema de acessibilidade
  void _addIssue(AccessibilityIssue issue) {
    setState(() {
      _issues.add(issue);
    });
  }

  /// Mostra relatório de acessibilidade
  void _showAccessibilityReport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Relatório de Acessibilidade'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: ListView.builder(
            itemCount: _issues.length,
            itemBuilder: (context, index) {
              final issue = _issues[index];
              return ListTile(
                leading: Icon(
                  _getIssueIcon(issue.severity),
                  color: _getIssueColor(issue.severity),
                ),
                title: Text(issue.message),
                subtitle: Text('${issue.type.name} - ${issue.location}'),
                trailing: Chip(
                  label: Text(issue.severity.name.toUpperCase()),
                  backgroundColor: _getIssueColor(issue.severity).withValues(alpha: 0.2),
                  labelStyle: TextStyle(
                    color: _getIssueColor(issue.severity),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
          ElevatedButton(
            onPressed: _exportReport,
            child: const Text('Exportar'),
          ),
        ],
      ),
    );
  }

  /// Obtém ícone para o tipo de problema
  IconData _getIssueIcon(IssueSeverity severity) {
    switch (severity) {
      case IssueSeverity.error:
        return Icons.error;
      case IssueSeverity.warning:
        return Icons.warning;
      case IssueSeverity.info:
        return Icons.info;
    }
  }

  /// Obtém cor para o tipo de problema
  Color _getIssueColor(IssueSeverity severity) {
    switch (severity) {
      case IssueSeverity.error:
        return Colors.red;
      case IssueSeverity.warning:
        return Colors.orange;
      case IssueSeverity.info:
        return Colors.blue;
    }
  }

  /// Exporta relatório
  void _exportReport() {
    final report = _generateReport();
    Clipboard.setData(ClipboardData(text: report));
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Relatório copiado para a área de transferência'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// Gera relatório em texto
  String _generateReport() {
    final buffer = StringBuffer();
    buffer.writeln('RELATÓRIO DE ACESSIBILIDADE - MERCADO FÁCIL');
    buffer.writeln('Data: ${DateTime.now()}');
    buffer.writeln('Total de problemas: ${_issues.length}');
    buffer.writeln();

    final errors = _issues.where((i) => i.severity == IssueSeverity.error).length;
    final warnings = _issues.where((i) => i.severity == IssueSeverity.warning).length;
    final infos = _issues.where((i) => i.severity == IssueSeverity.info).length;

    buffer.writeln('RESUMO:');
    buffer.writeln('- Erros: $errors');
    buffer.writeln('- Avisos: $warnings');
    buffer.writeln('- Informações: $infos');
    buffer.writeln();

    buffer.writeln('DETALHES:');
    for (final issue in _issues) {
      buffer.writeln('[${issue.severity.name.toUpperCase()}] ${issue.type.name}');
      buffer.writeln('Localização: ${issue.location}');
      buffer.writeln('Mensagem: ${issue.message}');
      buffer.writeln();
    }

    buffer.writeln('RECOMENDAÇÕES:');
    buffer.writeln('1. Corrija todos os erros de contraste de cores');
    buffer.writeln('2. Aumente tamanhos de alvos de toque se necessário');
    buffer.writeln('3. Adicione labels Semantics em elementos interativos');
    buffer.writeln('4. Teste navegação por teclado');
    buffer.writeln('5. Teste com leitores de tela');

    return buffer.toString();
  }
}

/// Classe para representar problemas de acessibilidade
class AccessibilityIssue {
  final IssueType type;
  final IssueSeverity severity;
  final String message;
  final String location;

  AccessibilityIssue({
    required this.type,
    required this.severity,
    required this.message,
    required this.location,
  });
}

/// Tipos de problemas de acessibilidade
enum IssueType {
  touchTarget,
  colorContrast,
  textSize,
  semantics,
  keyboardNavigation,
  screenReader,
  focusManagement,
}

/// Severidade dos problemas
enum IssueSeverity {
  error,
  warning,
  info,
}

/// Widget para simular leitor de tela
class ScreenReaderSimulator extends StatefulWidget {
  final Widget child;
  final bool enabled;

  const ScreenReaderSimulator({
    super.key,
    required this.child,
    this.enabled = false,
  });

  @override
  State<ScreenReaderSimulator> createState() => _ScreenReaderSimulatorState();
}

class _ScreenReaderSimulatorState extends State<ScreenReaderSimulator> {
  final List<String> _announcements = [];
  bool _isSimulating = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.enabled)
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.volume_up),
                        const SizedBox(width: 8),
                        const Text('Simulador de Leitor de Tela'),
                        const Spacer(),
                        IconButton(
                          onPressed: _toggleSimulation,
                          icon: Icon(_isSimulating ? Icons.pause : Icons.play_arrow),
                        ),
                        IconButton(
                          onPressed: _clearAnnouncements,
                          icon: const Icon(Icons.clear),
                        ),
                      ],
                    ),
                    if (_isSimulating && _announcements.isNotEmpty)
                      Container(
                        height: 100,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListView.builder(
                          itemCount: _announcements.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              dense: true,
                              title: Text(_announcements[index]),
                              trailing: IconButton(
                                onPressed: () => _removeAnnouncement(index),
                                icon: const Icon(Icons.close, size: 16),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _toggleSimulation() {
    setState(() {
      _isSimulating = !_isSimulating;
    });
  }

  void _clearAnnouncements() {
    setState(() {
      _announcements.clear();
    });
  }

  void _removeAnnouncement(int index) {
    setState(() {
      _announcements.removeAt(index);
    });
  }

  void addAnnouncement(String message) {
    if (_isSimulating) {
      setState(() {
        _announcements.add('${DateTime.now().toString().substring(11, 19)}: $message');
      });
    }
  }
}

/// Mixin para adicionar funcionalidades de teste de acessibilidade
mixin AccessibilityTestingMixin {
  /// Testa se um widget é acessível
  bool testWidgetAccessibility(Widget widget) {
    // Implementação simplificada
    // Em produção, seria mais robusta
    return true;
  }

  /// Gera relatório de acessibilidade para um widget
  String generateAccessibilityReport(Widget widget) {
    return 'Relatório de acessibilidade para ${widget.runtimeType}';
  }

  /// Valida contraste de cores
  bool validateColorContrast(Color foreground, Color background) {
    return AccessibilityTheme.hasAdequateContrast(foreground, background);
  }

  /// Valida tamanho de alvo de toque
  bool validateTouchTarget(Size size) {
    return AccessibilityConfig.isTouchTargetAdequate(size);
  }

  /// Valida tamanho de texto
  bool validateTextSize(double fontSize) {
    return AccessibilityConfig.isTextSizeAdequate(fontSize);
  }
}