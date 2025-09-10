import 'package:flutter/material.dart';

/// Chave global para navegação em SnackBars e outros fluxos
final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

/// Utilitário para SnackBar padronizado no app
void showAppSnackBar(
  BuildContext context,
  String message, {
  Color? backgroundColor,
  IconData? icon,
  Duration duration = const Duration(milliseconds: 1800),
  SnackBarAction? action,
}) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.primary,
      duration: duration,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      behavior: SnackBarBehavior.floating,
      action: action,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      elevation: 6,
    ),
  );
}

/// Classe utilitária para SnackBars com métodos estáticos
class SnackBarUtils {
  /// Mostra SnackBar de sucesso
  static void showSuccess(BuildContext context, String message) {
    showAppSnackBar(
      context,
      message,
      backgroundColor: Colors.green,
      icon: Icons.check_circle,
    );
  }

  /// Mostra SnackBar de erro
  static void showError(BuildContext context, String message) {
    showAppSnackBar(
      context,
      message,
      backgroundColor: Colors.red,
      icon: Icons.error,
    );
  }

  /// Mostra SnackBar de informação
  static void showInfo(BuildContext context, String message) {
    showAppSnackBar(
      context,
      message,
      backgroundColor: Colors.blue,
      icon: Icons.info,
    );
  }

  /// Mostra SnackBar de aviso
  static void showWarning(BuildContext context, String message) {
    showAppSnackBar(
      context,
      message,
      backgroundColor: Colors.orange,
      icon: Icons.warning,
    );
  }
}