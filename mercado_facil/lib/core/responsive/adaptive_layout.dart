import 'package:flutter/material.dart';
import 'responsive_breakpoints.dart';
import 'tablet_layout.dart';
import 'dynamic_font_sizes.dart';

/// Sistema de layout adaptativo
class AdaptiveLayout {
  /// Layout adaptativo para containers
  static Widget adaptiveContainer({
    required BuildContext context,
    required Widget child,
    EdgeInsets? padding,
    EdgeInsets? margin,
    double? width,
    double? height,
    Color? color,
    Decoration? decoration,
    Alignment? alignment,
  }) {
    return Container(
      width: width ?? _getAdaptiveWidth(context),
      height: height,
      padding: padding ?? TabletLayout.getAdaptivePadding(context),
      margin: margin ?? TabletLayout.getAdaptiveMargin(context),
      color: color,
      decoration: decoration,
      alignment: alignment,
      child: child,
    );
  }

  /// Layout adaptativo para cards
  static Widget adaptiveCard({
    required BuildContext context,
    required Widget child,
    EdgeInsets? padding,
    EdgeInsets? margin,
    double? width,
    double? height,
    Color? color,
    double? elevation,
    ShapeBorder? shape,
  }) {
    return Card(
      margin: margin ?? TabletLayout.getAdaptiveMargin(context),
      color: color,
      elevation: elevation ?? TabletLayout.getElevation(context),
      shape: shape ?? RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          TabletLayout.getBorderRadius(context),
        ),
      ),
      child: Container(
        width: width ?? TabletLayout.getCardWidth(context),
        height: height ?? TabletLayout.getCardHeight(context),
        padding: padding ?? TabletLayout.getAdaptivePadding(context),
        child: child,
      ),
    );
  }

  /// Layout adaptativo para botões
  static Widget adaptiveButton({
    required BuildContext context,
    required Widget child,
    required VoidCallback? onPressed,
    EdgeInsets? padding,
    double? width,
    double? height,
    ButtonStyle? style,
  }) {
    final buttonSize = TabletLayout.getButtonSize(context);
    final buttonPadding = TabletLayout.getButtonPadding(context);

    return SizedBox(
      width: width ?? buttonSize.width,
      height: height ?? buttonSize.height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: style ?? ElevatedButton.styleFrom(
          padding: padding ?? buttonPadding,
          textStyle: TextStyle(
            fontSize: DynamicFontSizes.getButtonText(context),
          ),
        ),
        child: child,
      ),
    );
  }

  /// Layout adaptativo para inputs
  static Widget adaptiveInput({
    required BuildContext context,
    required Widget child,
    EdgeInsets? padding,
    double? width,
    double? height,
    InputDecoration? decoration,
  }) {
    return Container(
      width: width ?? TabletLayout.getInputWidth(context),
      height: height ?? TabletLayout.getInputHeight(context),
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
      child: child,
    );
  }

  /// Layout adaptativo para grids
  static Widget adaptiveGrid({
    required BuildContext context,
    required List<Widget> children,
    EdgeInsets? padding,
    EdgeInsets? margin,
    double? spacing,
    double? runSpacing,
    int? crossAxisCount,
    double? childAspectRatio,
    double? mainAxisSpacing,
    double? crossAxisSpacing,
  }) {
    final columns = crossAxisCount ?? TabletLayout.getGridColumns(context);
    final gridSpacing = spacing ?? TabletLayout.getAdaptiveSpacing(context);

    return GridView.builder(
      padding: padding ?? TabletLayout.getAdaptivePadding(context),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        childAspectRatio: childAspectRatio ?? 0.75,
        mainAxisSpacing: mainAxisSpacing ?? gridSpacing,
        crossAxisSpacing: crossAxisSpacing ?? gridSpacing,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }

  /// Layout adaptativo para listas
  static Widget adaptiveList({
    required BuildContext context,
    required List<Widget> children,
    EdgeInsets? padding,
    EdgeInsets? margin,
    double? spacing,
    ScrollController? controller,
    bool shrinkWrap = false,
  }) {
    final listSpacing = spacing ?? TabletLayout.getAdaptiveSpacing(context);

    return ListView.separated(
      controller: controller,
      padding: padding ?? TabletLayout.getAdaptivePadding(context),
      shrinkWrap: shrinkWrap,
      itemCount: children.length,
      separatorBuilder: (context, index) => SizedBox(height: listSpacing),
      itemBuilder: (context, index) => children[index],
    );
  }

  /// Layout adaptativo para rows
  static Widget adaptiveRow({
    required BuildContext context,
    required List<Widget> children,
    MainAxisAlignment? mainAxisAlignment,
    CrossAxisAlignment? crossAxisAlignment,
    MainAxisSize? mainAxisSize,
    EdgeInsets? padding,
    double? spacing,
  }) {
    final rowSpacing = spacing ?? TabletLayout.getAdaptiveSpacing(context);

    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Row(
        mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.start,
        crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.center,
        mainAxisSize: mainAxisSize ?? MainAxisSize.max,
        children: _addSpacingBetweenChildren(children, rowSpacing),
      ),
    );
  }

  /// Layout adaptativo para columns
  static Widget adaptiveColumn({
    required BuildContext context,
    required List<Widget> children,
    MainAxisAlignment? mainAxisAlignment,
    CrossAxisAlignment? crossAxisAlignment,
    MainAxisSize? mainAxisSize,
    EdgeInsets? padding,
    double? spacing,
  }) {
    final columnSpacing = spacing ?? TabletLayout.getAdaptiveSpacing(context);

    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Column(
        mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.start,
        crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.start,
        mainAxisSize: mainAxisSize ?? MainAxisSize.max,
        children: _addSpacingBetweenChildren(children, columnSpacing),
      ),
    );
  }

  /// Layout adaptativo para sidebars
  static Widget adaptiveSidebar({
    required BuildContext context,
    required Widget child,
    double? width,
    EdgeInsets? padding,
    Color? color,
  }) {
    final sidebarWidth = width ?? TabletLayout.getSidebarWidth(context);
    
    if (sidebarWidth <= 0) {
      return const SizedBox.shrink(); // Não mostra sidebar em mobile
    }

    return Container(
      width: sidebarWidth,
      padding: padding ?? TabletLayout.getAdaptivePadding(context),
      color: color,
      child: child,
    );
  }

  /// Layout adaptativo para modais
  static Widget adaptiveModal({
    required BuildContext context,
    required Widget child,
    double? width,
    double? height,
    EdgeInsets? padding,
    Color? backgroundColor,
    double? elevation,
    ShapeBorder? shape,
  }) {
    return Dialog(
      backgroundColor: backgroundColor,
      elevation: elevation ?? TabletLayout.getElevation(context),
      shape: shape ?? RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          TabletLayout.getBorderRadius(context),
        ),
      ),
      child: Container(
        width: width ?? TabletLayout.getModalWidth(context),
        height: height ?? TabletLayout.getModalHeight(context),
        padding: padding ?? TabletLayout.getModalPadding(context),
        child: child,
      ),
    );
  }

  /// Layout adaptativo para chips
  static Widget adaptiveChip({
    required BuildContext context,
    required Widget child,
    EdgeInsets? padding,
    double? height,
    Color? backgroundColor,
    OutlinedBorder? shape,
  }) {
    return Chip(
      label: child,
      padding: padding ?? TabletLayout.getChipPadding(context),
      backgroundColor: backgroundColor,
      shape: shape ?? RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          TabletLayout.getBorderRadius(context),
        ),
      ),
    );
  }

  /// Layout adaptativo para badges
  static Widget adaptiveBadge({
    required BuildContext context,
    required Widget child,
    double? size,
    Color? backgroundColor,
    EdgeInsets? padding,
  }) {
    final badgeSize = size ?? TabletLayout.getBadgeSize(context);

    return Container(
      width: badgeSize,
      height: badgeSize,
      padding: padding ?? const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.red,
        shape: BoxShape.circle,
      ),
      child: child,
    );
  }

  /// Layout adaptativo para avatars
  static Widget adaptiveAvatar({
    required BuildContext context,
    required Widget child,
    double? size,
    Color? backgroundColor,
  }) {
    final avatarSize = size ?? TabletLayout.getAvatarSize(context);

    return CircleAvatar(
      radius: avatarSize / 2,
      backgroundColor: backgroundColor,
      child: child,
    );
  }

  /// Layout adaptativo para thumbnails
  static Widget adaptiveThumbnail({
    required BuildContext context,
    required Widget child,
    double? size,
    BoxFit? fit,
    BorderRadius? borderRadius,
  }) {
    final thumbnailSize = size ?? TabletLayout.getThumbnailSize(context);

    return Container(
      width: thumbnailSize,
      height: thumbnailSize,
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.circular(
          TabletLayout.getBorderRadius(context),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }

  /// Layout adaptativo para progress bars
  static Widget adaptiveProgressBar({
    required BuildContext context,
    required double value,
    double? width,
    double? height,
    Color? backgroundColor,
    Color? valueColor,
  }) {
    final progressWidth = width ?? TabletLayout.getProgressBarWidth(context);
    final progressHeight = height ?? TabletLayout.getProgressBarHeight(context);

    return Container(
      width: progressWidth,
      height: progressHeight,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.grey[300],
        borderRadius: BorderRadius.circular(progressHeight / 2),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: value.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            color: valueColor ?? Colors.blue,
            borderRadius: BorderRadius.circular(progressHeight / 2),
          ),
        ),
      ),
    );
  }

  /// Layout adaptativo para loading
  static Widget adaptiveLoading({
    required BuildContext context,
    double? size,
    Color? color,
    String? message,
  }) {
    final loadingSize = size ?? TabletLayout.getLoadingSize(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: loadingSize,
          height: loadingSize,
          child: CircularProgressIndicator(color: color),
        ),
        if (message != null) ...[
          SizedBox(height: TabletLayout.getAdaptiveSpacing(context)),
          DynamicText(
            text: message,
            baseSize: DynamicFontSizes.getBodyMedium(context),
          ),
        ],
      ],
    );
  }

  /// Layout adaptativo para espaçamento
  static Widget adaptiveSpacing({
    required BuildContext context,
    double? spacing,
    bool isVertical = true,
  }) {
    final adaptiveSpacing = spacing ?? TabletLayout.getAdaptiveSpacing(context);

    return isVertical
        ? SizedBox(height: adaptiveSpacing)
        : SizedBox(width: adaptiveSpacing);
  }

  /// Layout adaptativo para divisores
  static Widget adaptiveDivider({
    required BuildContext context,
    double? thickness,
    double? indent,
    double? endIndent,
    Color? color,
  }) {
    return Divider(
      thickness: thickness ?? 1,
      indent: indent ?? TabletLayout.getAdaptiveSpacing(context),
      endIndent: endIndent ?? TabletLayout.getAdaptiveSpacing(context),
      color: color,
    );
  }

  // Métodos auxiliares
  static double _getAdaptiveWidth(BuildContext context) {
    if (ResponsiveBreakpoints.isTablet(context)) {
      return TabletLayout.getMaxContentWidth(context);
    }
    return double.infinity;
  }

  static List<Widget> _addSpacingBetweenChildren(
    List<Widget> children, 
    double spacing,
  ) {
    if (children.isEmpty) return children;
    
    final result = <Widget>[];
    for (int i = 0; i < children.length; i++) {
      result.add(children[i]);
      if (i < children.length - 1) {
        result.add(SizedBox(height: spacing));
      }
    }
    return result;
  }
}

