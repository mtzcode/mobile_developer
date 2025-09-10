import 'package:flutter/material.dart';
import 'responsive_breakpoints.dart';

/// Sistema de tamanhos de fonte dinâmicos
class DynamicFontSizes {
  // Fatores de escala baseados no dispositivo
  static const double _mobileScale = 1.0;
  static const double _tabletScale = 1.2;
  static const double _desktopScale = 1.4;
  static const double _largeDesktopScale = 1.6;

  // Fatores de escala baseados no tamanho específico
  static const double _smallMobileScale = 0.9;
  static const double _mediumMobileScale = 1.0;
  static const double _largeMobileScale = 1.1;
  static const double _smallTabletScale = 1.2;
  static const double _largeTabletScale = 1.3;

  /// Obtém fator de escala baseado no tipo de dispositivo
  static double getDeviceScale(BuildContext context) {
    if (ResponsiveBreakpoints.isLargeDesktop(context)) {
      return _largeDesktopScale;
    } else if (ResponsiveBreakpoints.isDesktop(context)) {
      return _desktopScale;
    } else if (ResponsiveBreakpoints.isTablet(context)) {
      return _tabletScale;
    } else {
      return _mobileScale;
    }
  }

  /// Obtém fator de escala baseado no tamanho específico do dispositivo
  static double getSizeScale(BuildContext context) {
    final deviceSize = ResponsiveBreakpoints.getDeviceSize(context);
    
    switch (deviceSize) {
      case DeviceSize.smallMobile:
        return _smallMobileScale;
      case DeviceSize.mediumMobile:
        return _mediumMobileScale;
      case DeviceSize.largeMobile:
        return _largeMobileScale;
      case DeviceSize.smallTablet:
        return _smallTabletScale;
      case DeviceSize.largeTablet:
        return _largeTabletScale;
      case DeviceSize.desktop:
        return _desktopScale;
      case DeviceSize.largeDesktop:
        return _largeDesktopScale;
    }
  }

  /// Obtém fator de escala combinado (dispositivo + tamanho)
  static double getCombinedScale(BuildContext context) {
    final deviceScale = getDeviceScale(context);
    final sizeScale = getSizeScale(context);
    return deviceScale * sizeScale;
  }

  /// Calcula tamanho de fonte dinâmico
  static double getDynamicFontSize(BuildContext context, double baseSize) {
    final scale = getCombinedScale(context);
    return baseSize * scale;
  }

  /// Calcula tamanho de fonte com limite mínimo
  static double getDynamicFontSizeWithMin(
    BuildContext context, 
    double baseSize, 
    double minSize,
  ) {
    final dynamicSize = getDynamicFontSize(context, baseSize);
    return dynamicSize < minSize ? minSize : dynamicSize;
  }

  /// Calcula tamanho de fonte com limite máximo
  static double getDynamicFontSizeWithMax(
    BuildContext context, 
    double baseSize, 
    double maxSize,
  ) {
    final dynamicSize = getDynamicFontSize(context, baseSize);
    return dynamicSize > maxSize ? maxSize : dynamicSize;
  }

  /// Calcula tamanho de fonte com limites mínimo e máximo
  static double getDynamicFontSizeWithLimits(
    BuildContext context, 
    double baseSize, 
    double minSize,
    double maxSize,
  ) {
    final dynamicSize = getDynamicFontSize(context, baseSize);
    if (dynamicSize < minSize) return minSize;
    if (dynamicSize > maxSize) return maxSize;
    return dynamicSize;
  }

  /// Tamanhos de fonte pré-definidos dinâmicos
  static double getDisplayLarge(BuildContext context) {
    return getDynamicFontSize(context, 32.0);
  }

  static double getDisplayMedium(BuildContext context) {
    return getDynamicFontSize(context, 28.0);
  }

  static double getDisplaySmall(BuildContext context) {
    return getDynamicFontSize(context, 24.0);
  }

  static double getHeadlineLarge(BuildContext context) {
    return getDynamicFontSize(context, 22.0);
  }

  static double getHeadlineMedium(BuildContext context) {
    return getDynamicFontSize(context, 20.0);
  }

  static double getHeadlineSmall(BuildContext context) {
    return getDynamicFontSize(context, 18.0);
  }

  static double getTitleLarge(BuildContext context) {
    return getDynamicFontSize(context, 16.0);
  }

  static double getTitleMedium(BuildContext context) {
    return getDynamicFontSize(context, 14.0);
  }

  static double getTitleSmall(BuildContext context) {
    return getDynamicFontSize(context, 12.0);
  }

  static double getBodyLarge(BuildContext context) {
    return getDynamicFontSize(context, 16.0);
  }

  static double getBodyMedium(BuildContext context) {
    return getDynamicFontSize(context, 14.0);
  }

  static double getBodySmall(BuildContext context) {
    return getDynamicFontSize(context, 12.0);
  }

  static double getLabelLarge(BuildContext context) {
    return getDynamicFontSize(context, 14.0);
  }

  static double getLabelMedium(BuildContext context) {
    return getDynamicFontSize(context, 12.0);
  }

  static double getLabelSmall(BuildContext context) {
    return getDynamicFontSize(context, 10.0);
  }

  /// Tamanhos específicos para diferentes elementos
  static double getButtonText(BuildContext context) {
    return getDynamicFontSize(context, 15.0);
  }

  static double getInputText(BuildContext context) {
    return getDynamicFontSize(context, 16.0);
  }

  static double getCardTitle(BuildContext context) {
    return getDynamicFontSize(context, 16.0);
  }

  static double getCardSubtitle(BuildContext context) {
    return getDynamicFontSize(context, 14.0);
  }

