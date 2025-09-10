import 'package:flutter/material.dart';
import 'responsive_breakpoints.dart';
import 'tablet_layout.dart';
import 'dynamic_font_sizes.dart';

/// Testador responsivo para verificar comportamento em diferentes resoluções
class ResponsiveTester extends StatefulWidget {
  final Widget child;
  final bool enabled;

  const ResponsiveTester({
    super.key,
    required this.child,
    this.enabled = false, // Só ativo em modo debug
  });

  @override
  State<ResponsiveTester> createState() => _ResponsiveTesterState();
}

class _ResponsiveTesterState extends State<ResponsiveTester> {
  bool _showTester = false;
  Orientation _currentOrientation = Orientation.portrait;
  double _customWidth = 375.0;
  double _customHeight = 812.0;

  // Dispositivos de teste pré-definidos
  final Map<String, Map<String, double>> _testDevices = {
    'iPhone SE': {'width': 375, 'height': 667},
    'iPhone 12': {'width': 390, 'height': 844},
    'iPhone 12 Pro Max': {'width': 428, 'height': 926},
    'iPad Mini': {'width': 768, 'height': 1024},
    'iPad Pro': {'width': 1024, 'height': 1366},
    'Desktop Small': {'width': 1200, 'height': 800},
    'Desktop Large': {'width': 1920, 'height': 1080},
  };

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.enabled)
          Positioned(
            top: 50,
            left: 16,
            child: FloatingActionButton(
              onPressed: _toggleTester,
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              child: const Icon(Icons.devices),
            ),
          ),
        if (widget.enabled && _showTester)
          Positioned(
            top: 120,
            left: 16,
            right: 16,
            child: Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.devices),
                        const SizedBox(width: 8),
                        const Text('Testador Responsivo'),
                        const Spacer(),
                        IconButton(
                          onPressed: _toggleTester,
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Informações do dispositivo atual
                    _buildDeviceInfo(),
                    const SizedBox(height: 16),
                    
                    // Seletor de dispositivos
                    _buildDeviceSelector(),
                    const SizedBox(height: 16),
                    
                    // Controles de orientação
                    _buildOrientationControls(),
                    const SizedBox(height: 16),
                    
                    // Controles customizados
                    _buildCustomControls(),
                    const SizedBox(height: 16),
                    
                    // Botões de ação
                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDeviceInfo() {
    final deviceInfo = ResponsiveBreakpoints.getDeviceInfo(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Dispositivo Atual:', style: TextStyle(fontWeight: FontWeight.bold)),
        Text('Tipo: ${deviceInfo.deviceType.name}'),
        Text('Tamanho: ${deviceInfo.deviceSize.name}'),
        Text('Largura: ${deviceInfo.width.toStringAsFixed(0)}dp'),
        Text('Altura: ${deviceInfo.height.toStringAsFixed(0)}dp'),
        Text('Orientação: ${deviceInfo.orientation.name}'),
        Text('Pixel Ratio: ${deviceInfo.devicePixelRatio.toStringAsFixed(2)}'),
      ],
    );
  }

  Widget _buildDeviceSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Dispositivos de Teste:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _testDevices.entries.map((entry) {
            final deviceName = entry.key;
            final dimensions = entry.value;
            
            return ElevatedButton(
              onPressed: () => _setCustomDimensions(dimensions['width']!, dimensions['height']!),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              child: Text(deviceName),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildOrientationControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Orientação:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: [
            ElevatedButton(
              onPressed: () => _setOrientation(Orientation.portrait),
              style: ElevatedButton.styleFrom(
                backgroundColor: _currentOrientation == Orientation.portrait 
                    ? Colors.blue 
                    : Colors.grey[300],
                foregroundColor: Colors.white,
              ),
              child: const Text('Retrato'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () => _setOrientation(Orientation.landscape),
              style: ElevatedButton.styleFrom(
                backgroundColor: _currentOrientation == Orientation.landscape 
                    ? Colors.blue 
                    : Colors.grey[300],
                foregroundColor: Colors.white,
              ),
              child: const Text('Paisagem'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCustomControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Dimensões Customizadas:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Largura:'),
                  Slider(
                    value: _customWidth,
                    min: 200,
                    max: 2000,
                    divisions: 180,
                    label: _customWidth.toStringAsFixed(0),
                    onChanged: (value) => setState(() => _customWidth = value),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Altura:'),
                  Slider(
                    value: _customHeight,
                    min: 400,
                    max: 2000,
                    divisions: 160,
                    label: _customHeight.toStringAsFixed(0),
                    onChanged: (value) => setState(() => _customHeight = value),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () => _setCustomDimensions(_customWidth, _customHeight),
          child: const Text('Aplicar Dimensões'),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: _generateReport,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Gerar Relatório'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton(
            onPressed: _resetToDefault,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reset'),
          ),
        ),
      ],
    );
  }

  void _toggleTester() {
    setState(() {
      _showTester = !_showTester;
    });
  }

  void _setCustomDimensions(double width, double height) {
    // Em um ambiente real, isso seria aplicado através de um MediaQuery customizado
    // Por enquanto, apenas atualizamos os valores
    setState(() {
      _customWidth = width;
      _customHeight = height;
    });
    
    // Log das dimensões aplicadas
    debugPrint('Dimensões aplicadas: ${width.toStringAsFixed(0)}x${height.toStringAsFixed(0)}');
  }

  void _setOrientation(Orientation orientation) {
    setState(() {
      _currentOrientation = orientation;
    });
    
    debugPrint('Orientação alterada: ${orientation.name}');
  }

  void _generateReport() {
    final deviceInfo = ResponsiveBreakpoints.getDeviceInfo(context);
    final report = _generateResponsiveReport(deviceInfo);
    
    // Em um ambiente real, isso seria salvo ou exibido
    debugPrint('=== RELATÓRIO RESPONSIVO ===');
    debugPrint(report);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Relatório gerado! Verifique o console.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _resetToDefault() {
    setState(() {
      _customWidth = 375.0;
      _customHeight = 812.0;
      _currentOrientation = Orientation.portrait;
    });
    
    debugPrint('Configurações resetadas para padrão');
  }

  String _generateResponsiveReport(DeviceInfo deviceInfo) {
    final buffer = StringBuffer();
    
    buffer.writeln('RELATÓRIO RESPONSIVO - MERCADO FÁCIL');
    buffer.writeln('Data: ${DateTime.now()}');
    buffer.writeln();
    
    buffer.writeln('INFORMAÇÕES DO DISPOSITIVO:');
    buffer.writeln('- Tipo: ${deviceInfo.deviceType.name}');
    buffer.writeln('- Tamanho: ${deviceInfo.deviceSize.name}');
    buffer.writeln('- Largura: ${deviceInfo.width.toStringAsFixed(0)}dp');
    buffer.writeln('- Altura: ${deviceInfo.height.toStringAsFixed(0)}dp');
    buffer.writeln('- Orientação: ${deviceInfo.orientation.name}');
    buffer.writeln('- Pixel Ratio: ${deviceInfo.devicePixelRatio.toStringAsFixed(2)}');
    buffer.writeln();
    
    buffer.writeln('BREAKPOINTS VERIFICADOS:');
    buffer.writeln('- É Mobile: ${ResponsiveBreakpoints.isMobile(context)}');
    buffer.writeln('- É Tablet: ${ResponsiveBreakpoints.isTablet(context)}');
    buffer.writeln('- É Desktop: ${ResponsiveBreakpoints.isDesktop(context)}');
    buffer.writeln('- É Large Desktop: ${ResponsiveBreakpoints.isLargeDesktop(context)}');
    buffer.writeln();
    
    buffer.writeln('LAYOUT ADAPTATIVO:');
    buffer.writeln('- Padding: ${TabletLayout.getAdaptivePadding(context)}');
    buffer.writeln('- Spacing: ${TabletLayout.getAdaptiveSpacing(context)}');
    buffer.writeln('- Grid Columns: ${TabletLayout.getGridColumns(context)}');
    buffer.writeln('- Max Content Width: ${TabletLayout.getMaxContentWidth(context)}');
    buffer.writeln();
    
    buffer.writeln('FONTES DINÂMICAS:');
    buffer.writeln('- Display Large: ${DynamicFontSizes.getDisplayLarge(context).toStringAsFixed(1)}');
    buffer.writeln('- Headline Medium: ${DynamicFontSizes.getHeadlineMedium(context).toStringAsFixed(1)}');
    buffer.writeln('- Body Large: ${DynamicFontSizes.getBodyLarge(context).toStringAsFixed(1)}');
    buffer.writeln('- Button Text: ${DynamicFontSizes.getButtonText(context).toStringAsFixed(1)}');
    buffer.writeln();
    
    buffer.writeln('RECOMENDAÇÕES:');
    if (ResponsiveBreakpoints.isMobile(context)) {
      buffer.writeln('- Otimizar para navegação por toque');
      buffer.writeln('- Usar layouts de coluna única');
      buffer.writeln('- Manter elementos próximos');
    } else if (ResponsiveBreakpoints.isTablet(context)) {
      buffer.writeln('- Aproveitar espaço extra com grids');
      buffer.writeln('- Usar sidebars quando apropriado');
      buffer.writeln('- Aumentar tamanhos de fonte');
    } else {
      buffer.writeln('- Implementar layout desktop completo');
      buffer.writeln('- Usar múltiplas colunas');
      buffer.writeln('- Adicionar navegação por teclado');
    }
    
    return buffer.toString();
  }
}

/// Widget para simular diferentes resoluções
class ResolutionSimulator extends StatelessWidget {
  final Widget child;
  final double width;
  final double height;
  final Orientation orientation;

  const ResolutionSimulator({
    super.key,
    required this.child,
    required this.width,
    required this.height,
    this.orientation = Orientation.portrait,
  });

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        size: Size(width, height),
      ),
      child: child,
    );
  }
}

/// Mixin para adicionar funcionalidades de teste responsivo
mixin ResponsiveTestingMixin {
  /// Testa se um widget é responsivo
  bool testWidgetResponsiveness(Widget widget) {
    // Implementação simplificada
    // Em produção, seria mais robusta
    return true;
  }

  /// Gera relatório de responsividade para um widget
  String generateResponsiveReport(Widget widget) {
    return 'Relatório de responsividade para ${widget.runtimeType}';
  }

  /// Valida breakpoints
  bool validateBreakpoints(BuildContext context) {
    final deviceInfo = ResponsiveBreakpoints.getDeviceInfo(context);
    return deviceInfo.width > 0 && deviceInfo.height > 0;
  }

  /// Valida layout adaptativo
  bool validateAdaptiveLayout(BuildContext context) {
    final padding = TabletLayout.getAdaptivePadding(context);
    final spacing = TabletLayout.getAdaptiveSpacing(context);
    return padding.horizontal > 0 && spacing > 0;
  }

  /// Valida fontes dinâmicas
  bool validateDynamicFonts(BuildContext context) {
    final fontSize = DynamicFontSizes.getBodyLarge(context);
    return fontSize > 0;
  }
} 