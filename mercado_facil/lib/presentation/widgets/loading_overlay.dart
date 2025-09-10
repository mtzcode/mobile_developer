import 'package:flutter/material.dart';

/// Widget para exibir overlay de loading global
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final String? message;
  final Color? backgroundColor;
  final Color? indicatorColor;
  final double opacity;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    this.message,
    this.backgroundColor,
    this.indicatorColor,
    this.opacity = 0.7,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLoading) return const SizedBox.shrink();

    return Container(
      color: (backgroundColor ?? Colors.black).withValues(alpha: opacity),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: indicatorColor ?? Theme.of(context).colorScheme.primary,
                strokeWidth: 3,
              ),
              if (message != null) ...[
                const SizedBox(height: 16),
                Text(
                  message!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Exibe o overlay de loading
  static void show(
    BuildContext context, {
    String? message,
    Color? backgroundColor,
    Color? indicatorColor,
    double opacity = 0.7,
  }) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => LoadingOverlay(
        isLoading: true,
        message: message,
        backgroundColor: backgroundColor,
        indicatorColor: indicatorColor,
        opacity: opacity,
      ),
    );
  }

  /// Esconde o overlay de loading
  static void hide(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }
}

/// Widget wrapper que adiciona loading overlay
class LoadingWrapper extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? loadingMessage;
  final Color? backgroundColor;
  final Color? indicatorColor;
  final double opacity;

  const LoadingWrapper({
    super.key,
    required this.isLoading,
    required this.child,
    this.loadingMessage,
    this.backgroundColor,
    this.indicatorColor,
    this.opacity = 0.7,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        LoadingOverlay(
          isLoading: isLoading,
          message: loadingMessage,
          backgroundColor: backgroundColor,
          indicatorColor: indicatorColor,
          opacity: opacity,
        ),
      ],
    );
  }
}