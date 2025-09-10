import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

export 'app_loading_components.dart';

/// Componentes de loading padronizados para o app
class LoadingComponents {
  /// Loading circular padrão
  static Widget circular({
    double size = 24.0,
    Color? color,
    double strokeWidth = 2.0,
  }) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? AppTheme.produtoButtonColor,
        ),
      ),
    );
  }

  /// Loading linear (barra de progresso)
  static Widget linear({
    double? value,
    Color? backgroundColor,
    Color? valueColor,
    double height = 4.0,
  }) {
    return LinearProgressIndicator(
      value: value,
      backgroundColor: backgroundColor ?? Colors.grey.shade300,
      valueColor: AlwaysStoppedAnimation<Color>(
        valueColor ?? AppTheme.produtoButtonColor,
      ),
      minHeight: height,
    );
  }

  /// Loading com mensagem
  static Widget withMessage({
    required String message,
    double size = 24.0,
    Color? color,
    TextStyle? textStyle,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        circular(size: size, color: color),
        const SizedBox(height: 16),
        Text(
          message,
          style: textStyle ?? const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Loading de botão
  static Widget button({
    double size = 16.0,
    Color? color,
  }) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 2.0,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? Colors.white,
        ),
      ),
    );
  }

  /// Loading de página completa
  static Widget page({
    String? message,
    Color? backgroundColor,
  }) {
    return Container(
      color: backgroundColor ?? Colors.white,
      child: Center(
        child: withMessage(
          message: message ?? 'Carregando...',
          size: 32.0,
        ),
      ),
    );
  }

  /// Loading de card
  static Widget card({
    String? message,
    double height = 200.0,
  }) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Center(
        child: withMessage(
          message: message ?? 'Carregando...',
          size: 24.0,
        ),
      ),
    );
  }

  /// Loading de lista
  static Widget list({
    int itemCount = 3,
    double itemHeight = 80.0,
  }) {
    return ListView.builder(
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Container(
          height: itemHeight,
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }

  /// Loading de grid
  static Widget grid({
    int crossAxisCount = 2,
    int itemCount = 6,
    double childAspectRatio = 0.8,
  }) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }

  /// Loading de overlay
  static Widget overlay({
    required bool isLoading,
    String? message,
    Color? backgroundColor,
    double opacity = 0.7,
  }) {
    if (!isLoading) return const SizedBox.shrink();

    return Container(
      color: (backgroundColor ?? Colors.black).withValues(alpha: opacity),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: withMessage(
            message: message ?? 'Carregando...',
            size: 32.0,
          ),
        ),
      ),
    );
  }

  /// Loading de pull-to-refresh
  static Widget pullToRefresh({
    String? message,
    Color? color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        circular(size: 20.0, color: color),
        if (message != null) ...[
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ],
    );
  }

  /// Loading de skeleton para texto
  static Widget textSkeleton({
    double height = 16.0,
    double width = double.infinity,
    double borderRadius = 4.0,
  }) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }

  /// Loading de skeleton para imagem
  static Widget imageSkeleton({
    double height = 120.0,
    double width = double.infinity,
    double borderRadius = 8.0,
  }) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }

  /// Loading de skeleton para botão
  static Widget buttonSkeleton({
    double height = 48.0,
    double width = double.infinity,
    double borderRadius = 8.0,
  }) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// Widget wrapper para loading
class LoadingWrapper extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final Widget? loadingWidget;
  final String? loadingMessage;

  const LoadingWrapper({
    super.key,
    required this.isLoading,
    required this.child,
    this.loadingWidget,
    this.loadingMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return loadingWidget ?? 
        LoadingComponents.page(message: loadingMessage);
    }
    return child;
  }
}

/// Widget para loading de operações assíncronas
class AsyncLoadingWidget<T> extends StatelessWidget {
  final Future<T> future;
  final Widget Function(T data) builder;
  final Widget? loadingWidget;
  final Widget? errorWidget;
  final String? loadingMessage;

  const AsyncLoadingWidget({
    super.key,
    required this.future,
    required this.builder,
    this.loadingWidget,
    this.errorWidget,
    this.loadingMessage,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loadingWidget ?? 
            LoadingComponents.page(message: loadingMessage);
        }
        
        if (snapshot.hasError) {
          return errorWidget ?? 
            const Center(
              child: Text('Erro ao carregar dados'),
            );
        }
        
        if (snapshot.hasData) {
          return snapshot.data != null ? builder(snapshot.data as T) : errorWidget ?? const SizedBox.shrink();
        }
        
        return const Center(
          child: Text('Nenhum dado encontrado'),
        );
      },
    );
  }
}