import 'package:flutter/material.dart';
import 'responsive_breakpoints.dart';

/// Layout otimizado para tablets
class TabletLayout {
  /// Padding adaptativo para tablets
  static EdgeInsets getAdaptivePadding(BuildContext context) {
    if (ResponsiveBreakpoints.isTablet(context)) {
      return const EdgeInsets.all(24.0);
    }
    return const EdgeInsets.all(16.0);
  }

  /// Margem adaptativa para tablets
  static EdgeInsets getAdaptiveMargin(BuildContext context) {
    if (ResponsiveBreakpoints.isTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0);
    }
    return const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0);
  }

  /// Espaçamento adaptativo
  static double getAdaptiveSpacing(BuildContext context) {
    if (ResponsiveBreakpoints.isTablet(context)) {
      return 24.0;
    }
    return 16.0;
  }

  /// Tamanho de fonte adaptativo
  static double getAdaptiveFontSize(BuildContext context, double baseSize) {
    if (ResponsiveBreakpoints.isTablet(context)) {
      return baseSize * 1.2; // 20% maior em tablets
    }
    return baseSize;
  }

  /// Largura máxima para conteúdo
  static double getMaxContentWidth(BuildContext context) {
    if (ResponsiveBreakpoints.isTablet(context)) {
      return 800.0; // Largura máxima para tablets
    }
    return double.infinity; // Sem limite em mobile
  }

  /// Número de colunas para grid
  static int getGridColumns(BuildContext context) {
    if (ResponsiveBreakpoints.isLargeTablet(context)) {
      return 3; // 3 colunas em tablets grandes
    } else if (ResponsiveBreakpoints.isTablet(context)) {
      return 2; // 2 colunas em tablets
    }
    return 1; // 1 coluna em mobile
  }

  /// Largura de card adaptativa
  static double getCardWidth(BuildContext context) {
    if (ResponsiveBreakpoints.isTablet(context)) {
      return 300.0; // Cards mais largos em tablets
    }
    return double.infinity; // Largura total em mobile
  }

  /// Altura de card adaptativa
  static double getCardHeight(BuildContext context) {
    if (ResponsiveBreakpoints.isTablet(context)) {
      return 400.0; // Cards mais altos em tablets
    }
    return 350.0; // Altura padrão em mobile
  }

  /// Tamanho de ícone adaptativo
  static double getIconSize(BuildContext context, double baseSize) {
    if (ResponsiveBreakpoints.isTablet(context)) {
      return baseSize * 1.3; // 30% maior em tablets
    }
    return baseSize;
  }

  /// Tamanho de botão adaptativo
  static Size getButtonSize(BuildContext context) {
    if (ResponsiveBreakpoints.isTablet(context)) {
      return const Size(200, 56); // Botões maiores em tablets
    }
    return const Size(double.infinity, 48); // Tamanho padrão em mobile
  }

  /// Padding de botão adaptativo
  static EdgeInsets getButtonPadding(BuildContext context) {
    if (ResponsiveBreakpoints.isTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 32, vertical: 16);
    }
    return const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
  }

  /// Border radius adaptativo
  static double getBorderRadius(BuildContext context) {
    if (ResponsiveBreakpoints.isTablet(context)) {
      return 16.0; // Border radius maior em tablets
    }
    return 12.0; // Border radius padrão em mobile
  }

  /// Elevação adaptativa
  static double getElevation(BuildContext context) {
    if (ResponsiveBreakpoints.isTablet(context)) {
      return 8.0; // Elevação maior em tablets
    }
    return 4.0; // Elevação padrão em mobile
  }

  /// Largura de sidebar (se aplicável)
  static double getSidebarWidth(BuildContext context) {
    if (ResponsiveBreakpoints.isTablet(context)) {
      return 280.0; // Sidebar em tablets
    }
    return 0.0; // Sem sidebar em mobile
  }

  /// Largura de drawer
  static double getDrawerWidth(BuildContext context) {
    if (ResponsiveBreakpoints.isTablet(context)) {
      return 320.0; // Drawer mais largo em tablets
    }
    return 280.0; // Drawer padrão em mobile
  }

  /// Tamanho de avatar adaptativo
  static double getAvatarSize(BuildContext context) {
    if (ResponsiveBreakpoints.isTablet(context)) {
      return 80.0; // Avatar maior em tablets
    }
    return 60.0; // Avatar padrão em mobile
  }

  /// Tamanho de thumbnail adaptativo
  static double getThumbnailSize(BuildContext context) {
    if (ResponsiveBreakpoints.isTablet(context)) {
      return 120.0; // Thumbnail maior em tablets
    }
    return 100.0; // Thumbnail padrão em mobile
  }

  /// Largura de input adaptativa
  static double getInputWidth(BuildContext context) {
    if (ResponsiveBreakpoints.isTablet(context)) {
      return 400.0; // Inputs mais largos em tablets
    }
    return double.infinity; // Largura total em mobile
  }

  /// Altura de input adaptativa
  static double getInputHeight(BuildContext context) {
    if (ResponsiveBreakpoints.isTablet(context)) {
      return 56.0; // Inputs mais altos em tablets
    }
    return 48.0; // Altura padrão em mobile
  }

  /// Tamanho de chip adaptativo
  static double getChipHeight(BuildContext context) {
    if (ResponsiveBreakpoints.isTablet(context)) {
      return 40.0; // Chips mais altos em tablets
    }
    return 32.0; // Altura padrão em mobile
  }

  /// Padding de chip adaptativo
  static EdgeInsets getChipPadding(BuildContext context) {
    if (ResponsiveBreakpoints.isTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
    }
    return const EdgeInsets.symmetric(horizontal: 12, vertical: 6);
  }

  /// Tamanho de badge adaptativo
  static double getBadgeSize(BuildContext context) {
    if (ResponsiveBreakpoints.isTablet(context)) {
      return 24.0; // Badges maiores em tablets
    }
    return 20.0; // Tamanho padrão em mobile
  }

  /// Largura de modal adaptativa
  static double getModalWidth(BuildContext context) {
    if (ResponsiveBreakpoints.isTablet(context)) {
      return 600.0; // Modais mais largos em tablets
    }
    return double.infinity; // Largura total em mobile
  }

  /// Altura de modal adaptativa
  static double getModalHeight(BuildContext context) {
    if (ResponsiveBreakpoints.isTablet(context)) {
      return 500.0; // Modais mais altos em tablets
    }
    return 400.0; // Altura padrão em mobile
  }

  /// Padding de modal adaptativo
  static EdgeInsets getModalPadding(BuildContext context) {
    if (ResponsiveBreakpoints.isTablet(context)) {
      return const EdgeInsets.all(32.0);
    }
    return const EdgeInsets.all(24.0);
  }

  /// Tamanho de loading adaptativo
  static double getLoadingSize(BuildContext context) {
    if (ResponsiveBreakpoints.isTablet(context)) {
      return 48.0; // Loading maior em tablets
    }
    return 32.0; // Tamanho padrão em mobile
  }

  /// Largura de progress bar adaptativa
  static double getProgressBarWidth(BuildContext context) {
    if (ResponsiveBreakpoints.isTablet(context)) {
      return 400.0; // Progress bar mais larga em tablets
    }
    return double.infinity; // Largura total em mobile
  }

  /// Altura de progress bar adaptativa
  static double getProgressBarHeight(BuildContext context) {
    if (ResponsiveBreakpoints.isTablet(context)) {
      return 8.0; // Progress bar mais alta em tablets
    }
    return 4.0; // Altura padrão em mobile
  }
}

/// Widget para aplicar layout responsivo
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (ResponsiveBreakpoints.isDesktop(context) && desktop != null) {
          return desktop!;
        } else if (ResponsiveBreakpoints.isTablet(context) && tablet != null) {
          return tablet!;
        } else {
          return mobile;
        }
      },
    );
  }
}

/// Widget para aplicar padding responsivo
class ResponsivePadding extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;

  const ResponsivePadding({
    super.key,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? TabletLayout.getAdaptivePadding(context),
      child: child,
    );
  }
}

/// Widget para aplicar margin responsiva
class ResponsiveMargin extends StatelessWidget {
  final Widget child;
  final EdgeInsets? margin;

  const ResponsiveMargin({
    super.key,
    required this.child,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? TabletLayout.getAdaptiveMargin(context),
      child: child,
    );
  }
}

/// Widget para aplicar spacing responsivo
class ResponsiveSpacing extends StatelessWidget {
  final Widget child;
  final double? spacing;

  const ResponsiveSpacing({
    super.key,
    required this.child,
    this.spacing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(spacing ?? TabletLayout.getAdaptiveSpacing(context)),
      child: child,
    );
  }
} 