/// Widget para aplicar layout adaptativo automaticamente
class AdaptiveWidget extends StatelessWidget {
  final Widget child;
  final AdaptiveLayoutType type;
  final Map<String, dynamic>? properties;

  const AdaptiveWidget({
    super.key,
    required this.child,
    required this.type,
    this.properties,
  });

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case AdaptiveLayoutType.container:
        return AdaptiveLayout.adaptiveContainer(
          context: context,
          child: child,
          padding: properties?['padding'],
          margin: properties?['margin'],
          width: properties?['width'],
          height: properties?['height'],
          color: properties?['color'],
        );
      case AdaptiveLayoutType.card:
        return AdaptiveLayout.adaptiveCard(
          context: context,
          child: child,
          padding: properties?['padding'],
          margin: properties?['margin'],
          width: properties?['width'],
          height: properties?['height'],
        );
      case AdaptiveLayoutType.button:
        return AdaptiveLayout.adaptiveButton(
          context: context,
          child: child,
          onPressed: properties?['onPressed'],
          padding: properties?['padding'],
          width: properties?['width'],
          height: properties?['height'],
        );
      case AdaptiveLayoutType.input:
        return AdaptiveLayout.adaptiveInput(
          context: context,
          child: child,
          padding: properties?['padding'],
          width: properties?['width'],
          height: properties?['height'],
        );
      case AdaptiveLayoutType.chip:
        return AdaptiveLayout.adaptiveChip(
          context: context,
          child: child,
          padding: properties?['padding'],
          height: properties?['height'],
        );
      case AdaptiveLayoutType.badge:
        return AdaptiveLayout.adaptiveBadge(
          context: context,
          child: child,
          size: properties?['size'],
          backgroundColor: properties?['backgroundColor'],
        );
      case AdaptiveLayoutType.avatar:
        return AdaptiveLayout.adaptiveAvatar(
          context: context,
          child: child,
          size: properties?['size'],
          backgroundColor: properties?['backgroundColor'],
        );
      case AdaptiveLayoutType.thumbnail:
        return AdaptiveLayout.adaptiveThumbnail(
          context: context,
          child: child,
          size: properties?['size'],
          fit: properties?['fit'],
        );
      case AdaptiveLayoutType.loading:
        return AdaptiveLayout.adaptiveLoading(
          context: context,
          size: properties?['size'],
          color: properties?['color'],
          message: properties?['message'],
        );
      case AdaptiveLayoutType.spacing:
        return AdaptiveLayout.adaptiveSpacing(
          context: context,
          spacing: properties?['spacing'],
          isVertical: properties?['isVertical'] ?? true,
        );
    }
  }
}

/// Tipos de layout adaptativo
enum AdaptiveLayoutType {
  container,
  card,
  button,
  input,
  chip,
  badge,
  avatar,
  thumbnail,
  loading,
  spacing,
} 