  static double getCardBody(BuildContext context) {
    return getDynamicFontSize(context, 12.0);
  }

  static double getPrice(BuildContext context) {
    return getDynamicFontSize(context, 18.0);
  }

  static double getPriceSmall(BuildContext context) {
    return getDynamicFontSize(context, 14.0);
  }

  static double getNavigationText(BuildContext context) {
    return getDynamicFontSize(context, 12.0);
  }

  static double getChipText(BuildContext context) {
    return getDynamicFontSize(context, 12.0);
  }

  static double getBadgeText(BuildContext context) {
    return getDynamicFontSize(context, 10.0);
  }

  static double getModalTitle(BuildContext context) {
    return getDynamicFontSize(context, 20.0);
  }

  static double getModalBody(BuildContext context) {
    return getDynamicFontSize(context, 16.0);
  }

  static double getSnackBarText(BuildContext context) {
    return getDynamicFontSize(context, 14.0);
  }

  static double getTooltipText(BuildContext context) {
    return getDynamicFontSize(context, 12.0);
  }

  /// Ajusta tamanho baseado na orientação
  static double getOrientationAdjustedSize(
    BuildContext context, 
    double baseSize,
    {double landscapeMultiplier = 0.9}
  ) {
    final dynamicSize = getDynamicFontSize(context, baseSize);
    
    if (ResponsiveBreakpoints.isLandscape(context)) {
      return dynamicSize * landscapeMultiplier;
    }
    
    return dynamicSize;
  }

  /// Ajusta tamanho baseado na densidade de pixels
  static double getPixelDensityAdjustedSize(
    BuildContext context, 
    double baseSize,
  ) {
    final mediaQuery = MediaQuery.of(context);
    final pixelRatio = mediaQuery.devicePixelRatio;
    
    // Ajusta baseado na densidade de pixels
    double densityMultiplier = 1.0;
    
    if (pixelRatio <= 1.0) {
      densityMultiplier = 0.9; // Dispositivos com baixa densidade
    } else if (pixelRatio <= 2.0) {
      densityMultiplier = 1.0; // Densidade normal
    } else if (pixelRatio <= 3.0) {
      densityMultiplier = 1.1; // Alta densidade
    } else {
      densityMultiplier = 1.2; // Muito alta densidade
    }
    
    return getDynamicFontSize(context, baseSize) * densityMultiplier;
  }

  /// Ajusta tamanho baseado no tamanho da tela
  static double getScreenSizeAdjustedSize(
    BuildContext context, 
    double baseSize,
  ) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final screenArea = screenWidth * screenHeight;
    
    // Ajusta baseado na área da tela
    double areaMultiplier = 1.0;
    
    if (screenArea < 200000) { // Tela muito pequena
      areaMultiplier = 0.8;
    } else if (screenArea < 400000) { // Tela pequena
      areaMultiplier = 0.9;
    } else if (screenArea < 800000) { // Tela média
      areaMultiplier = 1.0;
    } else if (screenArea < 1200000) { // Tela grande
      areaMultiplier = 1.1;
    } else { // Tela muito grande
      areaMultiplier = 1.2;
    }
    
    return getDynamicFontSize(context, baseSize) * areaMultiplier;
  }
}

/// Widget para aplicar tamanho de fonte dinâmico
class DynamicText extends StatelessWidget {
  final String text;
  final double baseSize;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool useLimits;
  final double? minSize;
  final double? maxSize;

  const DynamicText({
    super.key,
    required this.text,
    required this.baseSize,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.useLimits = false,
    this.minSize,
    this.maxSize,
  });

  @override
  Widget build(BuildContext context) {
    double fontSize;
    
    if (useLimits && minSize != null && maxSize != null) {
      fontSize = DynamicFontSizes.getDynamicFontSizeWithLimits(
        context, 
        baseSize, 
        minSize!, 
        maxSize!
      );
    } else if (useLimits && minSize != null) {
      fontSize = DynamicFontSizes.getDynamicFontSizeWithMin(
        context, 
        baseSize, 
        minSize!
      );
    } else if (useLimits && maxSize != null) {
      fontSize = DynamicFontSizes.getDynamicFontSizeWithMax(
        context, 
        baseSize, 
        maxSize!
      );
    } else {
      fontSize = DynamicFontSizes.getDynamicFontSize(context, baseSize);
    }

    return Text(
      text,
      style: (style ?? const TextStyle()).copyWith(fontSize: fontSize),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

/// Widget para aplicar estilo de texto dinâmico
class DynamicTextStyle extends TextStyle {
  const DynamicTextStyle({
    super.color,
    super.backgroundColor,
    super.fontSize,
    super.fontWeight,
    super.fontStyle,
    super.letterSpacing,
    super.wordSpacing,
    super.textBaseline,
    super.height,
    super.leadingDistribution,
    super.locale,
    super.shadows,
    super.fontFeatures,
    super.fontVariations,
    super.decoration,
    super.decorationColor,
    super.decorationStyle,
    super.decorationThickness,
    super.debugLabel,
    super.fontFamily,
    super.fontFamilyFallback,
    super.package,
    super.overflow,
  });

  /// Cria um TextStyle com tamanho dinâmico
  static TextStyle withDynamicSize(
    BuildContext context, 
    double baseSize, {
    Color? color,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? height,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
    List<Shadow>? shadows,
    String? fontFamily,
    List<String>? fontFamilyFallback,
  }) {
    final dynamicSize = DynamicFontSizes.getDynamicFontSize(context, baseSize);
    
    return TextStyle(
      fontSize: dynamicSize,
      color: color,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      height: height,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      shadows: shadows,
      fontFamily: fontFamily,
      fontFamilyFallback: fontFamilyFallback,
    );
  }
}