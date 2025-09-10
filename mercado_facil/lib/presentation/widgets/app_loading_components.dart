import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Componente de loading indicador principal
class AppLoadingIndicator extends StatelessWidget {
  final String? message;
  final double size;
  final Color? color;

  const AppLoadingIndicator({
    super.key,
    this.message,
    this.size = 24.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              strokeWidth: 2.0,
              valueColor: AlwaysStoppedAnimation<Color>(
                color ?? AppTheme.produtoButtonColor,
              ),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// Componente de shimmer loading
class AppShimmerLoading extends StatefulWidget {
  final double height;
  final double width;
  final double borderRadius;

  const AppShimmerLoading({
    super.key,
    this.height = 20.0,
    this.width = double.infinity,
    this.borderRadius = 4.0,
  });

  @override
  State<AppShimmerLoading> createState() => _AppShimmerLoadingState();
}

class _AppShimmerLoadingState extends State<AppShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          height: widget.height,
          width: widget.width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.grey.shade300,
                Colors.grey.shade100,
                Colors.grey.shade300,
              ],
              stops: [
                _animation.value - 0.3,
                _animation.value,
                _animation.value + 0.3,
              ].map((e) => e.clamp(0.0, 1.0)).toList(),
            ),
          ),
        );
      },
    );
  }
}

/// Componente de skeleton card
class AppSkeletonCard extends StatelessWidget {
  final bool showImage;
  final double height;
  final double imageHeight;

  const AppSkeletonCard({
    super.key,
    this.showImage = true,
    this.height = 280.0,
    this.imageHeight = 120.0,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        height: height,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showImage) ...[
              AppShimmerLoading(
                height: imageHeight,
                width: double.infinity,
                borderRadius: 8,
              ),
              const SizedBox(height: 16),
            ],
            AppShimmerLoading(height: 16, width: double.infinity),
            const SizedBox(height: 8),
            AppShimmerLoading(height: 16, width: 120),
            const SizedBox(height: 12),
            AppShimmerLoading(height: 20, width: 80),
            const SizedBox(height: 16),
            AppShimmerLoading(height: 40, width: double.infinity, borderRadius: 8),
          ],
        ),
      ),
    );
  }
}

/// Componente de skeleton grid
class AppSkeletonGrid extends StatelessWidget {
  final int crossAxisCount;
  final int itemCount;
  final double childAspectRatio;

  const AppSkeletonGrid({
    super.key,
    this.crossAxisCount = 2,
    this.itemCount = 6,
    this.childAspectRatio = 0.8,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) => const AppSkeletonCard(),
    );
  }
}

/// Componente de skeleton list
class AppSkeletonList extends StatelessWidget {
  final int itemCount;
  final double itemHeight;

  const AppSkeletonList({
    super.key,
    this.itemCount = 5,
    this.itemHeight = 80.0,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Container(
          height: itemHeight,
          margin: const EdgeInsets.only(bottom: 16),
          child: const AppShimmerLoading(),
        );
      },
    );
  }
}

/// Componente de loading overlay
class AppLoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;
  final Color? backgroundColor;
  final double opacity;

  const AppLoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
    this.backgroundColor,
    this.opacity = 0.7,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: (backgroundColor ?? Colors.black).withValues(alpha: opacity),
            child: Center(
              child: AppLoadingIndicator(
                message: message,
                size: 32.0,
              ),
            ),
          ),
      ],
    );
  }
}

/// Componente de pull to refresh
class AppPullToRefresh extends StatelessWidget {
  final Future<void> Function() onRefresh;
  final Widget child;
  final String? message;
  final Color? color;

  const AppPullToRefresh({
    super.key,
    required this.onRefresh,
    required this.child,
    this.message,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: color ?? AppTheme.produtoButtonColor,
      child: child,
    );
  }
}

/// Componente de transição wrapper
class AppTransitionWrapper extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final bool enabled;

  const AppTransitionWrapper({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
    this.enabled = true,
  });

  @override
  State<AppTransitionWrapper> createState() => _AppTransitionWrapperState();
}

class _AppTransitionWrapperState extends State<AppTransitionWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));
    
    if (widget.enabled) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - _animation.value)),
            child: widget.child,
          ),
        );
      },
    );
  }
}