import 'package:flutter/material.dart';

// Imports das classes internas

/// Sistema de pull-to-refresh padronizado
class PullToRefreshWidget {
  /// Configuração padrão do RefreshIndicator
  static const Color defaultColor = Color(0xFF64ba01);
  static const Color defaultBackgroundColor = Colors.white;
  static const double defaultStrokeWidth = 2.0;
  static const Duration defaultDuration = Duration(milliseconds: 800);

  /// Cria um RefreshIndicator padronizado
  static RefreshIndicator create({
    required Future<void> Function() onRefresh,
    required Widget child,
    Color? color,
    Color? backgroundColor,
    double? strokeWidth,
    Duration? duration,
    String? message,
    bool showMessage = true,
  }) {
    return RefreshIndicator(
      onRefresh: () async {
        try {
          await onRefresh();
          if (showMessage) {
            // Mensagem de sucesso será mostrada pelo callback
          }
        } catch (e) {
          // Erro será tratado pelo callback
          rethrow;
        }
      },
      color: color ?? defaultColor,
      backgroundColor: backgroundColor ?? defaultBackgroundColor,
      strokeWidth: strokeWidth ?? defaultStrokeWidth,
      child: child,
    );
  }

  /// Cria um RefreshIndicator com loading customizado
  static RefreshIndicator createCustom({
    required Future<void> Function() onRefresh,
    required Widget child,
    Widget? loadingWidget,
    String? loadingMessage,
    Color? color,
    Color? backgroundColor,
  }) {
    return RefreshIndicator(
      onRefresh: () async {
        try {
          await onRefresh();
        } catch (e) {
          rethrow;
        }
      },
      color: color ?? defaultColor,
      backgroundColor: backgroundColor ?? defaultBackgroundColor,
      child: child,
    );
  }

  /// Cria um RefreshIndicator com feedback visual
  static RefreshIndicator createWithFeedback({
    required Future<void> Function() onRefresh,
    required Widget child,
    required BuildContext context,
    String? successMessage,
    String? errorMessage,
    Color? color,
    Color? backgroundColor,
  }) {
    return RefreshIndicator(
      onRefresh: () async {
        try {
          await onRefresh();
          if (successMessage != null && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(successMessage)),
            );
          }
        } catch (e) {
          if (errorMessage != null && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errorMessage),
                backgroundColor: Colors.red,
              ),
            );
          } else if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Erro ao atualizar dados'),
                backgroundColor: Colors.red,
              ),
            );
          }
          rethrow;
        }
      },
      color: color ?? defaultColor,
      backgroundColor: backgroundColor ?? defaultBackgroundColor,
      child: child,
    );
  }

  /// Cria um RefreshIndicator para listas específicas
  static RefreshIndicator forProducts({
    required Future<void> Function() onRefresh,
    required Widget child,
    required BuildContext context,
  }) {
    return createWithFeedback(
      onRefresh: onRefresh,
      child: child,
      context: context,
      successMessage: 'Produtos atualizados com sucesso!',
      errorMessage: 'Erro de conexão. Verifique sua internet.',
    );
  }

  /// Cria um RefreshIndicator para pedidos
  static RefreshIndicator forOrders({
    required Future<void> Function() onRefresh,
    required Widget child,
    required BuildContext context,
  }) {
    return createWithFeedback(
      onRefresh: onRefresh,
      child: child,
      context: context,
      successMessage: 'Pedidos atualizados com sucesso!',
      errorMessage: 'Erro de conexão. Verifique sua internet.',
    );
  }

  /// Cria um RefreshIndicator para perfil
  static RefreshIndicator forProfile({
    required Future<void> Function() onRefresh,
    required Widget child,
    required BuildContext context,
  }) {
    return createWithFeedback(
      onRefresh: onRefresh,
      child: child,
      context: context,
      successMessage: 'Perfil atualizado com sucesso!',
      errorMessage: 'Erro de conexão. Verifique sua internet.',
    );
  }

  /// Cria um RefreshIndicator para endereços
  static RefreshIndicator forAddresses({
    required Future<void> Function() onRefresh,
    required Widget child,
    required BuildContext context,
  }) {
    return createWithFeedback(
      onRefresh: onRefresh,
      child: child,
      context: context,
      successMessage: 'Endereços atualizados com sucesso!',
      errorMessage: 'Erro de conexão. Verifique sua internet.',
    );
  }

  /// Cria um RefreshIndicator para carrinho
  static RefreshIndicator forCart({
    required Future<void> Function() onRefresh,
    required Widget child,
    required BuildContext context,
  }) {
    return createWithFeedback(
      onRefresh: onRefresh,
      child: child,
      context: context,
      successMessage: 'Carrinho atualizado com sucesso!',
      errorMessage: 'Erro de conexão. Verifique sua internet.',
    );
  }
}

