import 'package:flutter/material.dart';

/// Sistema de animações de transição padronizadas
class TransitionAnimations {
  /// Duração padrão das animações
  static const Duration defaultDuration = Duration(milliseconds: 300);
  static const Duration fastDuration = Duration(milliseconds: 200);
  static const Duration slowDuration = Duration(milliseconds: 500);

  /// Curva padrão das animações
  static const Curve defaultCurve = Curves.easeInOut;
  static const Curve bounceCurve = Curves.elasticOut;
  static const Curve slideCurve = Curves.easeOutCubic;

  /// Animação de fade in
  static Widget fadeIn({
    required Widget child,
    Duration duration = defaultDuration,
    Curve curve = defaultCurve,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      curve: curve,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: child,
        );
      },
      child: child,
    );
  }

  /// Animação de fade out
  static Widget fadeOut({
    required Widget child,
    Duration duration = defaultDuration,
    Curve curve = defaultCurve,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      curve: curve,
      tween: Tween(begin: 1.0, end: 0.0),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: child,
        );
      },
      child: child,
    );
  }

  /// Animação de slide in da esquerda
  static Widget slideInLeft({
    required Widget child,
    Duration duration = defaultDuration,
    Curve curve = slideCurve,
    double distance = 100.0,
  }) {
    return TweenAnimationBuilder<Offset>(
      duration: duration,
      curve: curve,
      tween: Tween(begin: Offset(-distance, 0), end: Offset.zero),
      builder: (context, value, child) {
        return Transform.translate(
          offset: value,
          child: child,
        );
      },
      child: child,
    );
  }

  /// Animação de slide in da direita
  static Widget slideInRight({
    required Widget child,
    Duration duration = defaultDuration,
    Curve curve = slideCurve,
    double distance = 100.0,
  }) {
    return TweenAnimationBuilder<Offset>(
      duration: duration,
      curve: curve,
      tween: Tween(begin: Offset(distance, 0), end: Offset.zero),
      builder: (context, value, child) {
        return Transform.translate(
          offset: value,
          child: child,
        );
      },
      child: child,
    );
  }

  /// Animação de slide in de baixo
  static Widget slideInBottom({
    required Widget child,
    Duration duration = defaultDuration,
    Curve curve = slideCurve,
    double distance = 100.0,
  }) {
    return TweenAnimationBuilder<Offset>(
      duration: duration,
      curve: curve,
      tween: Tween(begin: Offset(0, distance), end: Offset.zero),
      builder: (context, value, child) {
        return Transform.translate(
          offset: value,
          child: child,
        );
      },
      child: child,
    );
  }

  /// Animação de slide in de cima
  static Widget slideInTop({
    required Widget child,
    Duration duration = defaultDuration,
    Curve curve = slideCurve,
    double distance = 100.0,
  }) {
    return TweenAnimationBuilder<Offset>(
      duration: duration,
      curve: curve,
      tween: Tween(begin: Offset(0, -distance), end: Offset.zero),
      builder: (context, value, child) {
        return Transform.translate(
          offset: value,
          child: child,
        );
      },
      child: child,
    );
  }

  /// Animação de scale in
  static Widget scaleIn({
    required Widget child,
    Duration duration = defaultDuration,
    Curve curve = defaultCurve,
    double beginScale = 0.0,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      curve: curve,
      tween: Tween(begin: beginScale, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: child,
    );
  }

  /// Animação de scale out
  static Widget scaleOut({
    required Widget child,
    Duration duration = defaultDuration,
    Curve curve = defaultCurve,
    double endScale = 0.0,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      curve: curve,
      tween: Tween(begin: 1.0, end: endScale),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: child,
    );
  }

  /// Animação de bounce
  static Widget bounce({
    required Widget child,
    Duration duration = defaultDuration,
    Curve curve = bounceCurve,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      curve: curve,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: child,
    );
  }

  /// Animação de rotação
  static Widget rotate({
    required Widget child,
    Duration duration = defaultDuration,
    Curve curve = defaultCurve,
    double beginAngle = 0.0,
    double endAngle = 360.0,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      curve: curve,
      tween: Tween(begin: beginAngle, end: endAngle),
      builder: (context, value, child) {
        return Transform.rotate(
          angle: value * 3.14159 / 180,
          child: child,
        );
      },
      child: child,
    );
  }

  /// Animação de loading rotativo
  static Widget loadingRotate({
    required Widget child,
    Duration duration = const Duration(seconds: 1),
    bool repeat = true,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.rotate(
          angle: value * 2 * 3.14159,
          child: child,
        );
      },
      child: child,
    );
  }

  /// Animação de pulse
  static Widget pulse({
    required Widget child,
    Duration duration = defaultDuration,
    Curve curve = Curves.easeInOut,
    double minScale = 0.95,
    double maxScale = 1.05,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      curve: curve,
      tween: Tween(begin: minScale, end: maxScale),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: child,
    );
  }

  /// Animação de shimmer (efeito de brilho)
  static Widget shimmer({
    required Widget child,
    Duration duration = const Duration(milliseconds: 1500),
    Color shimmerColor = Colors.white,
    double opacity = 0.3,
  }) {
    return ShaderMask(
      shaderCallback: (bounds) {
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.transparent,
            shimmerColor.withValues(alpha: opacity),
            Colors.transparent,
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(bounds);
      },
      child: child,
    );
  }

  /// Animação de entrada sequencial para lista
  static Widget staggeredList({
    required List<Widget> children,
    Duration itemDuration = const Duration(milliseconds: 200),
    Duration staggerDuration = const Duration(milliseconds: 100),
  }) {
    return Column(
      children: children.asMap().entries.map((entry) {
        final index = entry.key;
        final child = entry.value;
        
        return TweenAnimationBuilder<double>(
          duration: Duration(
            milliseconds: itemDuration.inMilliseconds + 
                         (index * staggerDuration.inMilliseconds),
          ),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: child,
              ),
            );
          },
          child: child,
        );
      }).toList(),
    );
  }

  /// Animação de entrada para grid
  static Widget staggeredGrid({
    required List<Widget> children,
    int crossAxisCount = 2,
    Duration itemDuration = const Duration(milliseconds: 200),
    Duration staggerDuration = const Duration(milliseconds: 50),
  }) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) {
        final child = children[index];
        
        return TweenAnimationBuilder<double>(
          duration: Duration(
            milliseconds: itemDuration.inMilliseconds + 
                         (index * staggerDuration.inMilliseconds),
          ),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.scale(
                scale: 0.8 + (0.2 * value),
                child: child,
              ),
            );
          },
          child: child,
        );
      },
    );
  }

  /// Animação de transição de página
  static PageRouteBuilder<T> pageTransition<T>({
    required Widget page,
    RouteSettings? settings,
    Duration duration = defaultDuration,
    Curve curve = defaultCurve,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  /// Animação de transição de modal
  static PageRouteBuilder<T> modalTransition<T>({
    required Widget page,
    RouteSettings? settings,
    Duration duration = defaultDuration,
    Curve curve = defaultCurve,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: curve,
          )),
          child: child,
        );
      },
    );
  }
}

/// Widget wrapper para animações
class AnimatedWrapper extends StatefulWidget {
  final Widget child;
  final bool animate;
  final Widget Function(Widget child) animationBuilder;
  final Duration duration;
  final Curve curve;

  const AnimatedWrapper({
    super.key,
    required this.child,
    required this.animate,
    required this.animationBuilder,
    this.duration = TransitionAnimations.defaultDuration,
    this.curve = TransitionAnimations.defaultCurve,
  });

  @override
  State<AnimatedWrapper> createState() => _AnimatedWrapperState();
}

class _AnimatedWrapperState extends State<AnimatedWrapper>
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
    _animation = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );

    if (widget.animate) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(AnimatedWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate != oldWidget.animate) {
      if (widget.animate) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
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
        return widget.animationBuilder(widget.child);
      },
    );
  }
}