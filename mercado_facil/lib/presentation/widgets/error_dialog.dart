import 'package:flutter/material.dart';
import '../../core/exceptions/app_exception.dart';

/// Widget para exibir diálogos de erro padronizados
class ErrorDialog extends StatelessWidget {
  final String message;
  final String? title;
  final IconData? icon;
  final Color? color;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;
  final bool showRetryButton;
  final bool showDismissButton;

  const ErrorDialog({
    super.key,
    required this.message,
    this.title,
    this.icon,
    this.color,
    this.onRetry,
    this.onDismiss,
    this.showRetryButton = false,
    this.showDismissButton = true,
  });

  /// Construtor a partir de uma AppException
  factory ErrorDialog.fromException(
    AppException exception, {
    VoidCallback? onRetry,
    VoidCallback? onDismiss,
    bool showRetryButton = false,
    bool showDismissButton = true,
  }) {
    return ErrorDialog(
      message: exception.displayMessage,
      title: _getErrorTitle(exception.type),
      icon: exception.icon,
      color: exception.color,
      onRetry: onRetry,
      onDismiss: onDismiss,
      showRetryButton: showRetryButton || exception.isRetryable,
      showDismissButton: showDismissButton,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Icon(
            icon ?? Icons.error,
            color: color ?? Theme.of(context).colorScheme.error,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title ?? 'Erro',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: Text(
        message,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      actions: [
        if (showRetryButton && onRetry != null)
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Tentar Novamente'),
          ),
        if (showDismissButton)
          TextButton(
            onPressed: onDismiss ?? () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
      ],
    );
  }

  /// Exibe o diálogo de erro
  static Future<void> show(
    BuildContext context, {
    required String message,
    String? title,
    IconData? icon,
    Color? color,
    VoidCallback? onRetry,
    VoidCallback? onDismiss,
    bool showRetryButton = false,
    bool showDismissButton = true,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ErrorDialog(
        message: message,
        title: title,
        icon: icon,
        color: color,
        onRetry: onRetry,
        onDismiss: onDismiss,
        showRetryButton: showRetryButton,
        showDismissButton: showDismissButton,
      ),
    );
  }

  /// Exibe o diálogo de erro a partir de uma AppException
  static Future<void> showFromException(
    BuildContext context,
    AppException exception, {
    VoidCallback? onRetry,
    VoidCallback? onDismiss,
    bool showRetryButton = false,
    bool showDismissButton = true,
  }) {
    return show(
      context,
      message: exception.displayMessage,
      title: _getErrorTitle(exception.type),
      icon: exception.icon,
      color: exception.color,
      onRetry: onRetry,
      onDismiss: onDismiss,
      showRetryButton: showRetryButton || exception.isRetryable,
      showDismissButton: showDismissButton,
    );
  }

  /// Retorna o título do erro baseado no tipo
  static String _getErrorTitle(ExceptionType type) {
    switch (type) {
      case ExceptionType.networkError:
      case ExceptionType.timeoutError:
      case ExceptionType.connectionError:
        return 'Erro de Conexão';
      case ExceptionType.authenticationError:
      case ExceptionType.authorizationError:
      case ExceptionType.sessionExpired:
        return 'Erro de Autenticação';
      case ExceptionType.dataNotFound:
        return 'Item Não Encontrado';
      case ExceptionType.validationError:
        return 'Dados Inválidos';
      case ExceptionType.insufficientStock:
        return 'Estoque Insuficiente';
      case ExceptionType.paymentError:
        return 'Erro no Pagamento';
      case ExceptionType.firebaseError:
      case ExceptionType.firestoreError:
      case ExceptionType.storageError:
        return 'Erro do Sistema';
      default:
        return 'Erro';
    }
  }
} 