/// Widget wrapper para pull-to-refresh
class PullToRefreshWrapper extends StatelessWidget {
  final Future<void> Function() onRefresh;
  final Widget child;
  final Color? color;
  final Color? backgroundColor;
  final double? strokeWidth;
  final String? successMessage;
  final String? errorMessage;
  final bool showFeedback;

  const PullToRefreshWrapper({
    super.key,
    required this.onRefresh,
    required this.child,
    this.color,
    this.backgroundColor,
    this.strokeWidth,
    this.successMessage,
    this.errorMessage,
    this.showFeedback = true,
  });

  @override
  Widget build(BuildContext context) {
    if (showFeedback) {
      return PullToRefreshWidget.createWithFeedback(
        onRefresh: onRefresh,
        child: child,
        context: context,
        successMessage: successMessage,
        errorMessage: errorMessage,
        color: color,
        backgroundColor: backgroundColor,
      );
    } else {
      return PullToRefreshWidget.create(
        onRefresh: onRefresh,
        child: child,
        color: color,
        backgroundColor: backgroundColor,
        strokeWidth: strokeWidth,
      );
    }
  }
}

/// Widget para pull-to-refresh com scroll customizado
class CustomPullToRefresh extends StatefulWidget {
  final Future<void> Function() onRefresh;
  final Widget child;
  final Color? color;
  final Color? backgroundColor;
  final double? strokeWidth;
  final String? loadingMessage;
  final bool showLoadingMessage;

  const CustomPullToRefresh({
    super.key,
    required this.onRefresh,
    required this.child,
    this.color,
    this.backgroundColor,
    this.strokeWidth,
    this.loadingMessage,
    this.showLoadingMessage = true,
  });

  @override
  State<CustomPullToRefresh> createState() => _CustomPullToRefreshState();
}

class _CustomPullToRefreshState extends State<CustomPullToRefresh> {
  bool _isRefreshing = false;

  Future<void> _handleRefresh() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    try {
      await widget.onRefresh();
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: widget.color ?? PullToRefreshWidget.defaultColor,
      backgroundColor: widget.backgroundColor ?? PullToRefreshWidget.defaultBackgroundColor,
      strokeWidth: widget.strokeWidth ?? PullToRefreshWidget.defaultStrokeWidth,
      child: Stack(
        children: [
          widget.child,
          if (_isRefreshing && widget.showLoadingMessage)
            Positioned(
              top: 100,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.loadingMessage ?? 'Atualizando...',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Widget para pull-to-refresh com indicador customizado
class CustomRefreshIndicator extends StatelessWidget {
  final Future<void> Function() onRefresh;
  final Widget child;
  final Widget? indicator;
  final Color? color;
  final Color? backgroundColor;

  const CustomRefreshIndicator({
    super.key,
    required this.onRefresh,
    required this.child,
    this.indicator,
    this.color,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: color ?? PullToRefreshWidget.defaultColor,
      backgroundColor: backgroundColor ?? PullToRefreshWidget.defaultBackgroundColor,
      child: child,
    );
  }
}

/// Mixin para adicionar funcionalidade de pull-to-refresh
mixin PullToRefreshMixin<T extends StatefulWidget> on State<T> {
  Future<void> onRefresh() async {
    // Implementação padrão - deve ser sobrescrita
    await Future.delayed(const Duration(milliseconds: 1000));
  }

  RefreshIndicator buildRefreshIndicator(Widget child) {
    return PullToRefreshWidget.create(
      onRefresh: onRefresh,
      child: child,
    );
  }

  RefreshIndicator buildRefreshIndicatorWithFeedback(
    Widget child,
    String? successMessage,
    String? errorMessage,
  ) {
    return PullToRefreshWidget.createWithFeedback(
      onRefresh: onRefresh,
      child: child,
      context: context,
      successMessage: successMessage,
      errorMessage: errorMessage,
    );
  }
}