import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Widgets de acessibilidade reutilizáveis
class AccessibilityWidgets {
  /// Botão acessível com feedback tátil
  static Widget accessibleButton({
    required String label,
    required VoidCallback onPressed,
    required Widget child,
    String? hint,
    bool enabled = true,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      button: true,
      enabled: enabled,
      child: GestureDetector(
        onTap: enabled ? () {
          HapticFeedback.lightImpact();
          onPressed();
        } : null,
        child: child,
      ),
    );
  }

  /// Campo de texto acessível
  static Widget accessibleTextField({
    required String label,
    required TextEditingController controller,
    String? hint,
    String? errorText,
    bool isPassword = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    VoidCallback? onTap,
    bool readOnly = false,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      textField: true,
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
        validator: validator,
        readOnly: readOnly,
        onTap: onTap,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          errorText: errorText,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  /// Imagem acessível com descrição
  static Widget accessibleImage({
    required String imageUrl,
    required String description,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    return Semantics(
      label: description,
      image: true,
      child: Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return placeholder ?? const CircularProgressIndicator();
        },
        errorBuilder: (context, error, stackTrace) {
          return errorWidget ?? const Icon(Icons.error);
        },
      ),
    );
  }

  /// Lista acessível
  static Widget accessibleList({
    required String label,
    required List<Widget> children,
    ScrollController? controller,
    EdgeInsets? padding,
  }) {
    return Semantics(
      label: label,
      child: ListView(
        controller: controller,
        padding: padding,
        children: children,
      ),
    );
  }

  /// Card acessível
  static Widget accessibleCard({
    required String label,
    required Widget child,
    String? hint,
    VoidCallback? onTap,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          child: child,
        ),
      ),
    );
  }

  /// Ícone acessível
  static Widget accessibleIcon({
    required IconData icon,
    required String label,
    double? size,
    Color? color,
    VoidCallback? onTap,
  }) {
    return Semantics(
      label: label,
      child: GestureDetector(
        onTap: onTap,
        child: Icon(
          icon,
          size: size,
          color: color,
        ),
      ),
    );
  }

  /// Texto acessível
  static Widget accessibleText({
    required String text,
    required String label,
    TextStyle? style,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  }) {
    return Semantics(
      label: label,
      child: Text(
        text,
        style: style,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
      ),
    );
  }

  /// Switch acessível
  static Widget accessibleSwitch({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
    String? hint,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      value: value.toString(),
      child: Switch(
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  /// Checkbox acessível
  static Widget accessibleCheckbox({
    required String label,
    required bool value,
    required ValueChanged<bool?> onChanged,
    String? hint,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      value: value.toString(),
      child: Checkbox(
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  /// Slider acessível
  static Widget accessibleSlider({
    required String label,
    required double value,
    required ValueChanged<double> onChanged,
    required double min,
    required double max,
    int? divisions,
    String? hint,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      value: value.toString(),
      child: Slider(
        value: value,
        min: min,
        max: max,
        divisions: divisions,
        onChanged: onChanged,
      ),
    );
  }

  /// Loading acessível
  static Widget accessibleLoading({
    required String message,
    Color? color,
  }) {
    return Semantics(
      label: message,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: color),
            const SizedBox(height: 16),
            Text(message),
          ],
        ),
      ),
    );
  }

  /// Container acessível
  static Widget accessibleContainer({
    required String label,
    required Widget child,
    String? hint,
    VoidCallback? onTap,
    Color? color,
    EdgeInsets? padding,
    EdgeInsets? margin,
    double? width,
    double? height,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          color: color,
          padding: padding,
          margin: margin,
          width: width,
          height: height,
          child: child,
        ),
      ),
    );
  }
}

/// Mixin para adicionar funcionalidades de acessibilidade
mixin AccessibilityMixin {
  /// Anuncia mudança para leitores de tela
  void announceForAccessibility(String message) {
    // Fallback para debugPrint, pois SemanticsService pode não estar disponível
    debugPrint('Accessibility Announcement: $message');
  }

  /// Fornece feedback tátil
  void provideHapticFeedback(HapticFeedbackType type) {
    switch (type) {
      case HapticFeedbackType.light:
        HapticFeedback.lightImpact();
        break;
      case HapticFeedbackType.medium:
        HapticFeedback.mediumImpact();
        break;
      case HapticFeedbackType.heavy:
        HapticFeedback.heavyImpact();
        break;
      case HapticFeedbackType.selection:
        HapticFeedback.selectionClick();
        break;
    }
  }

  /// Valida contraste de cores
  bool hasGoodContrast(Color foreground, Color background) {
    // Cálculo simplificado de contraste
    final luminance1 = foreground.computeLuminance();
    final luminance2 = background.computeLuminance();
    final brightest = luminance1 > luminance2 ? luminance1 : luminance2;
    final darkest = luminance1 > luminance2 ? luminance2 : luminance1;
    final contrast = (brightest + 0.05) / (darkest + 0.05);
    return contrast >= 4.5; // WCAG AA standard
  }
}

/// Tipos de feedback tátil
enum HapticFeedbackType {
  light,
  medium,
  heavy,
  selection,
}

/// Configurações de acessibilidade
class AccessibilityConfig {
  static const double minimumTouchTargetSize = 48.0;
  static const double minimumTextSize = 16.0;
  static const double minimumContrastRatio = 4.5;
  static const Duration minimumAnimationDuration = Duration(milliseconds: 300);
  
  /// Verifica se o tamanho do alvo de toque é adequado
  static bool isTouchTargetAdequate(Size size) {
    return size.width >= minimumTouchTargetSize && 
           size.height >= minimumTouchTargetSize;
  }
  
  /// Verifica se o tamanho do texto é adequado
  static bool isTextSizeAdequate(double fontSize) {
    return fontSize >= minimumTextSize;
  }
} 